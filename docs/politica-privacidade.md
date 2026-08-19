# Política de privacidade

O Play exige **uma URL pública** — não um PDF anexado, não um texto dentro do app.
Precisa estar no ar antes do envio e continuar no ar depois.

O plano é uma página estática única, no seu domínio, versionada aqui no repositório e
deployada sozinha.

## Por que só faz sentido depois do M9

Hoje o app **não tem rede**: zero permissões no manifesto, tudo em SQLite local, nenhum
analytics. Uma política escrita agora diria "não coletamos nada" e ficaria falsa no dia em que
o Firebase Auth entrar.

Escreva depois de o M9 estar implementado, e escreva sobre o que o código faz — não sobre o
que o modelo de política genérica sugere. O **formulário de segurança de dados** do Play
Console é preenchido à parte e **precisa bater** com este texto; divergência entre os dois é
motivo de suspensão, não só de rejeição.

## Onde o arquivo mora

```
docs/privacidade/index.html      # a página, autossuficiente (mesmo padrão de assets/marca/identidade.html)
```

Autossuficiente de propósito: sem CDN, sem fonte externa, sem script de terceiros. Uma
política de privacidade que carrega recurso de terceiro contradiz o próprio texto.

Reaproveite os tokens de `assets/marca/identidade.html` (paleta, escala tipográfica, blocos
claro/escuro) — a página é a primeira coisa que alguém vê fora do app, e vale parecer parte
do mesmo produto.

**Bilíngue**, como o app: pt-BR e en-US na mesma página, com âncora para cada
(`#pt` / `#en`), ou dois arquivos irmãos. Uma página só é mais simples de manter e de linkar.

## O que a página tem que responder

Escrito a partir do que o código faz — confira cada linha contra o `lib/` antes de publicar.

### Quem é o controlador
Nome e e-mail de contato. Precisa ser um canal que você realmente lê: é por ele que chegam
pedidos de exclusão e é ele que a Apple usa para te achar.

### O que fica só no aparelho
Contas, ocorrências, rendas, cartões, faturas, percentuais e fechamentos mensais — tudo em
SQLite local (`drift`). Sem login, **nada** sai do aparelho. Isso é o RNF-01/RNF-04 e é
verdade hoje.

### O que sai do aparelho, e só por ação explícita

| Dado | Quando | Para onde |
|---|---|---|
| Identificador da conta (UID), e-mail e nome | Ao entrar com Google ou Apple | Firebase Authentication |
| Backup: o banco inteiro serializado em JSON | Ao enviar o backup, ou ao confirmar no logout | Firebase Realtime Database, em `backups/{uid}` |
| CSV/JSON exportado | Ao tocar em exportar | Para onde **você** escolher no menu de compartilhar |

Deixe explícito que **não há envio automático em segundo plano** e que o uso diário funciona
integralmente sem login e sem rede.

### O que NÃO acontece
Sem analytics, sem publicidade, sem rastreadores de terceiros, sem venda ou compartilhamento
de dados, sem conexão com bancos ou instituições financeiras. O app não lê SMS, não lê
notificações e não importa extrato.

Vale ser específico aqui: "não conectamos ao seu banco" é exatamente o que quem instala um app
de finanças quer saber primeiro.

### Retenção e exclusão
- O backup fica em `backups/{uid}` até ser sobrescrito (*last-wins*) ou excluído.
- **Excluir a conta dentro do app** remove `backups/{uid}` e a conta no Firebase Auth.
  Diga que existe e onde fica.
- **Seção própria, com âncora, para a exclusão de conta.** O Play exige uma URL pública onde
  alguém que **já desinstalou** consiga pedir a exclusão — o caminho dentro do app não basta.
  Precisa dizer o que é apagado (conta, backup na nuvem), o que não é (o banco local, que sai
  junto com o app) e como pedir. Sugestão de âncora: `#exclusao-de-conta`, porque é ela que
  vai colada no campo do Play Console.
- **Desinstalar o app apaga o banco local.** Quem desinstalar sem backup na nuvem perde os
  dados. Isso precisa estar escrito; é a consequência que mais surpreende usuário.
  O app usa `allowBackup="false"`, então o Android também não guarda cópia — é verdade
  verificável no manifesto.
  **Se um dia sair no iOS**, reconferir: o diretório do banco pode entrar no backup do iCloud
  por padrão, e aí a frase acima fica imprecisa.

### Direitos do titular (LGPD)
Acesso, correção, portabilidade e eliminação. Na prática: os dados já estão no aparelho da
pessoa, a exportação em CSV/JSON **é** a portabilidade (RF-19), e a exclusão está no app.
Diga isso em vez de repetir os artigos da lei — é mais honesto e mais útil.

### Menores e transferência internacional
O app não se destina a menores de 13 anos. Os servidores do Firebase ficam fora do Brasil;
mencione a transferência internacional, que a LGPD exige informar.

### Data da última atualização
No topo. Toda revisão muda essa data.

## Deploy

Só esta pasta vai para o domínio — o resto do repositório continua local. Qualquer host
estático serve (GitHub Pages a partir de `docs/`, Cloudflare Pages, Netlify).

Sugestão de URL: `https://gabrielkozuki.com.br/conta-em-dia/privacidade`.

Depois de publicar:

1. Cole a URL da política no **Play Console → Painel de políticas**, e a âncora
   `#exclusao-de-conta` no campo de exclusão de conta.
2. Preencha o **formulário de segurança de dados** relendo esta página, não de memória.
3. Coloque um link para ela dentro do app, em Configurações. O Play exige um link acessível na
   ficha da loja, e é também o primeiro lugar onde a pessoa procura.
4. Confirme que a URL responde **sem login e sem redirecionamento** — a revisão abre direto.

## Ressalva

O roteiro acima descreve fielmente o que o app faz, mas não é aconselhamento jurídico.
Se o projeto deixar de ser portfólio e passar a ter usuários reais em volume, vale uma
revisão por alguém da área.
