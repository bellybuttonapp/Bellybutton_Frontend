# Flutter specific
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# OkHttp (required for image_cropper/uCrop)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# uCrop (image_cropper)
-dontwarn com.yalantis.ucrop.**
-keep class com.yalantis.ucrop.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play Core (deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Gson (if used)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# Keep generic signatures for reflection
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# Kotlin
-dontwarn kotlin.**
-keep class kotlin.** { *; }
