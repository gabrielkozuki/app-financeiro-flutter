# Minhas Finanças

App mobile de finanças pessoais que funciona como uma **checklist mensal de contas** combinada
com um **painel de direcionamento 50-30-20**. Responde, em uma tela, a duas perguntas: *"já
paguei o que devia?"* e *"estou gastando dentro do que planejei?"*.

Não é um registrador de transações nem se conecta a bancos: trabalha no nível de contas e
envelopes mensais, priorizando o hábito de conferência em vez do controle microscópico. A
referência 50-30-20 é **educativa, nunca punitiva** — mostra onde o dinheiro está indo, sem
bloquear nem culpar.

Projeto de estudo/portfólio em Flutter, offline-first, com as regras de negócio isoladas da UI
e cobertas por testes.

## O que faz

Onboarding de primeira execução, checklist mensal com dois estados (pendente/paga), contas
fixas, pontuais e parceladas, rendas recorrentes e pontuais, cartões de crédito no nível da
fatura com rateio entre grupos, virada de mês automática, histórico congelado por mês e
exportação em CSV e JSON.

## Arquitetura

```
lib/
  core/      # tema, formatadores, providers Riverpod
  domain/    # entidades e casos de uso puros (metodologia, virada, parcelas, rateio)
  data/      # drift (SQLite): tabelas, repositórios, exportação
  features/  # UI: shell, onboarding, contas, gráfico, config, cartão, entradas
```

Estado com **Riverpod**, persistência local em **SQLite via drift** (fonte de verdade) e
navegação por `Navigator` sobre uma barra de **3 menus fixos** — formulários e detalhes abrem
sobrepostos. O domínio não depende de Flutter, o que o torna testável de forma direta.

## Rodando

```bash
flutter pub get
dart run build_runner build   # gera o código do drift
flutter run                   # Android
flutter test                  # regras de negócio e persistência
```

## Status

MVP funcional rodando offline. Em andamento: autenticação e backup na nuvem com Firebase, e a
distribuição do APK — ver `docs/configurar-firebase.md`.
