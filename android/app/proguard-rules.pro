# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclass com.example.offline_messenger.** { *; }
#-keepclass * extends com.example.offline_messenger.WebAppInterface
#-keepclass * extends com.example.offline_messenger.WebAppInterface { *; }
#-keepclassmembers class * extends com.example.offline_messenger.WebAppInterface {
#     <methods>;
# }

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }

# Keep model classes
-keep class com.example.offline_messenger.models.** { *; }

# Keep network related classes
-keep class org.json.** { *; }
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }

-dontwarn okhttp3.**
-dontwarn retrofit2.**

# SQLite
-keep class org.sqlite.** { *; }
-keep class * extends org.sqlite.database.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
