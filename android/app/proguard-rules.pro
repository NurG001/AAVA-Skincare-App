# -- Flutter Wrapper Rules --
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# -- Google ML Kit Rules --
# Prevent R8 from stripping ML Kit text recognition options
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.common.** { *; }

# Specifically keep the language options causing the error
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }
-keep class com.google.mlkit.vision.text.latin.** { *; }

# -- TensorFlow Lite Rules --
# Prevent stripping of TFLite GPU delegate classes
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }

# -- Generic Safety --
-dontwarn com.google.mlkit.**
-dontwarn org.tensorflow.**

# --- NEW: Google Play Services & Deferred Components Fix ---
# Prevents crash due to missing Play Core libraries (SplitInstall, etc.)
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# --- Flutter Local Notifications Fix ---
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.google.gson.** { *; }

# --- Flutter Timezone Fix ---
-keep class net.wolverinebeach.flutter_timezone.** { *; }