#import "NSWorkspace+ApplicationURLsforURL.h"

@implementation NSWorkspace (AJKApplicationURLsforURL)


- (NSArray *)applicationURLsForURL:(NSURL *)fileURL
{
	NSArray *applicationURLs = (NSArray *)NSMakeCollectable(LSCopyApplicationURLsForURL((CFURLRef)fileURL, kLSRolesAll));
	return [applicationURLs copy];
}


@end