# Plano — MVP do App de Finanças Pessoais (Flutter)

> **Status (04/08/2026).** Este é o plano aprovado em 22/07/2026, mantido como registro da
> decisão. O texto abaixo da seção "Status" é o original e **não** foi reescrito conforme a
> implementação avançou — leia-o como o que foi planejado, e esta seção como o que foi feito.

## O caminho crítico até publicar

**Destino: Google Play Store** (decidido em 19/08/2026, por custo — US$ 25 de taxa única
contra US$ 99/ano da Apple, e sem precisar de Mac). A App Store fica para depois, com os
assets de iOS já prontos e congelados. APK avulso segue descartado.

Toda a **preparação** está feita: identidade, ícone, splash, tradução, acessibilidade, assets
de iOS e os roteiros em `docs/`.

### A ordem mudou por causa de um prazo, não de uma dependência

Conta pessoal nova no Play exige **teste fechado com 12 testadores por 14 dias corridos**
antes de liberar produção. Isso é espera de calendário — a única coisa do projeto que não
acelera com esforço. Então ela **começa primeiro**, não por último.

| # | O quê | Quem começa | Observação |
|---|---|---|---|
| 1 | Keystore de upload (`docs/assinar-release.md`) | **Você** — um `keytool`, ~2 min | Destrava o primeiro build enviável |
| 2 | Conta Google Play Developer (US$ 25) | **Você** | Verificação de identidade leva dias |
| 3 | **Abrir o teste fechado** | Depois de 1 e 2 | Com o app incompleto mesmo. Os 14 dias correm em paralelo ao M9 |
| 4 | Configurar o Firebase (`docs/m9-auth-backup.md`, Parte 1) | **Você** — console + `flutterfire configure` | Destrava o M9 e o CE-06 |
| 5 | Política de privacidade + seção de exclusão (`docs/politica-privacidade.md`) | Depois do M9 | O Play exige URL pública de exclusão |
| 6 | Produção (`docs/distribuicao.md`) | Depois de tudo | AAB, não APK |

**1, 2 e 4 são independentes** e podem correr juntos. O acoplamento real está no fim: o
**SHA-1 da chave de assinatura do app** — a que o Google gera, não a sua de upload — só existe
depois do primeiro envio, e é ela que o Google Sign-In valida em produção. Registrar só o de
upload faz o login funcionar em desenvolvimento e falhar em silêncio para quem baixa da loja.

### O que a troca de loja mudou de verdade

- **CE-03/CE-04 ficaram muito mais baratos.** Sem Mac, sem anuidade. Era a objeção que a
  decisão anterior tinha criado.
- **Perder o keystore deixou de ser catastrófico.** Com Play App Signing o Google guarda a
  chave de assinatura e a sua é só de upload, substituível pelo console. Fora de loja, perder
  a chave significava nunca mais atualizar o app.
- **Apareceu uma exigência nova:** URL pública de exclusão de conta, que a Apple não pede.
- **"Entrar com a Apple" deixou de ser obrigatório** (diretriz 4.8 é da Apple), mas fica no
  layout, acima do Google — custa zero e evita retrabalho se a App Store voltar.

## Status da execução

**M0–M8 concluídos.** App funcional offline no Android, em pt-BR e en-US: onboarding, três
abas, contas e ocorrências mensais, entradas, cartões com fatura e rateio, virada de mês com
`FechamentoMensal`, percentuais configuráveis, exportação CSV/JSON e exclusão total.
`flutter analyze` sem issues; 66 testes de regra de negócio e 9 de integração sobre emulador.

**Os marcos** (renumerados em 04/08/2026 — o M8 original agrupava auth,
qualidade e distribuição; virou três marcos com um propósito cada):

