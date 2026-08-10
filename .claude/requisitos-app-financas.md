# Documento de Requisitos — App de Gestão de Finanças Pessoais

**Versão:** 1.1
**Data:** 17/07/2026 (v1.0) · 04/08/2026 (v1.1 — alinhamento com as decisões de implementação)
**Plataforma:** Aplicativo mobile
**Contexto:** Projeto de estudo pessoal com objetivo de portfólio (produto + código)

---

## 1. Visão geral

### 1.1 O problema

A maioria das pessoas com renda fixa mensal não sabe responder duas perguntas simples no meio do mês: "já paguei tudo o que devia?" e "estou gastando dentro do que planejei?". Os apps de finanças existentes exigem registro transação a transação, sincronização bancária ou categorização detalhada — um esforço que a maioria abandona nas primeiras semanas. Planilhas resolvem, mas exigem disciplina e conhecimento para montar.

### 1.2 A solução

Um app mobile que funciona como uma **checklist mensal de contas** combinada com um **painel de direcionamento financeiro** baseado na metodologia 50-30-20. O usuário informa sua renda, cadastra suas contas e despesas planejadas, marca o que já pagou e vê, em uma única tela, se o dinheiro dele está indo para onde deveria.

### 1.3 Proposta de valor

> "Saiba se você já pagou o que devia e se está gastando dentro do que planejou — em uma tela."

O app **não** é um registrador de transações nem se conecta a bancos. Ele trabalha no nível de "contas e envelopes mensais", priorizando simplicidade e o hábito de conferência mensal em vez de controle microscópico.

### 1.4 Objetivos do projeto (estudo/portfólio)

- Exercitar o ciclo completo de produto: descoberta, requisitos, design, implementação e publicação na App Store.
- Produzir um case de portfólio com documentação de produto e código limpo e testável.
- Praticar modelagem de domínio com regras de negócio reais (ciclos mensais, recorrência, rateio percentual).

### 1.5 Princípios de produto

1. **Educativo, não punitivo.** O app esclarece e incentiva bons comportamentos; nunca bloqueia, restringe ou culpa. A metodologia 50-30-20 é uma referência de diagnóstico ("veja onde seu dinheiro está indo em relação ao ideal"), não um limite imposto.
2. **Realidade brasileira.** Muitos usuários terão meses em que a renda cobre apenas as contas essenciais — e o app precisa funcionar bem e com dignidade nesse cenário, mostrando o panorama com neutralidade.
3. **Simplicidade acima de completude.** Nada de microgerenciamento: sem itemizar fatura de cartão, sem registrar cafezinho, sem categorização obrigatória de transações.
4. **O dado é do usuário.** Offline-first, exportação em formato aberto e nenhum dado financeiro saindo do dispositivo sem ação explícita do usuário.

---

## 2. Público-alvo e personas

### 2.1 Público-alvo

Adultos de 20 a 35 anos, com renda mensal majoritariamente fixa (CLT, estágio, bolsa, salário + vale), que estão começando a organizar a vida financeira e consideram apps tradicionais de finanças burocráticos demais. Perfil digital, mas sem paciência para categorizar cada gasto pequeno.

### 2.2 Persona primária — "Camila, 26, analista júnior CLT"

Camila recebe salário no 5º dia útil. Tem contas fixas (aluguel, internet, celular, academia) e algumas variáveis (cartão de crédito, mercado). Já tentou usar planilha e um app de finanças, mas abandonou os dois em menos de um mês. O que ela quer: bater o olho e saber o que falta pagar e se pode gastar no fim de semana sem culpa.

- **Dores:** esquece vencimentos; não sabe quanto "sobra" de verdade; sente que o dinheiro some.
- **Ganhos esperados:** visão clara do mês em menos de 1 minuto por dia; alívio de não esquecer contas.

### 2.3 Persona secundária — "Rafael, 31, autônomo com renda variável"

