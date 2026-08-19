# Assinar o release (Android)

**No caminho crítico.** Desde 19/08/2026 o destino é a Google Play Store, e nada é enviado
sem uma chave própria.

Hoje o `build.gradle.kts` ainda tem o bloco do template:

```kotlin
buildTypes {
    release {
        // TODO: Add your own signing config for the release build.
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

Ou seja, `flutter build appbundle --release` produz um artefato assinado com a chave de debug.
Dá para conferir a qualquer momento:

```bash
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
# hoje: certificate DN: C=US, O=Android, CN=Android Debug
```

A chave de debug é gerada automaticamente por máquina e é pública — qualquer um pode assinar
com ela. O Play recusa.

## O que esta chave é (e o que ela não é)

Com **Play App Signing** — o padrão para apps novos, e o que vamos usar — existem duas chaves:

| | Chave de **upload** | Chave de **assinatura do app** |
|---|---|---|
| Quem tem | Você, neste keystore | O Google |
| Para que serve | Provar que o envio é seu | Assinar o que chega ao aparelho |
| Se perder | **Recuperável** — pede substituição no console | Não se aplica; você nunca a teve |

A chave gerada abaixo é a de **upload**. Isso muda o tamanho do risco: fora de loja, perder o
keystore significa nunca mais atualizar o app, porque o Android identifica a atualização pelo
par (`applicationId`, certificado). Dentro do Play, o Google guarda a chave que importa e a de
upload é substituível.

Guardar bem continua valendo — recuperação envolve suporte e demora. Mas não é catastrófico.

## 1. Gerar o keystore

`keytool` vem com o JDK que o Android Studio instala. No PowerShell, da raiz do projeto:

```powershell
keytool -genkey -v -keystore $HOME\conta-em-dia-upload.jks `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias upload
```

- `-validity 10000` são ~27 anos. O Play recusa certificado que expire antes de 22/10/2033;
  use prazo folgado e não pense nisso de novo.
- Pede uma senha e alguns dados de identificação. Podem ser os seus; aparecem só no
  certificado.
- **Fora do repositório de propósito** — `$HOME`, não a pasta do projeto. O `android/.gitignore`
  já ignora `key.properties`, `*.keystore` e `*.jks`, mas um arquivo fora do projeto não
  depende de o `.gitignore` estar certo.

## 2. Criar `android/key.properties`

```properties
storePassword=<a senha que você digitou>
keyPassword=<a mesma, se não definiu outra para a chave>
keyAlias=upload
storeFile=C:/Users/<voce>/conta-em-dia-upload.jks
```

Use **barras normais** (`/`) mesmo no Windows — o Gradle interpreta `\` como escape.

Confira antes de commitar:

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

O APK aqui é só para conferir a assinatura. **O que vai para o Play é o AAB**
(`flutter build appbundle --release`); ver [`distribuicao.md`](distribuicao.md).

## 5. Depois do primeiro envio: o SHA-1 que importa

Com Play App Signing existem dois SHA-1, e o Google Sign-In em produção usa o **da chave de
assinatura do app**, não o da sua chave de upload. Ele aparece em **Play Console → Configurar
→ Integridade do app**, e só existe depois do primeiro envio.

Registrar só o de upload faz o login funcionar em desenvolvimento e falhar em silêncio para
quem baixar da loja. Ver o passo 1.6 de [`m9-auth-backup.md`](m9-auth-backup.md).

## 6. Guardar

| O quê | Por quê |
|---|---|
| `conta-em-dia-upload.jks` | Substituível pelo console, mas com burocracia e espera |
| A senha do store e da chave | O `.jks` sozinho é inútil |
| O `keyAlias` | Está no `key.properties`, que não vai para o git |

## Se um dia distribuir fora de loja

Duas coisas que o Play resolve sozinho e voltariam a ser problema seu:

- **O APK sai com 58 MB** porque empacota `arm64-v8a`, `armeabi-v7a` e `x86_64`. Sem
  intermediário montando o pacote por aparelho, a divisão vira
  `flutter build apk --release --split-per-abi`, publicando o `arm64-v8a` (~20 MB).
- **O risco do keystore volta a ser total** — sem Play App Signing, perder a chave significa
  nunca mais atualizar o app instalado.
