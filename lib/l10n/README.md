# Traduções (M8)

`app_pt.arb` é o template (pt-BR, idioma de origem); `app_en.arb` é a tradução.
Depois de editar qualquer ARB, rode `flutter gen-l10n` — os arquivos gerados
ficam neste mesmo diretório e **não devem ser editados à mão**.

Só o **texto visível ao usuário** é localizado. Código, comentários, nomes de
variáveis, documentos do projeto e mensagens de `debugPrint` seguem em pt-BR.

## Convenções

- **Chaves em pt-BR camelCase**, com prefixo do contexto: `contaFormTituloNova`,
  `graficoLivreParaGastar`, `erroTituloPadrao`. Consistente com o resto do código.
- No `build`: `final l10n = AppLocalizations.of(context);` no topo, depois
  `l10n.chave`. Fora do `build`, receba o `BuildContext` por parâmetro.
- Valor com interpolação vira *placeholder* no ARB, nunca concatenação:
  `"contaMarcarPaga": "Marcar {nome} como paga"` com o bloco `@contaMarcarPaga`
  declarando o placeholder.
- Toda chave nova precisa existir nos **dois** ARB. Faltar no `en` gera aviso e
  cai no pt em tempo de execução.

## Glossário — obrigatório

O erro que estraga a versão em inglês é traduzir o mesmo termo de duas formas em
telas diferentes. Este mapeamento é fechado:

| pt-BR | en-US | Observação |
|---|---|---|
| conta (a despesa) | **bill** | NUNCA "account" — não é conta bancária |
| conta (do usuário, login) | **account** | Só na tela de login/backup |
| ocorrência | **monthly bill** | A instância do mês; evitar "occurrence" |
| fatura (de cartão) | **statement** | O valor fechado do mês do cartão |
| cartão | **card** | |
| rateio | **split** | A subdivisão da fatura entre grupos |
| grupo | **group** | |
| Necessidade / Desejo / Investimento | **Needs / Wants / Savings** | São os termos canônicos do método 50-30-20 em inglês — não invente outros |
| renda / entrada | **income** | |
| recorrente / pontual | **recurring / one-time** | |
| parcelada / parcela | **installments / installment** | |
| vencimento | **due date** | |
| planejado | **planned** | |
| pago / pendente | **paid / pending** | |
| comprometido | **committed** | |
| livre para gastar | **left to spend** | |
| virada de mês | **month rollover** | |
| mês fechado / reabrir mês | **closed month / reopen month** | |
| percentuais / metodologia | **percentages / method** | |
| apagar todos os dados | **delete all data** | |

## O nome do app

`appTitulo` **não é tradução literal**: cada idioma escolhe um nome que a busca
do launcher encontre — "Conta em Dia" (busca por *conta*/*contas*) e "Bills on
Track" (busca por *bill*/*bills*). Não "traduza" um para o outro.

## Tom

O app é **educativo, nunca punitivo** (RF-13 e princípio 1.5.1). Ao ultrapassar
um grupo, o inglês também deve ser neutro e informativo — nada de "over budget!",
"warning", "you overspent". Prefira construções como "108% of your income".
