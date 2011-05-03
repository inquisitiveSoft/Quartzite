#import "NSApplication+SystemVersion.h"


@implementation NSApplication (AJKSystemVersion)


+ (BOOL)isLion
{
	return !(floor(NSAppKitVersionNumber) <= 1038);		// Should use NSAppKitVersionNumber10_6
}


@end