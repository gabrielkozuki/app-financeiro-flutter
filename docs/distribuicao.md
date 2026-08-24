# Distribuição — Google Play Store

**Destino principal, decidido em 19/08/2026, por custo.** O motivo é direto:

| | Google Play | App Store |
|---|---|---|
| Conta de desenvolvedor | **US$ 25, taxa única** | US$ 99 por **ano**, recorrente |
| Hardware | Qualquer um | Mac com Xcode |
| Revisão | Automatizada + humana | Humana |

**A App Store fica para depois**, se e quando a anuidade se justificar. Nada do trabalho de
iOS foi perdido: `Info.plist`, `AppIcon.appiconset`, `LaunchImage` e o storyboard já estão
prontos, e o projeto segue compilando para iOS. Retomar é ter o Mac, não refazer trabalho.

**APK avulso por GitHub Releases segue descartado.** Uma loja já cumpre CE-03; um segundo
canal para o mesmo binário multiplica manutenção sem multiplicar alcance.

## Comece pelo prazo, não pelo build

Conta **pessoal** criada depois de 13/11/2023 precisa passar por um **teste fechado com 12
testadores por 14 dias corridos** antes de poder pedir acesso à produção. Verificado em
19/08/2026 na documentação do Play.

**14 dias é o piso de uma etapa, não do total:**

| Etapa | Prazo |
|---|---|
| Criar conta + verificação de identidade | Alguns dias, variável |
| Teste fechado | 14 dias corridos, 12 testadores |
| Solicitar acesso à produção | Revisão de até 7 dias |
| Revisão do app | Mais alguns dias |

Na prática, **~3 semanas no mínimo**.

### Três detalhes que custam a janela inteira

- **"Opted in" = aceitou o convite E instalou** com a conta Google correspondente. Convidado
  que não instalou não conta para os 12.
- **Os 14 dias são contínuos, com os 12 simultaneamente ativos.** Um testador que desinstala
  no dia 10 pode zerar a contagem. **Convide mais de 12** — a folga é barata, reiniciar não é.
- **O relógio só começa quando o 12º instalar**, não quando você abre o teste.

### Não existe atalho por outra faixa

O teste fechado é a **única** faixa que o Google aceita como prova de teste por usuários reais:

| Faixa | Serve como prova? |
|---|---|
| Interna (até 100 testadores, sem revisão) | Não |
| **Fechada** | **Sim** — é a exigida |
| Aberta (link público) | Não — e **só fica disponível depois** do acesso à produção |

A faixa aberta parece a saída óbvia e não é: ela vem *depois*, não antes. Consequência para o
CE-03: **não há link público de Play antes das ~3 semanas.**

### As duas isenções

1. **Conta de organização** — publica direto em produção. Exige número **D-U-N-S**, que
   pressupõe pessoa jurídica. Para portfólio pessoal raramente compensa; se já houver CNPJ e
   fizer sentido publicar por ele, corta as 3 semanas.
2. **Conta pessoal criada antes de 13/11/2023** — isenta pela data. **Conferir primeiro:** uma
   conta antiga, de um app publicado há anos ou de uma tentativa abandonada, elimina a
   exigência inteira.

### Por que isso é o passo 3 e não o último

Os 14 dias **não se somam ao desenvolvimento**. Abra o teste fechado assim que houver um build
assinado, mesmo com o M9 incompleto — a espera corre em paralelo. Deixar para o fim é o que
transforma 14 dias de relógio em 14 dias de atraso.

> Reconferir no Play Console antes de começar: o requisito já foi **20 testadores** e caiu para
> 12 em 11/12/2024. Guia que cite 20 está desatualizado — e pode mudar de novo.

## Pré-requisitos

| Item | Situação |
|---|---|
| Conta Google Play Developer | US$ 25, uma vez. Verificação de identidade leva alguns dias |
| Keystore de upload | Ver [`assinar-release.md`](assinar-release.md) — **está no caminho crítico** |
| M9 completo | Login, backup e exclusão de conta. Ver [`m9-auth-backup.md`](m9-auth-backup.md) |
| Política de privacidade | URL pública. Ver [`politica-privacidade.md`](politica-privacidade.md) |
| URL de exclusão de conta | Exigência específica do Play, **fora do app**. Ver abaixo |
| Formulário de segurança de dados | No console, precisa bater com a política |
| Classificação indicativa | Questionário no console |
| Ficha da loja | Descrição, ícone 512×512, gráfico de destaque 1024×500, capturas |
| Teste fechado | 12 testadores / 14 dias — **comece cedo** |

## O que o Play exige e a Apple não

Duas coisas que não estavam no roteiro anterior:

