# Flutter Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Keep Flutter Webview & AdMob
-keep class com.google.android.gms.ads.** { *; }
-keep class com.pichillilorenzo.flutter_inappwebview_android.** { *; }

# Keep models & json serialization
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Keep GetIt & Dio
-keep class com.example.MatchIn.** { *; }
