import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_service.dart';
import '../data/backup_nuvem_service.dart';
import '../data/db/app_database.dart';
import '../data/backup_service.dart';
import '../data/export_service.dart';
import '../data/repositories/drift_cartoes_repository.dart';
import '../data/repositories/drift_config_repository.dart';
import '../data/repositories/drift_contas_repository.dart';
import '../data/repositories/drift_entradas_repository.dart';
import '../data/repositories/drift_fechamento_repository.dart';
import '../domain/entities/usuario.dart';
import '../domain/repositories/repositories.dart';
import 'format/dates.dart';

/// Banco local (fonte de verdade). Instância única durante a vida do app.
final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Executa várias escritas como uma unidade: ou tudo grava, ou nada.
///
/// Existe para as duas gravações compostas do app — cadastro de conta
/// parcelada (1 conta + N ocorrências) e conclusão do onboarding (rendas +
/// percentuais + contas). Sem isso, uma falha no meio deixa estado parcial que
/// nenhuma tela corrige: no onboarding, por exemplo, gravar só as rendas faz
/// `precisaOnboarding` virar false e o usuário cai no app com metade do que
/// cadastrou.
final emTransacaoProvider =
    Provider<Future<void> Function(Future<void> Function())>(
        (ref) => ref.watch(dbProvider).transaction);

/// Repositórios expostos por interface: o domínio declara o contrato, a camada
/// de dados implementa. Os testes não passam por aqui — instanciam o
/// repositório drift direto sobre um banco em memória.
final contasRepoProvider = Provider<ContasRepository>(
    (ref) => DriftContasRepository(ref.watch(dbProvider)));

final entradasRepoProvider = Provider<EntradasRepository>(
    (ref) => DriftEntradasRepository(ref.watch(dbProvider)));

final configRepoProvider = Provider<ConfigRepository>(
    (ref) => DriftConfigRepository(ref.watch(dbProvider)));

final cartoesRepoProvider = Provider<CartoesRepository>(
    (ref) => DriftCartoesRepository(ref.watch(dbProvider)));

/// Planilha CSV do mês (RF-19).
final exportServiceProvider =
    Provider<ExportService>((ref) => ExportService(ref.watch(dbProvider)));

/// Backup completo do banco: gerar, restaurar e apagar. Recebe a `AppDatabase`
/// direto, e não os repositórios: é operação sobre o banco INTEIRO, que não
/// cabe nos contratos por agregado.
final backupServiceProvider =
    Provider<BackupService>((ref) => BackupService(ref.watch(dbProvider)));

final fechamentoRepoProvider = Provider<FechamentoRepository>(
    (ref) => DriftFechamentoRepository(ref.watch(dbProvider)));

// ---------------------------------------------------------------------------
// M9 — conta e backup na nuvem
//
// Nada aqui é tocado pelo uso diário: o app abre e funciona inteiro sem conta
// (RNF-01/RNF-04). Só a tela "Conta e backup" observa estes providers.
// ---------------------------------------------------------------------------

/// `false` quando `Firebase.initializeApp` falhou no start. A tela de conta usa
/// isso para explicar em vez de oferecer um botão que não vai funcionar — o
/// resto do app ignora.
///
/// O valor real vem de um `override` no `ProviderScope` do `main`: é decidido
/// uma vez, antes do primeiro frame, e não muda durante a sessão.
final firebaseDisponivelProvider = Provider<bool>((_) => false);

final authServiceProvider = Provider<AuthService>((_) => AuthService());

final backupNuvemProvider =
    Provider<BackupNuvemService>((_) => BackupNuvemService());

/// Sessão atual. É `Stream` e não leitura pontual porque o Firebase também
/// desloga por conta própria — token revogado, conta excluída em outro
/// aparelho — e a tela precisa refletir isso sem o usuário tocar em nada.
final usuarioProvider = StreamProvider<Usuario?>((ref) {
  if (!ref.watch(firebaseDisponivelProvider)) return Stream.value(null);
  return ref.watch(authServiceProvider).mudancas;
});

/// Meses (`YYYY-MM`) reabertos para edição nesta sessão. É estado em memória:
/// ao reabrir, o mês volta a ser editável; ao reiniciar o app, o conjunto zera
/// e os meses passados voltam a ser fechados (re-congelados na próxima virada).
class MesesReabertosNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void reabrir(String mes) => state = {...state, mes};
  void refechar(String mes) => state = {...state}..remove(mes);

  /// Esquece todos os meses reabertos — usado ao apagar tudo (RF-20), senão
  /// ficam marcados meses de dados que não existem mais.
  void limpar() => state = {};
}

final mesesReabertosProvider =
    NotifierProvider<MesesReabertosNotifier, Set<String>>(
        MesesReabertosNotifier.new);

/// Mês de referência selecionado (primeiro dia do mês). Controla o recorte
/// exibido nas abas Contas e Gráfico e permite navegar pelo histórico.
class MesSelecionadoNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month);
  }

  /// Avança (+1) ou retrocede (-1) meses, normalizando a virada de ano.
  void mover(int delta) => state = DateTime(state.year, state.month + delta);

  void definir(DateTime mes) => state = DateTime(mes.year, mes.month);
}

final mesSelecionadoProvider =
    NotifierProvider<MesSelecionadoNotifier, DateTime>(
        MesSelecionadoNotifier.new);

/// Chave `YYYY-MM` derivada do mês selecionado.
final mesReferenciaProvider =
    Provider<String>((ref) => mesReferencia(ref.watch(mesSelecionadoProvider)));

/// Lista de todas as entradas cadastradas (tela de gestão de renda).
final entradasProvider = FutureProvider(
    (ref) => ref.watch(entradasRepoProvider).todas());

/// Entradas que compõem a renda do mês selecionado: recorrentes ativas +
/// pontuais daquele mês. Base da tela de Rendas.
final entradasDoMesProvider = FutureProvider((ref) =>
    ref.watch(entradasRepoProvider).doMes(ref.watch(mesReferenciaProvider)));

/// Lista de cartões ativos (tela de gestão de cartões).
final cartoesProvider = FutureProvider(
    (ref) => ref.watch(cartoesRepoProvider).listarAtivos());

/// Indica se a primeira execução (onboarding) é necessária: verdadeiro quando
/// não há nenhuma entrada nem conta cadastrada. Invalidado ao concluir o
/// onboarding para reavaliar e liberar o app.
final precisaOnboardingProvider = FutureProvider<bool>((ref) async {
  final qtdEntradas = await ref.watch(entradasRepoProvider).contarTodas();
  final contasAtivas = await ref.watch(contasRepoProvider).listarAtivas();
  return qtdEntradas == 0 && contasAtivas.isEmpty;
});