- **URL pública de exclusão de conta.** A Apple exige que dê para excluir a conta *dentro do
  app* (diretriz 5.1.1(v)); o Play exige isso **e** um endereço na web onde alguém que já
  desinstalou possa pedir a exclusão. Pode ser uma seção da mesma página da política, desde
  que explique o que é apagado e como pedir.
- **Formulário de segurança de dados.** Equivalente às *nutrition labels*, mas com perguntas
  próprias, incluindo se o dado é criptografado em trânsito e se o usuário pode pedir
  exclusão. Divergir da política é motivo de suspensão.

Em compensação, **"Entrar com a Apple" deixa de ser obrigatório** — a diretriz 4.8 é da Apple.
Mesmo assim ele **continua no layout, acima do Google**: o custo de manter é zero, e reordenar
depois, quando a App Store voltar ao mapa, seria retrabalho e risco de rejeição.

## O build

```bash
flutter build appbundle --release
```

**AAB, não APK.** O Play exige App Bundle para apps novos, e é ele que monta o pacote por
aparelho — por isso não existe `--split-per-abi` aqui.

**O arquivo enviado tem ~57 MB e isso é normal**: o AAB carrega as três ABIs mais os recursos
de todas as densidades e idiomas, para o Play escolher. O que o usuário baixa é a fatia do
aparelho dele, ~20 MB. Não tente reduzir o AAB — o número que importa é o "tamanho do
download" que o console mostra depois do envio.

O `targetSdk 36` já atende a exigência atual do Play (≥35) e o `minSdk 24` cobre praticamente
todo aparelho em uso.

## Play App Signing

**Ative.** É o padrão para apps novos e muda a natureza do risco do keystore:

- Você assina o AAB com a **chave de upload** e envia.
- O Google re-assina com a **chave de assinatura do app**, que fica com ele.
- Perder a chave de upload é **recuperável** — dá para pedir a substituição pelo console.

Isso inverte o alerta que valia para distribuição fora de loja, onde perder o keystore
significava nunca mais atualizar o app. Guardar bem continua valendo; deixar de ser
catastrófico, não.

**A pegadinha que quebra o login em produção:** com Play App Signing existem **dois** SHA-1.
O do seu keystore de upload e o da chave que o Google gerou. O Google Sign-In em produção usa
o **da chave de assinatura do app**, que só aparece em **Play Console → Configurar →
Integridade do app**. Registrar só o de upload faz o login funcionar em desenvolvimento e
falhar em silêncio para quem baixar da loja. Ver o passo 1.6 de
[`m9-auth-backup.md`](m9-auth-backup.md).

## Estado de iOS (congelado, não perdido)

Preparado até onde o Windows alcança, e assim permanece até haver Mac:

| Item | Hoje |
|---|---|
| `CFBundleDisplayName` / `CFBundleName` | "Conta em Dia" ✔ |
| Bundle identifier | `br.com.gabrielkozuki.contaemdia` ✔ |
| `AppIcon.appiconset` | 15 arquivos (20 a 1024 px), em RGB ✔ |
| `LaunchImage.imageset` | A marca em 128/256/384 px ✔ |
| `LaunchScreen.storyboard` | Fundo `#F7F9F9` ✔ |
| Launch screen no modo escuro | Pendente — exige Xcode |
| `flutterfire configure` com iOS | Pendente |

**Ícone de iOS não pode ter canal alfa** — é o inverso do adaptativo do Android, que exige
transparência na camada de frente. Por isso `gerar_ios()` faz `convert('RGB')`.

## Versionamento

`pubspec.yaml` → `version: 1.0.0+1`. O `+1` vira `versionCode`: **precisa aumentar a cada
envio**, mesmo que o `1.0.0` não mude, e inclusive entre builds do teste fechado. O Play
recusa um `versionCode` já usado, e o número não pode ser reaproveitado nem depois de
descartar o build.

## Checklist final

- [ ] Conta Google Play Developer criada e identidade verificada
- [ ] Keystore de upload gerado, `key.properties` e `build.gradle.kts` ajustados
- [ ] Teste fechado aberto e os 14 dias **em andamento**
- [ ] M9 fechado, sem nada `enabled: false` visível
- [ ] SHA-1 **da chave de assinatura do app** (não o de upload) registrado no Firebase
- [ ] Política de privacidade publicada, com a seção de exclusão de conta
- [ ] Formulário de segurança de dados batendo com a política
- [ ] Classificação indicativa respondida
- [ ] Ficha da loja: descrição, capturas, gráfico de destaque
- [ ] `version` incrementada
- [ ] `flutter build appbundle --release` e envio
