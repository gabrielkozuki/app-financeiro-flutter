# Configurar Firebase (Auth + Realtime Database)

Estes passos dependem da sua conta Google e só você pode executá-los. Depois de concluí-los,
eu ligo o código de **login (Google + Apple)** e o **backup na nuvem** no app.

## 1. Criar o projeto no Firebase

1. Acesse <https://console.firebase.google.com> e clique em **Adicionar projeto**.
2. Nomeie (ex.: `minhas-financas`), pode desativar o Google Analytics.
3. Plano **Spark (gratuito)** — não precisa de cartão para Auth + Realtime Database.

## 2. Habilitar Authentication

1. No console: **Build → Authentication → Get started**.
2. Aba **Sign-in method** → habilite **Google** (defina o e-mail de suporte).
3. (Para iOS, depois) habilite **Apple**.

## 3. Habilitar Realtime Database

1. **Build → Realtime Database → Criar banco de dados**.
2. Local: escolha o mais próximo (ex.: `us-central1`).
3. Comece em **modo bloqueado** e depois aplique as regras abaixo (cada usuário só acessa o
   próprio backup):

   ```json
   {
     "rules": {
       "backups": {
         "$uid": {
           ".read": "auth != null && auth.uid === $uid",
           ".write": "auth != null && auth.uid === $uid"
         }
       }
     }
   }
   ```

## 4. Conectar o app Flutter (no seu Mac ou máquina com Flutter)

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

- Faça login na sua conta Google quando pedir.
- Selecione o projeto criado.
- Marque as plataformas **Android** (e iOS depois).
- Isso gera `lib/firebase_options.dart` e `android/app/google-services.json`.

## 5. Registrar o SHA-1 (Google Sign-In no Android)

```bash
cd android
./gradlew signingReport
```

- Copie o **SHA-1** (variante `debug`) e cole em:
  **Firebase Console → Configurações do projeto → Seus apps (Android) → Adicionar impressão digital**.
- Baixe novamente o `google-services.json` se o console pedir.

## 6. Me avise

Com `lib/firebase_options.dart` gerado e o Realtime Database ativo, me avise que eu:

- inicializo o Firebase no `main.dart`;
- adiciono a **tela de login** (Google/Apple) como porta de entrada, envolvendo o `RootGate`;
- implemento o **`BackupService`** (enviar/restaurar o JSON em `backups/{uid}`), com botão em
  Configurações, push no logout e oferta de restauração ao logar em outro aparelho.

> Enquanto o Firebase não estiver configurado, o app roda normalmente offline (sem login).
