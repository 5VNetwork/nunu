# AGP 9 R8 full mode strips RoomDatabase no-arg constructors used by reflection.
# WorkManager (via google_mobile_ads) crashes on startup without this.
-keep class * extends androidx.room.RoomDatabase {
    <init>();
}
