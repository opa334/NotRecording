@interface FBSystemService
+ (id)sharedInstance;
- (void)exitAndRelaunch:(BOOL)arg1;
@end

#define preferencePlist @"/var/mobile/Library/Preferences/com.opa334.notrecordingprefs.plist"

void respring()
{
  [[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
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
  NSArray* args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
  if(args.count != 0)
  {
		NSString *executablePath = args[0];
    if (executablePath)
    {
      NSString *processName = [executablePath lastPathComponent];
      BOOL isApplication = [executablePath containsString:@"/Application"];
      BOOL isSpringboard = [processName isEqualToString:@"SpringBoard"];

      if(isSpringboard)
      {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)respring, CFSTR("com.opa334.notrecording/respring"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
      }

      if(isApplication)
      {
        NSString* identifier = [NSBundle mainBundle].bundleIdentifier;

        NSDictionary* preferences = [[NSDictionary alloc] initWithContentsOfFile:preferencePlist];
        NSNumber *enabled, *enabledForApplication;

        enabled = [preferences objectForKey:@"enabled"];
        if(!enabled) enabled = @YES;

        enabledForApplication = [preferences objectForKey:[NSString stringWithFormat:@"enabled-%@", identifier]];
        if(!enabledForApplication) enabledForApplication = @NO;

        if([enabled boolValue] && [enabledForApplication boolValue])
        {
          //NSLog(@"notRecording enabled");
          %init(Application);
        }
      }
    }
  }
}
