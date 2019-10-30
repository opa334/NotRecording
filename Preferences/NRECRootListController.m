#include "NRECRootListController.h"

@implementation NRECRootListController

- (NSString*)plistName
{
	return @"Root";
}

- (void)respring
{
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.opa334.notrecording/respring"), NULL, NULL, YES);
}

@end
