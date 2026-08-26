# Próximas versões

Ideias e dívidas conhecidas, registradas **depois** de a v1.0.0 entrar em teste fechado
(25/08/2026). Nada aqui bloqueia a publicação — é o que vem depois.

Cada item diz o **porquê**, não só o quê: sem isso, daqui a três meses a lista vira um monte
de tarefas sem contexto e ninguém sabe quais ainda fazem sentido.

---

## Do uso real

### Adicionar contas próprias no onboarding

**Sugerido em 25/08/2026, durante o teste fechado.**

Hoje `_sugestoes()` em `onboarding_page.dart` oferece 6 chips fixos — Aluguel, Internet,
Energia, Mercado, Academia e Reserva. Tocar num deles cria a conta com nome, grupo e dia
sugeridos. **Não há caminho para uma conta fora dessa lista.**

Quem tem "Financiamento do carro", "Plano de saúde" ou "Pensão" como maior despesa termina o
onboarding sem ela e precisa descobrir sozinho que dá para adicionar depois, na aba Contas.

**A tensão de desenho, que a implementação precisa respeitar:** o onboarding existe para
*reduzir* atrito no cadastro inicial (risco #4 da seção 12 dos requisitos). Abrir o
`conta_form` completo ali dentro devolveria exatamente o atrito que os chips removem — o
formulário tem grupo, recorrência, parcelas e dia de vencimento.

O caminho provável é um chip **"+ Outra"** que abre um campo mínimo: nome e valor, herdando
grupo `necessidade` e dia sugerido, editável depois. A pessoa está montando uma lista, não
cadastrando um registro completo.

---

## Dívidas conhecidas

Itens que apareceram durante o desenvolvimento e foram deixados de propósito.

### RNF-05 nunca foi verificado por inteiro

Contraste (≥4,5:1) e alvo de toque (≥44dp) foram **medidos**. O terceiro requisito —
**suporte a leitor de tela** — nunca foi testado. Há 14 usos de `Semantics`/`semanticLabel`
no `lib/`, mas ninguém passou o TalkBack pelo app.

O emulador tem TalkBack e a suíte `integration_test/` já roda nele. É barato agora e caro
depois de haver usuários.

### RF-12 está incompleto

O requisito pede, por grupo: valor planejado, comprometido **e limite em R$**. O limite é
calculado em `calcular_metodologia.dart` e **nunca exibido** — a linha do grupo mostra
comprometido, percentual realizado e meta em %.

Registrado na tabela de divergências do `plano-mvp.md` desde o M7, sem decisão.

### Campos gravados e nunca lidos

- **`dataPagamento`** em `OcorrenciasConta`: gravado ao marcar como paga, nunca consultado.
  Ou vira funcionalidade (histórico de quando cada conta foi paga) ou sai do esquema.
- **`Entrada.ativa`**: existe na tabela, nunca é alternado pela UI.

Ambos são inofensivos hoje. Depois de publicado, remover coluna exige `onUpgrade` data-safe —
o custo de decidir sobe.

### Moeda fixa em Real

`core/format/money.dart` crava `locale: 'pt_BR'` e o símbolo `R$`, independentemente do idioma
do aparelho. A interface está traduzida para en-US, mas os valores continuam em Real com
separadores brasileiros.

Coerente enquanto a distribuição for só Brasil — **decisão registrada**, não descuido. Voltaria
a importar se a ficha da loja fosse publicada em outros países.

---

## Regime novo depois de publicar

Um lembrete que vale mais que qualquer item acima:

**O banco deixou de ter versão única.** Enquanto o app estava em desenvolvimento, mudar tabela
significava desinstalar o app de teste (`schemaVersion = 1`, sem `onUpgrade`). A partir da
primeira versão nas mãos de testadores existem bancos reais — toda alteração de esquema agora
exige subir a versão e escrever uma migração data-safe.

Ver o invariante 4 no `CLAUDE.md`.
