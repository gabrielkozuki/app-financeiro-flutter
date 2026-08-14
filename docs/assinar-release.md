# Assinar o release (Android)

> **Fora do caminho atual.** Desde 14/08/2026 o destino é a App Store, sem Play Store e sem
> APK por GitHub Releases — nada aqui é necessário para publicar. O documento fica porque a
> decisão pode voltar atrás e porque o projeto continua compilando para Android.
>
> **Assinatura de iOS não tem relação com isto.** Lá são certificados e perfis de
> provisionamento da Apple, gerenciados pelo Xcode; ver [`distribuicao.md`](distribuicao.md).

Hoje o `build.gradle.kts` ainda tem o bloco do template:

```kotlin
buildTypes {
    release {
        // TODO: Add your own signing config for the release build.
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

Ou seja, `flutter build apk --release` produz um APK assinado com a chave de debug.
Dá para conferir a qualquer momento:

```bash
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
# hoje: certificate DN: C=US, O=Android, CN=Android Debug
```

A chave de debug é gerada automaticamente por máquina e é pública — qualquer um pode assinar
um APK com ela. Não serve para distribuir.

## Por que isso é o passo mais irreversível do projeto

O Android identifica uma atualização pelo par (`applicationId`, **certificado**). Como o
`applicationId` já está congelado em `br.com.gabrielkozuki.contaemdia`, é o certificado que
decide se a próxima versão instala por cima ou é recusada.

**Perder o keystore depois de publicar significa que nenhuma versão futura instala por cima.**
O usuário teria que desinstalar — e como o app usa `android:allowBackup="false"` (deliberado:
o backup dele é o da nuvem, não o do sistema), o banco local vai junto.

Guarde o `.jks` e a senha **fora do repositório e fora desta máquina**.

## 1. Gerar o keystore

`keytool` vem com o JDK que o Android Studio instala. No PowerShell, da raiz do projeto:

```powershell
keytool -genkey -v -keystore $HOME\conta-em-dia.jks `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias conta-em-dia
```

- `-validity 10000` são ~27 anos. O Google Play recusa certificado que expire antes de
  22/10/2033; use um prazo folgado e não pense nisso de novo.
- Ele pede uma senha e alguns dados de identificação (nome, organização, país). Podem ser os
  seus; aparecem só no certificado.
- **Fora do repositório de propósito** — `$HOME`, não a pasta do projeto. O
  `android/.gitignore` já ignora `key.properties`, `*.keystore` e `*.jks`, mas um arquivo
  fora do projeto não depende de o `.gitignore` estar certo.

## 2. Criar `android/key.properties`

```properties
storePassword=<a senha que você digitou>
keyPassword=<a mesma, se não definiu outra para a chave>
keyAlias=conta-em-dia
storeFile=C:/Users/<voce>/conta-em-dia.jks
```

Use **barras normais** (`/`) mesmo no Windows — o Gradle interpreta `\` como escape.

Este arquivo já é ignorado pelo `android/.gitignore`. Confira antes de commitar:

```bash
git check-ignore -v android/key.properties   # deve responder com a linha do .gitignore
```

## 3. Trocar o bloco no `android/app/build.gradle.kts`

No topo do arquivo, **antes** de `plugins { ... }`:

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

Dentro de `android { ... }`, antes de `buildTypes`:

```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String?
        keyPassword = keystoreProperties["keyPassword"] as String?
        storeFile = keystoreProperties["storeFile"]?.let { file(it) }
        storePassword = keystoreProperties["storePassword"] as String?
    }
}
```

E substitua o `buildTypes`:

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

O `if (keystorePropertiesFile.exists())` importa: sem ele, um clone do repositório sem o
`key.properties` **falha ao abrir o projeto no Gradle**, não só ao buildar em release.

## 4. Verificar

```bash
flutter build apk --release
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

O `certificate DN` tem que refletir o que você digitou no passo 1. Se ainda aparecer
`CN=Android Debug`, o Gradle não achou o `key.properties` e caiu no bloco vazio — confira o
caminho e as barras.

## 5. Guardar

Três coisas, no mesmo lugar seguro (gerenciador de senhas com anexo, ou cofre offline):

| O quê | Por quê |
|---|---|
| `conta-em-dia.jks` | Sem ele não há atualização, nunca mais |
| A senha do store e da chave | O `.jks` sozinho é inútil |
| O `keyAlias` | Está no `key.properties`, que não vai para o git |

Se um dia publicar no Google Play, ative o **Play App Signing**: o Google passa a guardar a
chave de assinatura final e o seu keystore vira apenas a chave de *upload*, que pode ser
substituída em caso de perda. Para distribuição fora da loja (APK avulso) essa rede de
proteção não existe.

## Se a decisão voltar atrás

Duas coisas que só aparecem quando o Android volta ao caminho:

- **O APK sai com 58 MB** porque empacota `arm64-v8a`, `armeabi-v7a` e `x86_64`. Fora do Play
  não existe intermediário montando o pacote por aparelho, então a divisão tem que acontecer
  no build: `flutter build apk --release --split-per-abi`, publicando o `arm64-v8a` (~20 MB).
  O `x86_64` é emulador e não serve a nenhum celular.
- **O SHA-1 do keystore de release** precisa ser registrado no Firebase, além do de debug
  (passo 1.6 de [`m9-auth-backup.md`](m9-auth-backup.md)). Esquecer faz o Google Sign-In
  funcionar em desenvolvimento e falhar em silêncio no APK publicado.
