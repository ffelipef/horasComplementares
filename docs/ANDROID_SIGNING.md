# Android Signing (keystore) — passos rápidos

Este documento mostra como gerar um keystore local, como configurar `key.properties` e como gerar um build assinado.

1) Gerar um keystore (exemplo usando `keytool`):

```powershell
# Substitua os valores conforme necessário e execute no PowerShell
keytool -genkey -v -keystore C:\path\to\keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my_key_alias
```

2) Criar `android/key.properties` a partir do exemplo

- Copie `android/key.properties.example` para `android/key.properties` e preencha as propriedades:

```
storePassword=SUPER_SECRET_STORE_PASSWORD
keyPassword=SUPER_SECRET_KEY_PASSWORD
keyAlias=my_key_alias
storeFile=C:\path\to\keystore.jks
```

Observação: `android/key.properties` já está listado no `.gitignore` para evitar comitar credenciais.

3) Gerar um build release (AAB recomendado para Play Store)

```powershell
# Do diretório do projeto
flutter clean
flutter pub get
flutter build appbundle --release
```

4) Dicas adicionais
- Verifique `android/app/build.gradle.kts` — ele detecta `key.properties` no root e configura a assinatura automaticamente.
- Para automatizar builds no CI, armazene o keystore e `key.properties` como secrets e restaure no job antes do build.
- Nunca comite senhas/keystores em repositórios públicos.

Se quiser que eu gere um exemplo de `key.properties` usando um keystore que você criar aqui (posso executar `keytool` se você confirmar), me diga o caminho do keystore e as senhas, ou gere o keystore localmente e me peça para criar `android/key.properties` a partir dos valores fornecidos.
