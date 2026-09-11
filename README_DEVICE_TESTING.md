# Guia de Teste em Dispositivo Físico - Boxing AI

Este documento detalha o procedimento para compilar, instalar e testar o aplicativo **Boxing AI** em seu smartphone celular (Android ou iOS) com aceleração de hardware local e taxa de 30+ FPS.

---

## Opção 1: Rodar Direta e Instantaneamente via USB (Modo Desenvolvedor)

### Passo a Passo no Smartphone Android:
1. Acesse **Configurações > Sobre o Telefone**.
2. Toque no **Número da Versão** (Build Number) **7 vezes consecutivas** até ativar o modo *Opções do Desenvolvedor*.
3. Vá em **Configurações > Opções do Desenvolvedor** e ative a **Depuração USB** (USB Debugging).
4. Conecte o dispositivo ao computador via cabo USB e aceite a mensagem *"Permitir depuração USB deste computador?"*.

### Execução no Terminal:
No terminal da raiz do projeto (`c:\Users\User\Downloads\BOXE`), execute:

```powershell
flutter run --release
```

> **Por que `--release`?**
> Em modo `--debug`, a máquina virtual Dart injeta código de depuração que reduz o FPS da câmera. O modo `--release` utiliza compilação AOT (Ahead-Of-Time) nativa, liberando a velocidade máxima de 30 a 60 FPS com MediaPipe Pose.

---

## Opção 2: Gerar o Arquivo APK de Instalação (Android)

Se você deseja gerar o arquivo `.apk` para instalar diretamente ou enviar para outro celular:

1. Execute o script automático compilador:
   ```powershell
   .\scripts\build_release_apk.ps1
   ```
2. O arquivo APK otimizado para celulares modernos (ARM64) será gerado em:
   `c:\Users\User\Downloads\BOXE\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk`
3. Copie o arquivo para o seu celular ou instale via terminal com o comando:
   ```powershell
   adb install -r build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
   ```

---

## Resumo da Experiência no Dispositivo

Ao abrir o app no seu celular:
1. **Home Screen Cyber-Boxing**:
   - Você verá o perfil do atleta, seu streak 🔥 **7 DIAS** e o botão pulsante central **INICIAR ROUND 1**.
2. **Ao Clicar em INICIAR ROUND 1**:
   - O app solicitará a permissão de acesso à **Câmera Frontal**.
   - Posicione o celular em uma superfície estável na altura dos ombros a cerca de 1,5 metros.
   - O esqueleto neon verde/azul será desenhado sobre os seus braços e ombros a **30+ FPS**.
   - Estenda totalmente o braço para desferir um **Jab**: o HUD reagirá instantaneamente com o aviso `⚡ JAB DETECTADO! ⚡` e incrementará o placar!
3. **Ao Concluir o Round (3 min)**:
   - A tela de **Resumo de Fim de Round** exibirá seu total de golpes, tempo, precisão %, XP ganho e salvará offline de forma permanente.