- **M8 — Tradução (pt-BR + en-US). Feito.** `flutter_localizations` + ARB (235 chaves), as
  strings de UI saem dos widgets, e o nome exibido passa a ser localizado: "Conta em Dia" / "Bills on
  Track". Vem ANTES do auth de propósito: as telas de login, backup e exclusão de conta são
  as mais textuais do app e nasceriam em português para serem traduzidas depois.
  *Código, comentários e documentação seguem em pt-BR* — só o texto visível ao usuário é
  localizado.
- **M9 — Auth Firebase + backup na nuvem (CE-05/CE-06).** Bloqueado pela configuração do
  projeto Firebase, que depende da conta do usuário — guia em `docs/m9-auth-backup.md`
  (as dependências foram REMOVIDAS do `pubspec.yaml` até aqui; ver o passo 1.4 do guia).
  Inclui a exclusão de conta que as duas lojas exigem: apagar o `backups/{uid}` e a conta em
  si, não só o dado local — e, no Play, também uma URL pública para quem já
  desinstalou. **Restaurar só da nuvem**
  — a restauração por arquivo foi descartada em 04/08/2026 (duas fontes para o
  mesmo backup), e o `file_picker` saiu do projeto: nem a v11 nem a v12-beta
  convivem com o Kotlin embutido do Flutter 3.44 e o `share_plus`.
- **M10 — Publicação na Google Play Store (CE-03/CE-04).** Ícone, splash e identidade visual
  (`assets/marca/`) estão **prontos**, e os assets de iOS também — congelados até haver Mac.
  Falta a assinatura de upload (`docs/assinar-release.md`, hoje o build sai com
  `CN=Android Debug`), a política de privacidade com seção de exclusão
  (`docs/politica-privacidade.md`) e o envio (`docs/distribuicao.md`).
  **A produção é o último passo**, depois do M9 — senão o app iria à loja com "Entrar"
  desabilitado. **O teste fechado, porém, é o primeiro**: são 12 testadores por 14 dias
  corridos, espera de calendário que corre em paralelo ao desenvolvimento.
  A acessibilidade do antigo M8 já foi antecipada (contraste ≥4,5:1, alvos ≥44dp, rótulos
  semânticos).

Identidade definida: **`br.com.gabrielkozuki.contaemdia`** (permanente — é a chave de
atualização do Android), nome exibido "Conta em Dia".

### Onde a implementação divergiu do plano

Divergências deliberadas, aprovadas ao longo do desenvolvimento:

| Plano | O que foi feito | Por quê |
|---|---|---|
| `core/routes.dart` com `onGenerateRoute` e rotas nomeadas | Um helper único em `config_tab.dart:99` com `Navigator.push(MaterialPageRoute(...))`; o resto abre em `showModalBottomSheet`/`showDialog` | Com 3 menus fixos e formulários sobrepostos, uma tabela de rotas nomeadas não se pagava. CE-02 continua atendido (roteamento por `Navigator` entre páginas) |
| `data/db/daos/` com DAOs por agregado | Repositórios drift acessando o banco direto | Camada a mais sem ganho: os repositórios já são a fronteira de persistência |
| `data/sync/backup_service.dart` | `data/export_service.dart` (CSV/JSON de portabilidade, RF-19) e `data/backup_service.dart` (banco inteiro, base do M9) | Acabaram sendo duas coisas: exportar é para o usuário ler na planilha, o backup é para a máquina restaurar. Separados quando o segundo ganhou envelope e validação |
| `mocktail` nos testes | Drift em memória, **sem fakes** | Decisão do usuário; o pacote foi removido do `pubspec.yaml`. O SQL faz parte da regra testada, então o *test double* é o próprio banco |
| "testes de widget das abas principais" na verificação | Regra de negócio em `test/unit/` e `test/persistence/`; fluxos ponta a ponta em `integration_test/` sobre emulador | A restrição a testes de UI foi levantada em 04/08/2026 — existia para manter a suíte enxuta, não por princípio |
| Casos de uso `AplicarPagamento` e `AtualizarPercentuais` | Regra de pagamento (RN-04) nos repositórios; `ValidarPercentuais` em `usecases/percentuais.dart` | Consolidação; a validação de soma virou usecase testado, o pagamento não precisou de um |
| `features/auth/` | Ainda não existe; a tela já está em `features/config/conta_backup_page.dart` | Login não é porta de entrada, então mora em Configurações — uma pasta `auth/` só para isso não se paga. Faz parte do M9 |
| Painel 50-30-20 "rosca na aba Gráfico (não barras na home)" | Rosca na aba Gráfico, com barra de progresso por grupo nas linhas abaixo dela. A aba Contas tem só a barra de "pago este mês" | Cumprido como planejado. O RF-12 pede planejado/comprometido/limite por grupo; hoje a linha do grupo mostra comprometido, % realizado e meta% — o `limite` em R$ é calculado (`calcular_metodologia.dart`) e não exibido |

