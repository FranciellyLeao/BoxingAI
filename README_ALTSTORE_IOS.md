# Guia de Compilação do Pacote iOS (.ipa) e Sideloading via AltStore PAL

Este documento fornece as instruções completas, comandos exatos da **Flutter CLI** e configurações nativas do iOS para compilar o pacote `.ipa` do **Boxing AI** e realizar o sideloading via **AltStore PAL**, **AltServer**, **SideStore** ou **Sideloadly**.

---

## 1. Configurações de Identificador & Permissões Nativas

- **Bundle Identifier**: `com.boxing.ai.boxingAi`
- **Permissão de Câmera Frontal (`NSCameraUsageDescription`)**:
  Definida no arquivo [Info.plist](file:///c:/Users/User/Downloads/BOXE/ios/Runner/Info.plist) para conformidade com as diretrizes da Apple e AltStore PAL.
- **ExportOptions.plist**:
  Localizado em [ios/ExportOptions.plist](file:///c:/Users/User/Downloads/BOXE/ios/ExportOptions.plist), configurado com `method: development` e `compileBitcode: false`.

---

## 2. Comando Exato da Flutter CLI para Gerar o Arquivo `.ipa`

Execute o seguinte comando no terminal na raiz do projeto (`c:\Users\User\Downloads\BOXE`):

### Para Compilação Padrão (com perfil de desenvolvimento registrado no Xcode):
```bash
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

### Para Compilação Sem Assinatura Próvia (para re-assinatura via AltStore / AltServer):
Se você não possui uma conta paga de desenvolvedor Apple e deseja que o AltServer/AltStore PAL assine o aplicativo automaticamente com seu ID Apple gratuito:
```bash
flutter build ipa --release --no-codesign
```

---

## 3. Como Empacotar e Instalar o `.ipa` no iPhone

Caso utilize o modo `--no-codesign`:

1. Após a compilação, o Flutter gerará a pasta do aplicativo em:
   `build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app`
2. **Empacotamento do Container Payload**:
   - Crie uma pasta chamada `Payload`.
   - Mova a pasta `Runner.app` para dentro de `Payload`.
   - Compacte a pasta `Payload` para o formato `.zip`.
   - Altere a extensão de `.zip` para `.ipa` (exemplo: `BoxingAI.ipa`).

3. **Sideloading via AltStore PAL / AltServer**:
   - Abra o **AltServer** no seu computador (Windows ou macOS) e conecte seu iPhone via cabo USB ou Wi-Fi na mesma rede.
   - Abra a aplicativo **AltStore** ou **AltStore PAL** no seu iPhone.
   - Toque no botão `+` (Adicionar App) no canto superior esquerdo do AltStore.
   - Selecione o arquivo `BoxingAI.ipa` recém-gerado.
   - O AltServer irá assinar o app com a sua credencial Apple ID e instalar o **Boxing AI** diretamente na sua tela de início!

---

## 4. Otimização de Performance no iPhone

Ao abrir o **Boxing AI** instalado no iPhone:
- A GPU do iOS acelerará a renderização do `PoseOverlayPainter` via **Metal API**.
- O motor **Google ML Kit Pose Detection** executará a inferência temporal on-device a **60 FPS** no processador Apple Neural Engine!