Rafael tem uma renda base previsível e ganhos extras que variam mês a mês. Meses fracos acontecem, e nesses meses quase toda a renda vai para necessidades. Para ele, o valor do app está justamente em **tornar visível essa instabilidade**: ver que num mês as necessidades consumiram 90% da renda é o alerta que o motiva a agir. A renda variável não é um caso de borda a ser tolerado — é um cenário de primeira classe, coerente com o propósito educativo do app.

- **Dores:** não sabe se o mês "fechou no azul"; a instabilidade da renda dificulta planejar.
- **Ganhos esperados:** enxergar mês a mês o quanto sobra (ou não) e onde o dinheiro está concentrado, sem julgamento.

---

## 3. Escopo

### 3.1 Dentro do escopo (MVP)

1. Cadastro de renda mensal (uma ou mais fontes).
2. Cadastro de contas/despesas planejadas com valor, vencimento, categoria e recorrência.
3. Checklist mensal com apenas dois status: pago e pendente.
4. Cartões de crédito tratados no nível da fatura, com rateio macro opcional entre grupos.
5. Classificação de cada conta em Necessidades, Desejos ou Poupança/Investimento.
6. Painel 50-30-20 com barras de progresso por grupo (referência educativa, nunca restrição).
7. Virada de mês com geração automática das contas recorrentes.
8. Persistência local dos dados no dispositivo (offline-first).
9. Exportação como planilha (CSV) no formato da checklist.

### 3.2 Fora do escopo (MVP)

- Integração bancária / Open Finance.
- Registro de transações avulsas (extrato).
- Contas compartilhadas ou múltiplos usuários.
- Sincronização contínua entre dispositivos com fusão registro a registro. **O que entra no
  MVP** é login social (CE-06) e backup/restauração do banco inteiro por usuário, com o último
  backup substituindo o estado local — uma ação explícita, não uma sincronização automática.
- Notificações push (fica para a fase 2).
- Suporte a múltiplas moedas.

---

## 4. Metodologia 50-30-20

### 4.1 Definição

A regra 50-30-20 orienta que a renda líquida mensal seja dividida em: **50% para necessidades** (moradia, alimentação, transporte, saúde, contas essenciais), **30% para desejos** (lazer, assinaturas, compras não essenciais) e **20% para poupança e investimentos** (reserva de emergência, aportes, quitação acelerada de dívidas).

### 4.2 Adaptações no app

- **A metodologia é referência, não restrição.** O app compara o realizado com o ideal e apresenta a diferença de forma informativa. Ultrapassar um percentual nunca gera bloqueio, alerta agressivo ou tom de erro.
- Os percentuais são **configuráveis** (padrão 50-30-20), permitindo variações como 70-20-10 sem mudar a arquitetura.
- O cálculo é feito sobre a **renda líquida informada** pelo usuário (o app não calcula impostos).
- **Como uma conta entra na metodologia:** cada conta é classificada **diretamente em um dos três grupos** — Necessidade, Desejo ou Investimento — no momento do cadastro, sem camada intermediária de categorias. O app pode oferecer um grupo pré-selecionado sensato ao criar a conta, mas a escolha final é sempre do usuário, já que a fronteira entre necessidade e desejo é pessoal (academia, carro...).
- O grupo "Poupança" é tratado como uma "conta a pagar para si mesmo": o usuário cadastra o aporte planejado e o marca como pago quando efetivar, reforçando o hábito de *pay yourself first* — como incentivo, nunca como cobrança.

---

## 5. Requisitos funcionais

### Módulo A — Entradas (renda)

O modelo financeiro do app é de **entradas e saídas**: toda renda é uma entrada de dinheiro (recorrente ou pontual) e toda conta/despesa é uma saída. Não há tratamento especial para 13º, férias ou renda variável — são simplesmente entradas pontuais do mês em que ocorrem.

- **RF-01:** O usuário pode cadastrar entradas recorrentes (ex.: salário) com nome, valor líquido e dia de recebimento.
- **RF-02:** O usuário pode registrar uma entrada pontual em um mês específico (ex.: 13º, freelance, restituição), que entra no cálculo apenas daquele mês.
- **RF-03:** A renda do mês é a soma de todas as entradas do mês corrente (recorrentes + pontuais), sempre em valores líquidos, e é a base dos cálculos percentuais da metodologia.

