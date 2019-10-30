#import <Preferences/PSListController.h>

//Parses nestedEntryCount property for more dynamic preferences
@interface NRECListController : PSListController
{
  NSArray* _allSpecifiers;
}

- (NSString*)plistName;
- (void)removeDisabledGroups:(NSMutableArray*)specifiers;
@end
