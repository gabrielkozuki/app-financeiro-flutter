# Distribuição — App Store

**Destino único, decidido em 14/08/2026.** Sem Play Store e sem APK por GitHub Releases: o app
é um produto só, e dois canais para o mesmo binário multiplicam manutenção sem multiplicar
alcance.

O projeto **continua compilando e sendo testado no Android** — `integration_test/` roda em
emulador Android e é assim que os fluxos ponta a ponta são verificados. O que mudou é o
destino, não o alvo de build. Se um dia a decisão voltar atrás, o caminho Android está
preservado em [`assinar-release.md`](assinar-release.md).

**É o último passo do projeto**, por decisão: só depois do M9. Publicar antes significa subir
um app com "Entrar" desabilitado, o que reprova na diretriz 2.1 (*App Completeness*) e deixa o
CE-06 em aberto.

## O que só existe no Mac

Nada disto tem substituto no Windows, nem em VM (a licença do macOS não permite):

- `flutter build ipa` e `pod install`
- Rodar em simulador ou aparelho
- Assinar com certificado Apple
- Enviar ao App Store Connect (via Xcode ou Transporter)

O que **não** precisa de Mac já foi feito — ver "Estado de iOS" abaixo.

## Pré-requisitos

| Item | Situação |
|---|---|
| Mac com Xcode | — |
| Apple Developer Program | US$ 99/**ano**, recorrente. Sem isso não há envio |
| M9 completo | Login, backup e exclusão de conta. Ver [`m9-auth-backup.md`](m9-auth-backup.md) |
| Login com Apple | Diretriz 4.8, obrigatório porque há login Google. Faz parte do M9 |
| Excluir conta dentro do app | Diretriz 5.1.1(v). Faz parte do M9 |
| Política de privacidade | URL pública. Ver [`politica-privacidade.md`](politica-privacidade.md) |
| Nutrition labels | Formulário no App Store Connect, separado da política e precisa bater com ela |
| Nada em estado "em breve" | Diretriz 2.1. Hoje `conta_backup_page.dart` tem dois itens `enabled: false` |
| Capturas de tela | Por tamanho de tela exigido pelo App Store Connect |

## Diretrizes que este app toca de perto

- **2.1 — App Completeness.** Funcionalidade visível que não funciona é rejeição. Os dois
  `ListTile` de login desabilitados são exatamente o caso, e é por isso que a publicação vem
  depois do M9.
- **4.8 — Login Services.** Havendo login de terceiros (Google), é obrigatório oferecer
  alternativa equivalente e com privacidade. O "Entrar com a Apple" já está posicionado acima
  do Google no layout por causa disso — **não reordene**.
- **5.1.1(v) — Account Deletion.** Precisa ser possível excluir a conta **dentro do app**, não
  por e-mail de suporte. Remove `backups/{uid}` e a conta no Auth.
- **5.1.1 — Data Collection.** As nutrition labels precisam bater com a política. O app não
  coleta analytics de valores; o que sai do aparelho é o backup, por ação explícita.

## Estado de iOS

A preparação que não depende de Xcode está **feita** — plist, catálogo de assets e storyboard
são texto e PNG, editáveis em qualquer sistema:

| Item | Hoje |
|---|---|
| `CFBundleDisplayName` | "Conta em Dia" ✔ |
| `CFBundleName` | "Conta em Dia" ✔ |
| Bundle identifier no `project.pbxproj` | `br.com.gabrielkozuki.contaemdia` ✔ |
| `AppIcon.appiconset` | 15 arquivos (20 a 1024 px) gerados por `gerar_icone.py`, em RGB ✔ |
| `LaunchImage.imageset` | A marca em 128/256/384 px ✔ |
| `LaunchScreen.storyboard` | Fundo `#F7F9F9`, a mesma superfície do app ✔ |

**Ícone de iOS não pode ter canal alfa** — o envio é recusado. É o inverso do adaptativo do
Android, que exige transparência na camada de frente; por isso `gerar_ios()` faz
`convert('RGB')`. Também não arredonde os cantos: o sistema aplica a máscara, e um PNG já
arredondado fica com halo.

### Pendências de iOS que exigem o Mac

- **Launch screen no modo escuro.** No Android isso saiu com `drawable-night-v21/`; no iOS a
  cor de fundo mora no storyboard, que não acompanha o tema sozinho. O caminho é um *Color Set*
  no catálogo (`LaunchBackground.colorset`, com variante `luminosity: dark`) referenciado por
  nome no storyboard, mais variantes escuras na `LaunchImage.imageset`. Ficou para o Mac de
  propósito: é edição de arquivo do Xcode que não dá para validar sem abrir o Xcode, e um
  storyboard malformado quebra o build sem dar erro de lint antes.
- **Conferir o ícone no simulador.** A máscara do iOS corta mais que a do Android; se ficar
  apertado, o ajuste é o parâmetro `escala` do gerador.
- **Firebase no iOS.** O `flutterfire configure` precisa ser rodado marcando iOS, gerando
  `GoogleService-Info.plist`. O Google Sign-In no iOS usa *URL scheme* com o reversed client ID
  no `Info.plist` — mecanismo diferente do SHA-1 do Android.
- **`sign_in_with_apple`** só entra quando houver conta paga no Apple Developer Program.

## Versionamento

`pubspec.yaml` → `version: 1.0.0+1`. O `+1` vira `CFBundleVersion`: **precisa aumentar a cada
envio**, mesmo que o `1.0.0` não mude. A Apple recusa um build com número já usado — inclusive
builds rejeitados na revisão consomem o número.

## Checklist final

- [ ] M9 fechado, sem nada `enabled: false` visível
- [ ] Mac com Xcode e conta no Apple Developer Program ativa
- [ ] `flutterfire configure` rodado com iOS marcado
- [ ] Launch screen com variante escura
- [ ] Ícone conferido no simulador
- [ ] Política de privacidade publicada e a URL acessível sem login
- [ ] Nutrition labels preenchidas, batendo com a política
- [ ] Capturas de tela nos tamanhos exigidos
- [ ] `version` incrementada
- [ ] `flutter build ipa` e envio pelo Xcode/Transporter