### Módulo B — Contas e despesas planejadas

- **RF-04:** O usuário pode cadastrar uma conta com: nome, valor, dia de vencimento, grupo (Necessidade/Desejo/Investimento) e recorrência (fixa mensal ou pontual).
- **RF-05:** O usuário pode cadastrar contas de valor variável (ex.: energia), informando um valor estimado e ajustando o valor real no mês.
- **RF-06:** O usuário pode cadastrar uma despesa parcelada informando valor da parcela e número de parcelas; no ato do cadastro, o app gera **N contas mensais independentes**, uma para cada mês, com contador de parcela (ex.: 3/10).
- **RF-07:** O usuário pode editar, pausar ou excluir uma conta recorrente, escolhendo se a alteração vale só para o mês corrente ou para os próximos.

### Módulo C — Checklist mensal

- **RF-08:** O app exibe a lista de contas do mês corrente com apenas dois status: **pendente** ou **paga**, ordenada por vencimento (pendentes com vencimento mais próximo ou passado no topo).
- **RF-09:** O usuário pode marcar/desmarcar uma conta como paga com um toque, podendo ajustar o valor efetivamente pago no momento da marcação.
- **RF-10:** O vencimento é usado apenas como critério de ordenação e como informação exibida na linha da conta — não existe um terceiro estado "vencida", em nome da simplicidade e do tom não punitivo.
- **RF-11:** O usuário pode adicionar rapidamente uma despesa avulsa do mês (não recorrente) direto da checklist.

### Módulo D — Painel 50-30-20

- **RF-12:** O app exibe, para cada grupo, uma barra de progresso com: valor planejado, valor comprometido (soma das contas do grupo) e limite do grupo (percentual × renda).
- **RF-13:** Quando o valor comprometido de um grupo ultrapassa a referência, o app sinaliza de forma **informativa e neutra** (ex.: mudança sutil de cor e texto do tipo "Necessidades está em 68% da sua renda este mês"), sem tom de erro, alerta ou culpa.
- **RF-14:** O app exibe o "livre para gastar": renda − total comprometido no mês.
- **RF-15:** O usuário pode ajustar os percentuais da metodologia nas configurações, com validação de que a soma seja 100%.

### Módulo E — Ciclo mensal

- **RF-16:** Na virada do mês (ou no primeiro acesso do novo mês), o app gera a checklist a partir das contas recorrentes e das parcelas em aberto.
- **RF-17:** Contas pendentes ao fim do mês **permanecem pendentes no mês de origem** — em um mês fechado, "pendente" significa "não foi paga naquele mês". Nada é migrado nem duplicado. Na virada, o app pode exibir um resumo informativo do mês fechado (total pago, pendente e panorama dos grupos), sempre em tom neutro. Se o usuário ainda precisar quitar uma dessas contas, ele a cadastra como despesa avulsa do novo mês (RF-11).
- **RF-18:** O app mantém o histórico dos meses anteriores em modo somente leitura (consulta simples no MVP).

### Módulo F — Cartão de crédito

O cartão é tratado no nível da **fatura**, nunca da transação individual — sem microgerenciamento. Por ter comportamento próprio (valor sempre variável e subdividido entre grupos), é modelado como uma entidade distinta de conta comum.

- **RF-21:** O usuário pode cadastrar um ou mais cartões de crédito, cada um com nome e dia de vencimento; cada cartão passa a gerar uma fatura mensal.
- **RF-22:** Quando a fatura fecha, o usuário informa o valor total daquele mês e a marca como paga na checklist, ao lado das demais contas.
- **RF-23 (subdivisão entre grupos):** Ao informar o valor da fatura, o usuário divide-o entre os grupos da metodologia com valores aproximados de cabeça (ex.: R$ 2.000 → R$ 1.400 Necessidade + R$ 600 Desejo), sem itemizar transações. Essa subdivisão é o que mantém o painel 50-30-20 fiel mesmo quando quase tudo é pago no cartão.