Decisões posteriores ao plano (histórico de meses, reabertura, esquema) estão registradas em
`.claude/requisitos-app-financas.md` e no histórico de decisões do projeto.

---

## Context

O repositório é um projeto Flutter recém-criado (Flutter 3.44.6 / Dart 3.12.2) contendo
apenas uma vitrine de UI: `lib/main.dart` renderiza uma tela única "Meu mês" com checklist
de contas **mock** (sem persistência), `lib/models/conta.dart` traz o modelo `Conta` em
memória + enum `Grupo`, `lib/utils/formatter.dart` tem o helper `brl()`, e `lib/main_demo.dart`
é o contador padrão do Flutter (descartável). Não há navegação, banco de dados, autenticação
nem testes reais.

O objetivo é desenvolver e implantar o **MVP funcional completo** descrito em
`.claude/requisitos-app-financas.md` (seção 5 inteira) de forma a **cumprir os 6 critérios
obrigatórios de entrega (seção 14)**, mantendo os princípios de produto (offline-first no uso
diário, educativo/não punitivo, **simplicidade**) e o objetivo de portfólio (arquitetura em
camadas + testes das regras de negócio, RNF-06). O protótipo Whimsical fornecido é a
referência visual e de navegação.

### Decisões fechadas com o usuário
- **Estado / DI:** Riverpod (`flutter_riverpod`).
- **Persistência local:** SQLite/drift como **fonte de verdade** (offline-first, testável).
- **Navegação:** **exatamente 3 menus fixos** na barra inferior — **Contas | Gráfico |
  Configurações** (conforme protótipo). Formulários e detalhes (nova/editar conta,
  cartão/fatura, entradas, login, onboarding) **abrem sobrepostos** (push/modal) e voltam pelo
  botão voltar — são páginas (contam para CE-01), mas **nunca viram um 4º menu**. Roteamento
  com **`Navigator` nativo + rotas nomeadas** (sem `go_router`).
- **Painel 50-30-20:** **rosca/donut na aba Gráfico** (não barras na home), com total no centro
  + linhas por grupo (Necessidade/Desejo/Investimento/Livre) com % e sinalização neutra
  "meta X% · acima/abaixo" (RF-13). A aba Contas mostra só "pago este mês" + checklist.
- **Autenticação:** Firebase Auth com **Google + Apple**, dando acesso à conta do usuário (CE-06).
- **Sincronização em nuvem:** **backup/restore do banco inteiro por UID** (sem merge por
  registro; *last-backup-wins*) num **blob JSON** no **Firebase Realtime Database** — gratuito
  no plano Spark e **sem exigir cartão de crédito** (o Cloud Storage passou a exigir Blaze+cartão
  desde fev/2026; Realtime DB permanece grátis). Push sob demanda + no logout; oferta de
  restauração ao logar em novo aparelho.
- **Plataforma/distribuição:** desenvolver e testar em **Android agora**; distribuir um
  **APK/AAB por link público (GitHub Releases)** para cumprir CE-03/CE-04. **iOS/App Store**
  fica para fase posterior (usuário tem acesso a Mac).
- **Escopo:** MVP funcional completo (módulos A–G da seção 5).

