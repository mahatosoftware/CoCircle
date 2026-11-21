# Required for google_sign_in 7.0.0+ (Identity Services)
-keep class com.google.android.gms.auth.api.identity.** { *; }
-dontwarn com.google.android.gms.auth.api.identity.**
-keep class com.google.android.libraries.identity.googleid.** { *; }
-dontwarn com.google.android.libraries.identity.googleid.**

# Required for Credential Manager
-keep class androidx.credentials.** { *; }
-dontwarn androidx.credentials.**

# AndroidX Startup & Initializers
-keep class androidx.startup.** { *; }
-keep class * extends androidx.startup.Initializer {
    public <init>();
}
-dontwarn androidx.startup.**

# AndroidX WorkManager & Room Database
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker { *; }
-keep class * extends androidx.work.ListenableWorker { *; }
-keep class androidx.work.impl.WorkDatabase_Impl {
    public <init>();
}
-keep class * extends androidx.room.RoomDatabase {
    public <init>();
}
-keepclassmembers class * extends androidx.room.RoomDatabase {
    *;
}
-keep class * extends androidx.room.migration.Migration {
    *;
}
-dontwarn androidx.work.**
-dontwarn androidx.room.**

