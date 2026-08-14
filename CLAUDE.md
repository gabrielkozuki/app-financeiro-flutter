# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

App Flutter de finanças pessoais: checklist mensal de contas + painel 50-30-20. Offline-first,
projeto de estudo/portfólio. Código, comentários e documentação em **português do Brasil** —
mantenha assim.

## Comandos

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # após mexer em data/db/tables.dart
flutter analyze --no-pub                                   # deve ficar em 0 issues
flutter test --no-pub                                      # suíte completa
flutter test test/unit/percentuais_test.dart --no-pub       # um arquivo
flutter test --plain-name "soma 101 é recusada" --no-pub    # um teste
flutter run                                                # só Android (não há target web/desktop)
```

`app_database.g.dart` é gerado — nunca edite à mão. Não existe emulador configurado por padrão;
não conte com `flutter run` para validar mudanças.

## O modelo mental que o código exige

**`Conta` é o modelo; `OcorrenciaConta` é a instância daquele mês.** Essa separação é a espinha
dorsal do app: cada mês tem ocorrências próprias e independentes (inclusive parcelas), agrupadas
sob a conta de origem. É o que permite "excluir esta e as futuras" sem tocar em meses fechados.
Mesma relação entre `Cartao` e `FaturaCartao`. Editar a conta muda o futuro; editar a ocorrência
muda só aquele mês.

**Um mês tem três estados**, e quase todo bug de dado nasce de confundi-los:

| Estado | Comportamento |
|---|---|
| Corrente ou futuro | A virada gera ocorrências e faturas que faltam; tudo editável |
| Passado fechado | Somente leitura. Renda e percentuais vêm do snapshot `FechamentoMensal`, não do cálculo ao vivo — mudar a renda hoje **não** reescreve o histórico |
| Passado reaberto | Editável, mas **nunca gerado**. Reabrir libera só a correção do que já existe |

**`panoramaMesProvider` (`features/mes/mes_panorama.dart`) é um `FutureProvider.family` por
`YYYY-MM` que ESCREVE no banco durante a leitura** — executa a virada e o fechamento dos meses
passados. É um desenho deliberado, aprovado, não um descuido. Consequências ao mexer nele:

- A virada não tem trava em memória e não precisa: a idempotência é do banco (invariante 3) e
  duas abas observam a MESMA instância da family, então o Riverpod já compartilha uma computação
  por mês. Não reintroduza um mapa de "viradas em voo" — ele fica obsoleto e ainda serve resultado
  velho a quem chega durante o voo.
- Nenhum `ref.read` depois de um `await` dentro do provider: os repositórios são capturados antes
  do primeiro await e passados por parâmetro. Invalidação durante a computação lançaria.
- Os ~13 pontos de escrita do app fazem `ref.invalidate(panoramaMesProvider)` na **family
  inteira** (recarrega todos os meses em cache). Nenhum provider é `autoDispose`.

## Invariantes que corrompem dado se quebrados

1. **Mês passado nunca é gerado** (RN-05). A guarda é `if (!ehPassado)` em `mes_panorama.dart`.
   Reintroduzir `|| reaberto.contains(mes)` faz contas criadas hoje aparecerem no histórico e
   serem congeladas no `FechamentoMensal` ao concluir a edição.
2. **A ordem dos enums em `domain/entities/enums.dart` é contrato de persistência.** São gravados
   como `intEnum`, então reordenar reclassifica em silêncio tudo o que já está no banco e em todo
   backup JSON. Travado por `test/persistence/esquema_test.dart`.
3. **Uma conta tem no máximo uma ocorrência por mês** (e um cartão, uma fatura), garantido por
   `uniqueKeys` + `onConflict: DoNothing`. É o que torna a virada idempotente.
4. **Enquanto o app está em desenvolvimento, o banco tem VERSÃO ÚNICA** (`schemaVersion = 1`, sem
   `onUpgrade`). Mudou tabela? Desinstale o app no aparelho de teste — não escreva migração, e
   não suba a versão. Depois de publicar isso se inverte: aí existem bancos de usuários reais e
   toda alteração exige `onUpgrade` data-safe.
5. **Fatura pendente nunca tem `valorPago`.** `desmarcarFatura` limpa o campo; use
   `FaturaCartao.valorEfetivo`, não `valorPago ?? valorTotal` espalhado.
6. **O rateio da fatura precisa somar exatamente o total** (RN-08) — use
   `RatearFatura().validar(...)`, não reimplemente o epsilon.

## Padrões a seguir

- **Toda escrita passa por `executarComFeedback` (`core/feedback.dart`)**, que captura a exceção,
  faz `debugPrint`, mostra SnackBar e devolve `bool`. Não relança — o chamador reseta o
  `_salvando` e só fecha a tela ou invalida providers se voltou `true`. Não existe outro `catch`
  no `lib/`.
- **Ramo `error:` de `AsyncValue` usa `erroAsync(...)` do `core/widgets/ui_kit.dart`**, que loga e
  devolve um `ErrorState` com "Tentar novamente". Nunca exiba a exceção na tela.
- **`ref`/`context` depois de `await`** exigem `if (context.mounted)`.
- **Cores de grupo (`core/theme/grupo_visual.dart`) têm contraste calculado**, com a razão WCAG
  em comentário ao lado. Ao alterar qualquer uma, recalcule luminância relativa de verdade:
  ≥4,5:1 para texto, ≥3:1 para elemento gráfico e para o par ícone/fundo do `GroupAvatar`.
- **Alvo de toque ≥44dp** (`AppTheme.alvoToqueMinimo`) e a barra do seletor de mês deriva a altura
  de `MediaQuery.textScalerOf(context).scale(48)` — nunca limite o `textScaler` do usuário.
- **Tom neutro** ao ultrapassar um grupo (RF-13): sem vermelho de erro, sem ícone de alerta, sem
  linguagem de culpa. É princípio de produto, não estética.

## M9 (auth + backup) — decisões já tomadas

- **Login NÃO é porta de entrada.** O app abre e funciona inteiro sem conta
  (RNF-01/RNF-04). Entrar mora em `features/config/conta_backup_page.dart`,
  alcançável de Configurações **e** do botão "Já uso o app" na primeira tela do
  onboarding — sem essa porta, um aparelho recém-instalado não chega à
  restauração. O `RootGate` continua binário.
- **"Entrar com a Apple" vem ACIMA de "Entrar com o Google".** Não é preferência
  visual: a diretriz 4.8 da App Store exige alternativa equivalente e com
  privacidade quando há login de terceiros, e as HIG pedem destaque. Reordenar
  arrisca rejeição na publicação.
- **Excluir conta** (diretriz 5.1.1(v) da App Store) é diferente de "apagar dados locais":
  precisa remover o `backups/{uid}` e a conta no Firebase, não só o banco.
- **Backup:** blob JSON por UID no Realtime Database, *last-wins*. Perguntar no
  logout antes de enviar; ao logar com UID diferente do último visto, perguntar
  "usar os dados deste aparelho" vs "restaurar os da conta" com a data do backup.
- `data/backup_service.dart` é a base e **não sabe nada de rede** — o serviço de
  nuvem só move a String de `exportarJson()`/`importarJson()`.
- Depois de trocar o banco inteiro, chame `aposMudancaAmpla(ref)` — invalidar as
  leituras sem esquecer os meses reabertos deixa a tela mostrando dado que não
  existe mais.

## Decisões fechadas — não reabrir sem perguntar

Riverpod; drift/SQLite; **exatamente 3 menus fixos** (Contas · Gráfico · Configurações) com
formulários sobrepostos, nunca um 4º menu; `Navigator` nativo sem `go_router`; rosca `fl_chart`
na aba Gráfico; Firebase Auth + Realtime Database para o backup (M8, ainda não implementado);
pastas `core`/`domain`/`data`/`features`.

**Testes cobrem apenas regra de negócio** — `test/unit/` (regras puras) e `test/persistence/`
(drift em memória, sem `mocktail` e **sem fakes** — o SQL faz parte da regra testada, então o
*test double* é o próprio banco). **Não escreva testes de widget/UI**: foi excluído por
decisão expressa.

*"Simplicidade acima de completude"* é princípio de produto: proposta que adiciona complexidade
precisa justificar o ganho.

## Documentos

- `.claude/requisitos-app-financas.md` — requisitos (RF/RN/RNF) e os critérios de entrega
  CE-01..CE-06. É a fonte da verdade; amarre mudanças a ele.
- `.claude/plano-mvp.md` — plano dos marcos M0–M10, status atual e onde a execução divergiu.
- `docs/configurar-firebase.md` — o que falta para o M9 (auth + backup).