> **Ajuste aprovado:** haverá sincronização em nuvem, o que sobrepõe o RNF-04 original — os
> dados passam a ir para a nuvem **atrelados ao usuário autenticado**, de forma explícita. É o
> que dá sentido ao login (CE-06) e à continuidade entre aparelhos.

### Como cada critério obrigatório (seção 14) é atendido
| Critério | Como |
|---|---|
| CE-01 Múltiplas páginas | Login, Onboarding, shell de 3 abas + telas sobrepostas (nova/editar conta, cartão/fatura, entradas) |
| CE-02 Navegação/roteamento | `Navigator` nativo + rotas nomeadas; `NavigationBar` de 3 destinos |
| CE-03 Distribuição | APK/AAB em **GitHub Releases** (link público) agora; App Store iOS depois |
| CE-04 Plataforma mobile | Android agora; iOS depois |
| CE-05 Banco de dados | SQLite local via **drift** + backup na nuvem (Realtime Database) |
| CE-06 Autenticação | Firebase Auth (Google + Apple); a conta dá acesso ao backup |

## Arquitetura

Camadas isoladas (UI → casos de uso → repositórios → persistência), domínio livre de Flutter e
coberto por testes. Estrutura *feature-first*:

```
lib/
  main.dart                 # bootstrap: Firebase.init, ProviderScope, MaterialApp (rotas nomeadas)
  core/
    theme/app_theme.dart    # extrair tema do main.dart atual (seed 0xFF0F766E, M3)
    format/money.dart       # brl() atual -> NumberFormat pt_BR (intl)
    format/dates.dart       # nomes de meses pt_BR
    routes.dart             # nomes de rotas + onGenerateRoute (Navigator nativo)
  domain/
    entities/               # Grupo, Entrada, Conta, OcorrenciaConta, Cartao, Fatura, Rateio, ConfigMetodologia, FechamentoMensal
    repositories/           # interfaces (contratos)
    usecases/               # regras de negócio puras (ver abaixo)
  data/
    db/app_database.dart    # @DriftDatabase (tabelas da seção 8)
    db/tables.dart
    db/daos/                # DAOs por agregado
    repositories/           # implementações drift dos contratos do domínio
    sync/backup_service.dart # export/import do banco (JSON) + push/pull no Realtime Database por UID
  features/
    auth/         # tela de Login (Google/Apple) + provider de sessão
    onboarding/   # fluxo de 1ª execução (renda -> metodologia -> 3–5 contas)
    shell/        # Scaffold + NavigationBar de 3 abas (IndexedStack)
    contas/       # aba Contas (checklist) + telas sobrepostas: nova/editar conta, cartão/fatura
    grafico/      # aba Gráfico (rosca 50-30-20 + linhas por grupo)
    config/       # aba Configurações: entradas, percentuais, exportação, backup, apagar dados
```

Providers Riverpod expõem `AppDatabase`, repositórios e casos de uso; os notifiers de tela
consomem casos de uso. Nos testes, os repositórios drift são instanciados direto sobre um
banco em memória (`NativeDatabase.memory()`) — não há fakes.

### Navegação (3 menus fixos)
`ShellPage` = `Scaffold` com `NavigationBar` de 3 destinos e `IndexedStack` das 3 abas. Um
*root gate* escuta `FirebaseAuth.authStateChanges`: sem sessão → `LoginPage`; primeira execução
→ `OnboardingPage`; caso contrário → `ShellPage`. Telas de formulário/detalhe são empilhadas
com `Navigator.pushNamed` a partir das abas (ex.: FAB "+" na aba Contas abre "nova conta").
**Histórico não é tela nova**: é o próprio seletor de meses (‹ Julho 2026 ›) das abas Contas e
Gráfico exibindo meses fechados em modo somente-leitura (RF-18).