### Módulo G — Configurações e dados

- **RF-19:** O usuário pode exportar seus dados como planilha (CSV, que abre no Excel e no Google Sheets) no formato da checklist mensal — espelhando a planilha manual que o app substitui — além de JSON para backup completo.
- **RF-20:** O usuário pode apagar todos os dados do app (com confirmação dupla).

---

## 6. Regras de negócio

- **RN-01:** O ciclo financeiro padrão é o mês-calendário (1 a 30/31). Evolução futura: ciclo personalizado iniciando no dia do salário.
- **RN-02:** O percentual de cada grupo é calculado sobre a **renda líquida** total do mês, definida como a soma de todas as entradas do mês (recorrentes + pontuais). O app não calcula impostos: o usuário sempre informa valores líquidos.
- **RN-03:** Uma despesa parcelada gera N contas mensais independentes no ato do cadastro, uma por mês de referência. Excluir uma parcela oferece a opção "excluir só esta" ou "esta e as futuras"; parcelas de meses já fechados nunca são alteradas.
- **RN-04:** Ao marcar uma conta como paga com valor diferente do planejado, o valor real substitui o planejado nos cálculos daquele mês, preservando o planejado nos meses futuros.
- **RN-05:** Cada mês é um recorte fechado: conta pendente ao fim do mês permanece pendente naquele mês (leitura: "não foi paga naquele mês") e **não rola para o mês seguinte**. A mesma lógica vale para parcelas — a parcela 3/10 pendente em julho fica pendente em julho; a parcela 4/10 de agosto segue normalmente.
- **RN-06:** Alterar os percentuais da metodologia afeta apenas o mês corrente e os futuros; o histórico preserva os percentuais vigentes em cada mês.
- **RN-07:** Cada conta é classificada diretamente em um dos três grupos, escolhido pelo usuário no cadastro e editável a qualquer momento. O app pode pré-selecionar um grupo como sugestão, mas nunca o impõe.
- **RN-08:** A subdivisão da fatura entre grupos (RF-23) deve somar exatamente o valor total da fatura. Enquanto a soma não bater, o app impede a conclusão de forma amigável (ex.: mostra o quanto ainda falta alocar). A subdivisão vale apenas para o mês da fatura.

---

## 7. Requisitos não funcionais

- **RNF-01 (Offline-first):** Todas as funcionalidades do MVP funcionam sem conexão; dados armazenados localmente (ex.: SQLite).
- **RNF-02 (Desempenho):** Abertura do app até a tela principal em menos de 2 segundos em aparelhos intermediários.
- **RNF-03 (Usabilidade):** Marcar uma conta como paga exige no máximo 2 toques a partir da tela inicial.
- **RNF-04 (Privacidade):** Nenhum dado financeiro sai do dispositivo sem uma ação explícita do usuário — exportar a planilha ou enviar o backup para a conta autenticada dele (CE-06). Sem coleta de analytics de valores e sem envio automático em segundo plano. O uso diário continua funcionando integralmente sem login e sem rede (RNF-01).
- **RNF-05 (Acessibilidade):** Contraste adequado, alvos de toque ≥ 44pt e suporte a leitores de tela nas telas principais.
- **RNF-06 (Qualidade de código):** Cobertura de testes unitários nas regras de negócio (cálculos, virada de mês, parcelas) — este é um objetivo explícito do portfólio.

---

## 8. Modelo de dados conceitual

