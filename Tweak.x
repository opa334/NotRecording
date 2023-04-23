#import "Shared.h"
#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <rootless.h>

extern char*** _NSGetArgv();
NSString* safe_getExecutablePath()
{
	char* executablePathC = **_NSGetArgv();
	return [NSString stringWithUTF8String:executablePathC];
}

NSString* safe_getBundleIdentifier()
{
	CFBundleRef mainBundle = CFBundleGetMainBundle();

	if(mainBundle != NULL)
	{
		CFStringRef bundleIdentifierCF = CFBundleGetIdentifier(mainBundle);

		return (__bridge NSString*)bundleIdentifierCF;
	}

	return nil;
}

void (*__BKSTerminateApplicationForReasonAndReportWithDescription)(NSString *bundleID, int reasonID, bool report, NSString *description);

void loadBackboardServices(void)
{
	static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
        void* bbsHandle = dlopen("/System/Library/PrivateFrameworks/BackBoardServices.framework/BackBoardServices", RTLD_NOW);
		__BKSTerminateApplicationForReasonAndReportWithDescription = dlsym(bbsHandle, "BKSTerminateApplicationForReasonAndReportWithDescription");
    });
}

void handleEnabledAppsChange()
{
	static NSDictionary* cachedPrefs;
	NSDictionary* newPrefs = [NSDictionary dictionaryWithContentsOfFile:NOT_RECORDING_PREFS_PATH];

	if(cachedPrefs)
	{
		NSMutableSet* oldEnabledApps = [NSMutableSet setWithArray:cachedPrefs[@"enabledApplications"]?:@[]];
		NSMutableSet* newEnabledApps = [NSMutableSet setWithArray:newPrefs[@"enabledApplications"]?:@[]];

		NSMutableSet* disabledApps = [oldEnabledApps mutableCopy];
		NSMutableSet* enabledApps = [newEnabledApps mutableCopy];

		[enabledApps minusSet:oldEnabledApps];
		[disabledApps minusSet:newEnabledApps];

		NSMutableSet* changedApps = disabledApps.mutableCopy;
		[changedApps unionSet:enabledApps];

		for(NSString* changedAppId in changedApps)
		{
			loadBackboardServices();
			__BKSTerminateApplicationForReasonAndReportWithDescription(changedAppId, 5, false, @"NotRecording - prefs changed, killed");
		}
	}

	cachedPrefs = newPrefs;
}


%group Application
%hook UIScreen

//Prevents apps from checking whether the screen is being captured
- (BOOL)isCaptured
{
	//NSLog(@"isCaptured access prevented!");
	return NO;
}

//Make sure apps can't check the ivar instead...
- (void)_setCaptured:(BOOL)captured
{
	//NSLog(@"_setCaptured set prevented!");
	%orig(NO);
}

//Prevents apps from checking whether the screen is being mirrored
- (UIScreen*)mirroredScreen
{
	//NSLog(@"mirroredScreen access prevented!");
	return nil;
}

%end
%end

%ctor
{
	NSString *executablePath = safe_getExecutablePath();
	if (executablePath)
	{
		NSString *processName = [executablePath lastPathComponent];
		BOOL isSpringBoard = [processName isEqualToString:@"SpringBoard"];
		if(isSpringBoard)
		{
			migratePreferencesIfNeeded();
			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handleEnabledAppsChange, CFSTR("com.opa334.notrecordingprefs/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
			handleEnabledAppsChange();
		}

		BOOL isApplication = [executablePath containsString:@"/Application"];
		if(isApplication)
		{
			NSString* identifier = safe_getBundleIdentifier();

			NSDictionary* preferences = [[NSDictionary alloc] initWithContentsOfFile:NOT_RECORDING_PREFS_PATH];

			NSNumber* globallyEnabledNum = [preferences objectForKey:@"enabled"];
			BOOL globallyEnabled = globallyEnabledNum ? globallyEnabledNum.boolValue : YES;
			if(!globallyEnabled) return;

			NSArray* enabledApps = [preferences objectForKey:@"enabledApplications"];
			if(![enabledApps containsObject:identifier]) return;

			%init(Application);
		}
	}
}
