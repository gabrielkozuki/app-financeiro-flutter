# Distribuição

**Último passo do projeto**, por decisão: só depois do M9 fechado. Publicar antes significaria
subir um app com "Entrar" desabilitado, o que reprova na diretriz 2.1 da App Store (*App
Completeness*) e deixa o CE-06 em aberto.

Pré-requisito absoluto: [`assinar-release.md`](assinar-release.md). Nada aqui funciona com o
APK assinado pela chave de debug.

## Onde o projeto está

```bash
flutter build apk --release   # já conclui hoje
```

Sai um APK de **58 MB**, porque empacota as três ABIs:

```
21,8 MB  lib/x86_64        <- só emulador, nenhum celular usa
20,4 MB  lib/arm64-v8a     <- todo aparelho moderno
17,9 MB  lib/armeabi-v7a   <- aparelho antigo (32 bits)
```

## Android — GitHub Releases (CE-03/CE-04)

Fora da loja não existe intermediário montando o pacote por aparelho: a divisão tem que
acontecer no build.

```bash
flutter build apk --release --split-per-abi
```

Gera três arquivos em `build/app/outputs/flutter-apk/`. Publique o **`arm64-v8a`** (~20 MB) e,
se quiser cobrir aparelho antigo, o `armeabi-v7a`. O `x86_64` não serve a ninguém — é
emulador.

Na página do Release, deixe explícito qual baixar. Quem não sabe a ABI do próprio aparelho vai
escolher errado, e "o app não instala" é o suporte que você não quer dar. Se preferir uma
única resposta, publique só o `arm64-v8a` e diga isso.

Instalação exige "fontes desconhecidas" — vale um parágrafo no corpo do Release, junto do
motivo (não está na Play Store).

## Android — Google Play, se um dia

```bash
flutter build appbundle --release
```

O AAB delega ao Play a montagem do APK por aparelho: mesmo problema do `--split-per-abi`,
resolvido do outro lado. Não use AAB fora do Play — não é instalável diretamente.

Requisitos que o projeto já cumpre: `targetSdk 36` (o Play exige ≥35), `applicationId` único,
ícone adaptativo. Faltaria: conta de desenvolvedor (US$ 25, pagamento único), ficha da loja,
capturas de tela e a política de privacidade.

Ative o **Play App Signing** se for por esse caminho — o Google guarda a chave final e o seu
keystore vira chave de *upload*, substituível em caso de perda. É a única rede de proteção
para o cenário descrito em `assinar-release.md`.

## App Store — o destino declarado

### O que é obrigatório antes de tentar

| Item | Situação |
|---|---|
| Mac com Xcode | Só ele arquiva e envia. Ver "iOS" abaixo |
| Apple Developer Program | US$ 99/**ano**, recorrente. Sem isso não há envio |
| Login com Apple | Diretriz 4.8, se houver login Google. Faz parte do M9 |
| Excluir conta dentro do app | Diretriz 5.1.1(v). Faz parte do M9 |
| Política de privacidade | URL pública obrigatória. Ver [`politica-privacidade.md`](politica-privacidade.md) |
| Nutrition labels | Formulário no App Store Connect, não é o mesmo que a política |
| Nada em estado "em breve" | Diretriz 2.1. Hoje `conta_backup_page.dart` tem dois itens `enabled: false` |

### Diretrizes que este app toca de perto

- **2.1 — App Completeness.** Funcionalidade visível que não funciona é rejeição. Os dois
  `ListTile` de login desabilitados são exatamente o caso.
- **4.8 — Login Services.** Havendo login de terceiros (Google), é obrigatório oferecer
  alternativa equivalente e com privacidade. O "Entrar com a Apple" já está posicionado acima
  do Google no layout por causa disso — não reordene.
- **5.1.1(v) — Account Deletion.** Precisa ser possível excluir a conta **dentro do app**,
  não por e-mail de suporte. Remove `backups/{uid}` e a conta no Auth.
- **5.1.1 — Data Collection.** As nutrition labels precisam bater com a política. O app não
  coleta analytics de valores; o que sai do aparelho é o backup, por ação explícita.

### O estado de iOS hoje

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

### O que ainda exige o Mac

- `flutter build ipa`, `pod install`, rodar em simulador ou aparelho, assinar com certificado
  Apple e enviar ao App Store Connect. Sem substituto no Windows.
- **Launch screen no modo escuro.** No Android isso saiu com `drawable-night-v21/`; no iOS a
  cor de fundo mora no storyboard, que não acompanha o tema sozinho. O caminho é um
  *Color Set* no catálogo (`LaunchBackground.colorset`, com variante `luminosity: dark`)
  referenciado por nome no storyboard, mais variantes escuras na `LaunchImage.imageset`.
  Ficou para o Mac de propósito: é edição de arquivo do Xcode que não dá para validar sem
  abrir o Xcode, e um storyboard malformado quebra o build.
- Conferir o ícone renderizado no simulador. A máscara do iOS corta mais que a do Android, e
  a marca pode pedir um `escala` menor.

## Versionamento

`pubspec.yaml` → `version: 1.0.0+1`. O `+1` vira `versionCode` no Android e `CFBundleVersion`
no iOS: **precisa aumentar a cada envio**, mesmo que o `1.0.0` não mude. Ambas as lojas
recusam um build com número já usado.

## Checklist final

- [ ] M9 fechado, sem nada `enabled: false` visível
- [ ] Keystore de release gerado e guardado fora da máquina
- [ ] SHA-1 **de release** registrado no Firebase (não só o de debug)
- [ ] `apksigner verify` mostrando o seu certificado, não `CN=Android Debug`
- [ ] Política de privacidade publicada e a URL acessível
- [ ] `--split-per-abi`, publicando o `arm64-v8a`
- [ ] `version` incrementada
- [ ] iOS: nome, ícone e splash reais (se for para a App Store)
