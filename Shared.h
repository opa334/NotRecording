#import <rootless.h>
#define NOT_RECORDING_PREFS_PATH ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.opa334.notrecordingprefs.plist")

extern void migratePreferencesIfNeeded(void);