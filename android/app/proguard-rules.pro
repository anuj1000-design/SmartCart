# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.kts.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line numbers, uncomment this to hide the original
# source file name.
#-renamesourcefileattribute SourceFile

# Flutter-specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.analytics.** { *; }
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.firebase.firestore.** { *; }
-keep class com.google.firebase.crashlytics.** { *; }
-keep class com.google.firebase.messaging.** { *; }

# Google Sign-In rules
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.api.client.** { *; }

# Google Play Core rules (for deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Keep data classes and models
-keep class com.shrs.smartcart.models.** { *; }
-keep class com.shrs.smartcart.providers.** { *; }

# Keep service classes
-keep class com.shrs.smartcart.services.** { *; }

# Keep widget classes (if needed for reflection or dynamic loading)
-keep class com.shrs.smartcart.widgets.** { *; }

# Keep main activity and application class
-keep class com.shrs.smartcart.MainActivity { *; }
-keep class com.shrs.smartcart.Application { *; }

# General rules for Flutter plugins
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
-dontwarn javax.annotation.**
-dontwarn kotlin.Unit
-dontwarn kotlinx.coroutines.**

# Keep annotations
-keepattributes *Annotation*

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enum values and methods
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep parcelable classes
-keep class * extends android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep serializable classes
-keep class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}