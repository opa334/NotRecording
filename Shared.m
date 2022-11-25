#import "Shared.h"
#import <Foundation/Foundation.h>

void migratePreferencesIfNeeded(void)
{
	NSMutableDictionary* existingPrefs = [NSDictionary dictionaryWithContentsOfFile:NOT_RECORDING_PREFS_PATH].mutableCopy;
	if(existingPrefs)
	{
		NSMutableArray* previousVersionEnabled = [NSMutableArray new];
		[existingPrefs enumerateKeysAndObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString* key, NSNumber* value, BOOL* stop)
		{
			if(![value isKindOfClass:[NSNumber class]]) return;
			if([key hasPrefix:@"enabled-"])
			{
				if(value.boolValue)
				{
					[previousVersionEnabled addObject:[key substringFromIndex:8]];
				}
				[existingPrefs removeObjectForKey:key];
			}
		}];

		if(previousVersionEnabled.count)
		{
			existingPrefs[@"enabledApplications"] = previousVersionEnabled;
			[existingPrefs writeToFile:NOT_RECORDING_PREFS_PATH atomically:YES];
		}
	}
}