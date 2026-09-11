# Regras de Proguard/R8 para preservar o Google ML Kit Pose Detection e TensorFlow Lite

# Preserva plugins Flutter nativos
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Preserva ML Kit Pose Detection e classes nativas do Google Vision
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.vision.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_pose.** { *; }
-dontwarn com.google.mlkit.**

# Preserva o motor TensorFlow Lite C++ JNI
-keep class org.tensorflow.lite.** { *; }
-keepclassmembers class * {
    native <methods>;
}

# Preserva metadados de mídia da Câmera Flutter
-keep class com.baseflow.permissionhandler.** { *; }