### Modelo de dados (drift — seção 8 do documento)
Tabelas: `Entradas`, `Contas`, `OcorrenciasConta`, `Cartoes`, `FaturasCartao`,
`RateiosFatura`, `ConfiguracaoMetodologia`, `FechamentosMensais`. Chaves e colunas conforme
seção 8; `mesReferencia` como `YYYY-MM`. Migrações versionadas (`schemaVersion`).

### Sincronização em nuvem (backup/restore por UID)
`BackupService` reutiliza o mesmo export/import da exportação de dados (RF-19): serializa o
banco para JSON e grava em `Realtime Database` no caminho `backups/{uid}` (um blob por usuário),
lendo/restaurando sob demanda. Gatilhos: botão manual em Configurações, *push* automático no
logout e *pull* opcional ao logar em novo aparelho (diálogo "restaurar backup de DD/MM?"). Sem
merge por registro — o último backup substitui o estado local ao restaurar. Regras de segurança
do Realtime DB restringindo cada UID ao seu próprio nó (`auth.uid == $uid`).

### Casos de uso com testes unitários (RNF-06 — objetivo de portfólio)
- `CalcularMetodologia` — planejado/comprometido/limite por grupo + "livre para gastar" e os %
  exibidos na rosca (RF-12..15); sinalização neutra ao ultrapassar (RF-13).
- `GerarMes` — virada: gera ocorrências de recorrentes + parcelas em aberto + faturas (RF-16);
  mês fechado não rola (RN-05).
- `GerarParcelas` — cria N ocorrências independentes com contador (RF-06/RN-03); excluir
  "só esta" vs "esta e futuras" sem tocar meses fechados.
- `RatearFatura` — subdivisão entre grupos deve somar o total (RF-23/RN-08).
- `AplicarPagamento` — valor pago substitui planejado só naquele mês (RN-04).
- `AtualizarPercentuais` — validação soma = 100%, vale mês corrente/futuros; snapshot no
  histórico (RF-15/RN-06).

> **Reordenação aprovada (22/07/2026):** a **autenticação (login/gate) e o backup na nuvem
> foram movidos para o fim** do desenvolvimento. Primeiro constrói-se toda a navegação de 3
> abas e a UI funcional ligada ao banco (rodando no Android sem exigir login durante o dev);
> Firebase Auth + Realtime DB entram por último, quando o usuário configurar o projeto Firebase
> (depende da conta dele). M2 abaixo passa a ser só a navegação; M8 passa a incluir auth+backup.

## Plano de implementação (marcos)