- **Entrada** (id, nome, valorLiquido, tipo [recorrente | pontual], diaRecebimento?, mesReferencia?, ativa) — unifica salário, 13º, freelas e demais rendas.
- **Conta** (id, nome, grupo [necessidade | desejo | investimento], valorPlanejado, diaVencimento, recorrencia [fixa | pontual | parcelada], totalParcelas?, ativa) — classificação direta no grupo, sem camada de categoria.
- **OcorrenciaConta** (id, contaId, mesReferencia, valorPlanejado, valorPago?, dataPagamento?, status [pendente | paga], parcelaAtual?, removida) — apenas dois estados; em mês fechado, "pendente" significa "não foi paga naquele mês". Urgência de vencimento é apenas ordenação/exibição, nunca um estado. `removida` marca a ocorrência excluída "só deste mês" (RF-07): ela some da checklist mas continua gravada, senão a virada a recriaria no acesso seguinte.
- **Cartao** (id, nome, diaVencimento, ativa) — modelado à parte por ter comportamento próprio (fatura sempre variável, subdividida entre grupos).
- **FaturaCartao** (id, cartaoId, mesReferencia, valorTotal?, valorPago?, dataPagamento?, status [pendente | paga]) — a instância mensal da fatura, análoga a uma OcorrenciaConta mas em tabela própria.
- **RateioFatura** (id, faturaCartaoId, grupo [necessidade | desejo | investimento], valor) — subdivisão macro da fatura entre grupos (RF-23); uma fatura tem uma ou mais linhas de rateio que somam o valor total.
- **ConfiguracaoMetodologia** (mesVigenciaInicial, percentualNecessidades, percentualDesejos, percentualPoupanca)
- **FechamentoMensal** (mesReferencia, rendaTotal, totalPorGrupo, snapshotPercentuais) — gerado na virada, alimenta o histórico.

A separação entre **Conta** (o modelo/recorrência) e **OcorrenciaConta** (a instância do mês) concretiza a decisão de "separar tudo por mês": cada mês tem suas próprias ocorrências independentes — inclusive parcelas —, mas elas continuam agrupadas sob a Conta de origem, o que permite editar ou excluir "esta e as futuras" em lote sem tocar nos meses já fechados.

## 9. Fluxos e telas principais

1. **Onboarding (primeira execução):** informar renda → escolher metodologia (padrão 50-30-20) → cadastrar 3 a 5 contas principais → chegar na tela inicial já funcional.
2. **Tela inicial — "Meu mês":** painel 50-30-20 no topo (3 barras + livre para gastar) e checklist de contas abaixo, ordenada por vencimento. É a única tela obrigatória do dia a dia.
3. **Detalhe/edição de conta:** formulário com nome, valor, vencimento, categoria, grupo e recorrência.
4. **Virada de mês:** no primeiro acesso do novo mês, o app gera as ocorrências do mês e exibe um resumo informativo do mês fechado (pago, não pago e aderência aos grupos) — sem exigir decisões do usuário.
5. **Histórico:** não é uma tela própria — é o seletor de mês das abas Contas e Gráfico exibindo um mês fechado em modo somente leitura (RF-18), com o resumo por grupo vindo do `FechamentoMensal`. Um mês fechado pode ser **reaberto** para correção: a reabertura é local, reversível e restrita às ocorrências e faturas que já existem naquele mês — nunca cria lançamentos novos nem altera os modelos recorrentes (RN-05). Ao concluir a edição, um novo retrato é gravado.
6. **Configurações:** rendas, percentuais, exportação e limpeza de dados.

## 10. Roadmap pós-MVP

- **Fase 2:** notificações de vencimento; ciclo personalizado pelo dia do salário; metas de poupança com progresso; **sincronização da planilha exportada com o Google Drive** (aproveitando a experiência do autor com as APIs do Google).
- **Fase 3:** outras metodologias (70-20-10, pay yourself first); comparativo entre meses com gráficos; widgets de tela inicial (iOS); parcelas de cartão cadastradas como contas informativas vinculadas à fatura.
- **Fase 4 (exploratória):** backup em nuvem opcional; insights educativos simples ("sua conta de energia subiu 20% em relação à média"), sempre em tom neutro.

## 11. Métricas de sucesso

Como projeto de estudo, as métricas servem para simular a visão de produto:

- **Ativação:** % de usuários que completam o onboarding e cadastram ≥ 3 contas.
- **Hábito:** % de contas marcadas como pagas dentro do mês (proxy de uso real).
- **Retenção mensal:** usuário retorna e realiza a virada de mês por 3 meses consecutivos.
- **Aderência à metodologia:** % de meses em que o usuário fecha dentro dos limites dos 3 grupos.

