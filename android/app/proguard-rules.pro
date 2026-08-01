# Flutter-specific R8/Proguard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.android.gms.common.annotation.KeepName { *; }
-keepnames class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# Fix for Play Store Split / Deferred Components missing classes
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**