**M0 — Fundação.** Remover `main_demo.dart`; adicionar dependências
(`flutter_riverpod`, `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `path_provider`,
`firebase_core`, `firebase_auth`, `firebase_database`, `google_sign_in`, `sign_in_with_apple`,
`intl`, `fl_chart`, `csv`, `excel`, `share_plus`; dev: `drift_dev`, `build_runner`, `mocktail`).
Criar estrutura de pastas; extrair tema para `core/theme` e `brl()` para `core/format`.

**M1 — Persistência + domínio.** Definir tabelas drift (seção 8) + `build_runner`; DAOs;
interfaces de repositório + implementações drift; entidades e **casos de uso** puros. Escrever
os testes unitários das regras aqui.

**M2 — Navegação + Auth (CE-01/02/06).** Setup Firebase (projeto, `flutterfire configure`,
`google-services.json`, SHA-1 no console p/ Google Sign-In no Android); Realtime DB habilitado.
`ShellPage` com `NavigationBar` de 3 abas + `Navigator`/rotas nomeadas; *root gate* de auth;
tela de Login (Google + Apple). Sessão fica em cache → após 1º login o app abre offline (RNF-01).

**M3 — Onboarding + aba Contas.** Fluxo de onboarding (renda → metodologia → 3–5 contas,
seção 9) limitado a 3–5 itens com sugestões. Aba **Contas**: seletor de mês, card "pago este
mês" + checklist ordenada por vencimento — **reaproveitando os widgets do `main.dart` atual**,
ligados ao drift via Riverpod (RF-08..11; marcar paga em ≤2 toques, RNF-03). FAB "+" abre
"nova conta" sobreposta.

**M4 — Contas, Entradas, Parcelas.** Tela (sobreposta) de conta criar/editar/pausar/excluir
("só este mês" vs "próximos", RF-04/05/07); valor variável ajustável (RF-05); despesa avulsa
pela checklist (RF-11); parcelas (RF-06). Gestão de entradas recorrentes + pontuais em
Configurações (RF-01..03).

**M5 — Cartão/Fatura + Rateio.** CRUD de cartões (RF-21); fatura mensal com valor total e
marcação de paga aparecendo na própria checklist da aba Contas (RF-22); tela sobreposta de
rateio entre grupos com validação de soma amigável (RF-23/RN-08).

**M6 — Aba Gráfico + Ciclo mensal + Histórico.** Aba **Gráfico**: rosca (`fl_chart`) com total
no centro + linhas por grupo com % e "meta · acima/abaixo" (RF-12..14). Virada de mês no 1º
acesso do novo mês: gera ocorrências, grava `FechamentoMensal` (snapshot) e mostra resumo neutro
do mês fechado (RF-16..18). Histórico = seletor de meses em modo leitura nas abas Contas/Gráfico.

**M7 — Configurações + Exportação + Backup.** Percentuais configuráveis (soma 100%, RF-15);
exportação CSV no formato da checklist + JSON de backup (RF-19); apagar todos os dados com
dupla confirmação (RF-20). **`BackupService`**: push/restore do backup no Realtime Database por
UID (botão manual, push no logout, oferta de restauração ao logar em novo aparelho) + regras de
segurança por UID.

**M8 — Qualidade + Distribuição.** Acessibilidade (contraste, alvos ≥44pt, semântica — RNF-05);
checar abertura <2s (RNF-02); cobertura das regras; README de portfólio (arquitetura + decisões).
**Build Android release** (`flutter build appbundle`/`apk`), assinatura, e publicar
**GitHub Release** com o APK como link público (**CE-03**). Fase posterior no Mac:
`flutter build ipa`, Sign in with Apple, TestFlight → App Store.

## Arquivos-chave a criar/alterar
- Reaproveitar: `lib/main.dart` (widgets de resumo/checklist → `features/contas/`),
  `lib/models/conta.dart` (enum `Grupo` → `domain/entities`), `lib/utils/formatter.dart` (→ `core/format`).
- Remover: `lib/main_demo.dart`; reescrever `test/widget_test.dart`.
- Novos: conforme árvore de arquitetura acima.
- `pubspec.yaml` (dependências) e `android/` (config Firebase/assinatura).

## Verificação (fim a fim)
1. `flutter analyze` sem erros; `dart format`.
2. `flutter test` — casos de uso das regras (metodologia, virada, parcelas, rateio, pagamento)
   passando; testes de widget das abas principais.
3. `flutter run` em emulador/dispositivo Android: login (Google/Apple) → onboarding → aba Contas
   marcar conta paga (≤2 toques) → aba Gráfico reflete na rosca → adicionar cartão + rateio →
   virar mês (data simulada) → exportar CSV → backup no Realtime DB → apagar dados → **relogar e
   restaurar backup**, confirmando que os dados voltam. Confirmar que a barra inferior tem
   **exatamente 3 menus**.
4. `flutter build apk --release` gera artefato; instalar em device físico e validar abertura <2s.
5. Publicar APK em GitHub Release e confirmar que o link público baixa e instala (CE-03).
6. (Fase iOS, no Mac) `flutter build ipa`, validar Sign in with Apple, subir TestFlight.

## Fora deste MVP (mantém seção 3.2 + roadmap)
Integração bancária/Open Finance, extrato de transações, contas compartilhadas, sync contínuo
multi-dispositivo em tempo real com merge por registro (aqui é backup/restore last-wins),
notificações push, múltiplas moedas. Publicação iOS na App Store entra como fase seguinte (não
bloqueia CE-03/CE-04, já cumpridos via Android).
