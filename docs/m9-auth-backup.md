# M9 — Autenticação e backup na nuvem

Fecha o **CE-06** (login social) e dá ao app o backup de verdade. É o último marco funcional;
depois dele só resta a publicação na Play Store ([`distribuicao.md`](distribuicao.md)).

Substitui o antigo `configurar-firebase.md`, que descrevia o login como porta de entrada —
decisão revertida (ver abaixo).

## O que já está pronto no código

Não comece do zero: a base foi construída durante o M8.

| Peça | Onde | Estado |
|---|---|---|
| Serializar/restaurar o banco inteiro | `lib/data/backup_service.dart` | Pronto e testado (`test/persistence/backup_roundtrip_test.dart`) |
| `backupServiceProvider` | `lib/core/providers.dart:55` | Pronto |
| Tela "Conta e backup" | `lib/features/config/conta_backup_page.dart` | Layout pronto, itens `enabled: false` |
| Porta a partir do onboarding | Botão "Já uso o app" | Pronta |
| Recarregar tudo após troca de banco | `aposMudancaAmpla(ref)` em `mes_panorama.dart:334` | Pronto |

`BackupService` **não sabe nada de rede** e continua assim. A API é:

```dart
Future<String> exportarJson();          // banco inteiro -> String
Future<void>   importarJson(String);    // String -> banco inteiro (valida antes de escrever)
Future<void>   apagarTudo();
static DateTime? geradoEm(String);      // lê o carimbo do envelope sem importar
static const formatoBackupAtual = 1;
```

O serviço de nuvem só **move essa String**. Se ele precisar entender o conteúdo do JSON,
a fronteira foi rompida.

## Decisões já fechadas — não reabrir

- **Login NÃO é porta de entrada.** O app abre e funciona inteiro sem conta (RNF-01/RNF-04).
  O `RootGate` continua binário (onboarding ou shell) e **não** é envolvido por tela de login.
  Entrar mora em Configurações → "Conta e backup", e também no botão "Já uso o app" da
  primeira tela do onboarding — sem essa segunda porta, um aparelho recém-instalado não
  alcança a restauração sem antes cadastrar dados que a restauração vai apagar.
- **"Entrar com a Apple" vem ACIMA de "Entrar com o Google".** A exigência é da diretriz 4.8
  da App Store (alternativa equivalente e com privacidade quando há login de terceiros), então
  **não vale para o Play** — mas a ordem fica. Custa zero manter, e reordenar depois, quando a
  App Store voltar ao mapa, seria retrabalho com risco de rejeição.
- **Backup é blob JSON por UID, *last-wins*.** Sem merge, sem resolução de conflito por campo.
- **Não existe "restaurar de arquivo".** O backup real é o da nuvem; um segundo canal seria
  uma segunda fonte para o mesmo dado. O JSON exportado em Configurações é portabilidade
  (RF-19), não canal de restauração.
- **Excluir conta** é diferente de "apagar dados locais": precisa remover `backups/{uid}`
  **e** a conta no Firebase Auth, não só o banco. As duas lojas exigem, com uma diferença: a
  Apple quer o caminho dentro do app (5.1.1(v)); o **Play quer isso e mais uma URL pública**,
  para quem já desinstalou conseguir pedir. A URL é uma seção da página de privacidade —
  ver [`politica-privacidade.md`](politica-privacidade.md).

---

# Parte 1 — O que só você pode fazer

Depende da sua conta Google. Enquanto não estiver feito, o app roda normalmente offline.

## 1.1 Criar o projeto no Firebase

1. <https://console.firebase.google.com> → **Adicionar projeto**.
2. Nome sugerido: `conta-em-dia`. Pode desativar o Google Analytics.
3. Plano **Spark (gratuito)** — Auth + Realtime Database não exigem cartão.
   (Cloud Storage passou a exigir Blaze em fev/2026; por isso o backup é no Realtime Database.)

## 1.2 Habilitar Authentication

**Build → Authentication → Get started → Sign-in method**

- Habilite **Google** (defina o e-mail de suporte).
- **Apple** só quando houver conta paga no Apple Developer Program.

## 1.3 Habilitar Realtime Database

**Build → Realtime Database → Criar banco de dados**, região mais próxima, começando em
**modo bloqueado**. Depois aplique estas regras:

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

Sem `.read`/`.write` na raiz: o padrão é negar, e é isso que se quer. Cada usuário enxerga
exclusivamente o próprio nó.

## 1.4 Readicionar as dependências