## 12. Riscos e decisões em aberto

| # | Risco / decisão | Direção sugerida |
|---|---|---|
| 1 | Mês-calendário vs. ciclo do salário | **Decidido:** MVP usa mês-calendário (1 a 30/31). Ciclo iniciando no dia do salário fica para a fase 2 |
| 2 | Gastos variáveis do dia a dia (mercado, lazer) não são "contas" | **Decidido:** também são contas — a critério da organização do usuário. Uma conta não precisa ser recorrente; pode ser pontual do mês. O fluxo de cartão (RF-21 a 23) cobre o caso de tudo cair na fatura |
| 3 | Renda variável em relação à referência 50-30-20 | **Decidido:** não é um problema, é uma funcionalidade. A variação da renda reflete a instabilidade financeira real e serve de alerta — um mês em que as necessidades consomem 90% da renda é justamente a informação que o app existe para revelar. Coerente com o princípio educativo (1.5) |
| 4 | Usuário abandonar por excesso de cadastro inicial | Onboarding limitado a 3–5 contas com sugestões prontas |
| 5 | Escopo crescer e o projeto de estudo não ser concluído | MVP fechado nas seções 3.1 e 5; tudo mais é fase futura |

## 13. Definição técnica

- **Framework:** Flutter (decisão tomada), com publicação inicial no **Android**, distribuído como APK/AAB por link público no GitHub Releases (CE-03/CE-04) — o desenvolvimento é feito no Windows e não depende de conta Apple Developer para entregar. **iOS/App Store** fica para fase seguinte, quando o autor usar o Mac; exige conta Apple Developer (US$ 99/ano) e revisão da Apple.
- **Persistência local:** SQLite via **drift** (type-safe, com migrações e boa testabilidade) — alinhado ao offline-first (RNF-01). Uma conta tem no máximo uma ocorrência por mês (e um cartão, uma fatura), garantido por restrição de unicidade no banco: é o que torna a virada do mês idempotente (RF-16/RN-05).
- **Estado:** **Riverpod**, com os repositórios expostos por interface (o domínio declara o contrato, a camada de dados implementa). Nos testes o *test double* é o próprio banco em memória, não um fake: o SQL faz parte da regra testada.
- **Navegação:** **exatamente 3 menus fixos** (Contas | Gráfico | Configurações). Formulários e detalhes abrem sobrepostos com `Navigator` nativo, folhas modais e diálogos — nunca viram um 4º menu. Sem pacote de rotas (`go_router`), por simplicidade (CE-02 é atendido pelo `Navigator`).
- **Arquitetura:** camadas UI → casos de uso → repositórios → persistência, com a lógica de domínio (cálculos da metodologia, geração do mês, parcelas, rateio de fatura) isolada da UI e coberta por testes unitários (RNF-06). Essa separação rende bom material de README para o portfólio.
- **Exportação:** geração de CSV no dispositivo; na fase 2, upload para o Google Drive via API oficial.

## 14. Critérios obrigatórios de entrega

Requisitos mínimos que a entrega do projeto deve cumprir (checklist de avaliação):

- **CE-01 (Múltiplas páginas):** o app deve ter mais de uma página/tela.
- **CE-02 (Navegação e roteamento):** deve haver conexão entre as páginas com roteamento estruturado (ex.: `Navigator`/rotas nomeadas ou um pacote de rotas como `go_router`).
- **CE-03 (Distribuição):** o app deve estar publicado em uma loja de aplicativos ou, no mínimo, disponibilizar um link de download público.
- **CE-04 (Plataforma mobile):** deve funcionar em pelo menos uma plataforma dentre Android, iOS ou Web.
- **CE-05 (Banco de dados):** deve usar banco de dados local ou online (servidor livre para escolha).
- **CE-06 (Autenticação):** deve oferecer login via rede social ou similar (ex.: Google, Apple, e-mail/senha).
