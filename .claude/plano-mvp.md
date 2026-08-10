# Plano — MVP do App de Finanças Pessoais (Flutter)

> **Status (04/08/2026).** Este é o plano aprovado em 22/07/2026, mantido como registro da
> decisão. O texto abaixo da seção "Status" é o original e **não** foi reescrito conforme a
> implementação avançou — leia-o como o que foi planejado, e esta seção como o que foi feito.

## Status da execução

**M0–M7 concluídos.** App funcional offline no Android: onboarding, três abas, contas e
ocorrências mensais, entradas, cartões com fatura e rateio, virada de mês com `FechamentoMensal`,
percentuais configuráveis, exportação CSV/JSON e exclusão total. `flutter analyze` sem
issues; 43 testes de regra de negócio passando.

**M8 pendente**, dividido em duas partes:
- **Auth + backup na nuvem** — bloqueado pela configuração do projeto Firebase, que depende da
  conta do usuário. As dependências já estão no `pubspec.yaml`, mas **nada de Firebase é
  importado em `lib/`** ainda. Guia em `docs/configurar-firebase.md`.
- **Qualidade + distribuição** — a parte de acessibilidade do M8 foi antecipada (contraste
  ≥4,5:1 nas cores de grupo e ≥3:1 nos elementos gráficos, alvos ≥44dp, rótulos semânticos);
  falta o build de release assinado e o GitHub Release público (CE-03).

### Onde a implementação divergiu do plano

Divergências deliberadas, aprovadas ao longo do desenvolvimento:

| Plano | O que foi feito | Por quê |
|---|---|---|
| `core/routes.dart` com `onGenerateRoute` e rotas nomeadas | Um helper único em `config_tab.dart:99` com `Navigator.push(MaterialPageRoute(...))`; o resto abre em `showModalBottomSheet`/`showDialog` | Com 3 menus fixos e formulários sobrepostos, uma tabela de rotas nomeadas não se pagava. CE-02 continua atendido (roteamento por `Navigator` entre páginas) |
| `data/db/daos/` com DAOs por agregado | Repositórios drift acessando o banco direto | Camada a mais sem ganho: os repositórios já são a fronteira de persistência |
| `data/sync/backup_service.dart` | `data/export_service.dart` (`exportarJson`/`importarJson`), que será a base do backup | O mesmo serializador atende RF-19 e o backup do M8 |
| `mocktail` nos testes | Drift em memória, **sem fakes** | Decisão do usuário; o pacote foi removido do `pubspec.yaml`. O SQL faz parte da regra testada, então o *test double* é o próprio banco |
| "testes de widget das abas principais" na verificação | Somente testes de regra de negócio (`test/unit/`, `test/persistence/`) | Decisão expressa do usuário: sem testes de widget/UI |
| Casos de uso `AplicarPagamento` e `AtualizarPercentuais` | Regra de pagamento (RN-04) nos repositórios; `ValidarPercentuais` em `usecases/percentuais.dart` | Consolidação; a validação de soma virou usecase testado, o pagamento não precisou de um |
| `features/auth/` | Ainda não existe | Faz parte do M8 pendente |
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