Foram **removidas do `pubspec.yaml`** de propósito. Mesmo sem serem importadas em `lib/`,
injetavam `ACCESS_NETWORK_STATE`, `USE_BIOMETRIC`, `USE_FINGERPRINT` e `READ_GSERVICES` no
manifesto e um `FirebaseInitProvider` no start — permissões e custo de inicialização sem
função nenhuma.

```bash
flutter pub add firebase_core firebase_auth firebase_database google_sign_in
# sign_in_with_apple só quando houver conta Apple Developer
```

> Conferir depois: `flutter build apk --release` e comparar as permissões do manifesto
> mesclado. Hoje o app declara **zero** permissões; toda permissão nova precisa de motivo.

## 1.5 Conectar o app

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Selecione o projeto e marque **Android** (iOS depois). Gera `lib/firebase_options.dart` e
`android/app/google-services.json`.

## 1.6 Registrar o SHA-1 (Google Sign-In no Android)

```bash
cd android && ./gradlew signingReport
```

Copie o **SHA-1** e cole em **Configurações do projeto → Seus apps (Android) → Adicionar
impressão digital**. Baixe o `google-services.json` de novo se o console pedir.

São **três** SHA-1 ao todo, e a ordem em que eles passam a existir importa:

| Origem | Quando existe | Para que |
|---|---|---|
| Variante `debug` | Agora | `flutter run` e o emulador |
| Keystore de **upload** | Depois de [`assinar-release.md`](assinar-release.md) | Buildar release na sua máquina |
| Chave de **assinatura do app** (do Google) | **Só depois do primeiro envio ao Play** | O login de quem baixa da loja |

O terceiro é o que quebra em produção. Com Play App Signing o Google re-assina o AAB com uma
chave própria, então o app que chega ao aparelho **não** carrega o seu certificado de upload —
e o Google Sign-In valida contra o certificado real. Ele aparece em **Play Console →
Configurar → Integridade do app**.

Registrar só os dois primeiros faz o login funcionar em desenvolvimento, funcionar no APK que
você mesmo instala, e falhar em silêncio para quem baixar da loja. É o erro clássico aqui, e
como o terceiro SHA-1 só nasce depois do primeiro envio, ele é fácil de esquecer: volte ao
Firebase **depois** de enviar.

---

# Parte 2 — O que eu implemento depois

Me avise quando `lib/firebase_options.dart` existir e o Realtime Database estiver ativo.

## 2.1 Inicialização

`Firebase.initializeApp` no `main.dart`, **sem bloquear a abertura do app**. Falha de rede na
inicialização não pode impedir o uso offline (RNF-01).

## 2.2 Entrar e sair

Em `conta_backup_page.dart`, trocar os dois `ListTile` desabilitados por ação real, mantendo
Apple acima de Google. Estado da sessão num provider, com o e-mail/nome exibido quando logado.

## 2.3 Enviar e restaurar

- **Enviar:** `exportarJson()` → `backups/{uid}` como String, com carimbo de data.
- **Restaurar:** ler o nó → `importarJson()` → `aposMudancaAmpla(ref)`.
  Sem o `aposMudancaAmpla`, a tela continua mostrando dado que não existe mais — invalidar as
  leituras sem limpar os meses reabertos deixa o painel incoerente.
- **No logout:** perguntar antes de enviar.
- **Ao logar com UID diferente do último visto:** perguntar uma vez, oferecendo "usar os dados
  deste aparelho" vs "restaurar os da conta", **com a data do backup** (é para isso que
  `BackupService.geradoEm` existe — lê o carimbo sem importar nada).

## 2.4 Excluir conta

Item explícito, com confirmação. Remove `backups/{uid}`, chama `delete()` no usuário do
Firebase Auth e só então oferece apagar o banco local.

O Play exige **também** uma URL pública de solicitação de exclusão, para quem já desinstalou
— não substitui o caminho dentro do app, soma-se a ele. Mora na página de privacidade.

## 2.5 Cobertura

Regra de negócio nova é pouca — a serialização já é testada. O que precisa de teste é a
**decisão** de qual lado vence ao logar com UID diferente, que é regra pura e cabe em
`test/unit/`. Rede não entra na suíte.

## 2.6 Traduzir

Toda string nova entra em `lib/l10n/app_pt.arb` **e** `app_en.arb` — o glossário fechado está
em `lib/l10n/README.md`. Atenção ao par que já causou confusão: *conta* (bill) vs *conta de
usuário* (account). Esta tela é a segunda.

## 2.7 Política de privacidade

A partir do momento em que existe UID e dado em servidor, ela deixa de ser opcional.
Ver [`politica-privacidade.md`](politica-privacidade.md).
