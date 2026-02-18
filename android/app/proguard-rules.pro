# Required for google_sign_in 7.0.0+ (Identity Services)
-keep class com.google.android.gms.auth.api.identity.** { *; }
-dontwarn com.google.android.gms.auth.api.identity.**
-keep class com.google.android.libraries.identity.googleid.** { *; }
-dontwarn com.google.android.libraries.identity.googleid.**

# Required for Credential Manager
-keep class androidx.credentials.** { *; }
-dontwarn androidx.credentials.**

