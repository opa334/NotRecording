#import <Preferences/PSSpecifier.h>

#import "NRECListController.h"

@implementation NRECListController

//Must be overwritten by subclass
- (NSString*)plistName
{
	return nil;
}

- (NSMutableArray*)specifiers
{
	if(!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:[self plistName] target:self];
		_allSpecifiers = [_specifiers copy];
		[self removeDisabledGroups:_specifiers];
	}

	return _specifiers;
}

- (void)removeDisabledGroups:(NSMutableArray*)specifiers;
{
	for(PSSpecifier* specifier in [specifiers reverseObjectEnumerator])
	{
		NSNumber* nestedEntryCount = [[specifier properties] objectForKey:@"nestedEntryCount"];
		if(nestedEntryCount)
		{
			BOOL enabled = [[self readPreferenceValue:specifier] boolValue];

			if(!enabled)
			{
				NSMutableArray* nestedEntries = [[_allSpecifiers subarrayWithRange:NSMakeRange([_allSpecifiers indexOfObject:specifier]+1, [nestedEntryCount intValue])] mutableCopy];

				BOOL containsNestedEntries = NO;

				for(PSSpecifier* nestedEntry in nestedEntries)
				{
					NSNumber* nestedNestedEntryCount = [[nestedEntry properties] objectForKey:@"nestedEntryCount"];
					if(nestedNestedEntryCount)
					{
						containsNestedEntries = YES;
						break;
					}
				}

				if(containsNestedEntries)
				{
					[self removeDisabledGroups:nestedEntries];
				}

				[specifiers removeObjectsInArray:nestedEntries];
			}
		}
	}
}

- (void)setPreferenceValue:(NSNumber *)value specifier:(PSSpecifier*)specifier
{
	[super setPreferenceValue:value specifier:specifier];

	NSNumber* nestedEntryCount = [[specifier properties] objectForKey:@"nestedEntryCount"];
	if(nestedEntryCount)
	{
		NSInteger index = [_allSpecifiers indexOfObject:specifier];
		NSMutableArray* nestedEntries = [[_allSpecifiers subarrayWithRange:NSMakeRange(index + 1, [nestedEntryCount intValue])] mutableCopy];
		[self removeDisabledGroups:nestedEntries];

		if([value boolValue])
		{
			[self insertContiguousSpecifiers:nestedEntries afterSpecifier:specifier animated:YES];
		}
		else
		{
			[self removeContiguousSpecifiers:nestedEntries animated:YES];
		}
	}
}

@end
