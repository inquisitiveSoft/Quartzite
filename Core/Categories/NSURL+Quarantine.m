#import "NSURL+Quarantine.h"
#import <CoreServices/CoreServices.h>
#import <sys/xattr.h>


@implementation NSURL (AJKQuarantine)


- (NSDictionary *)quarantineProperties
{
	FSRef fsRef;
	if(CFURLGetFSRef((CFURLRef)self, &fsRef)) {
		CFDictionaryRef quarentineProperties;
		if((LSCopyItemAttribute(&fsRef, kLSRolesAll, kLSItemQuarantineProperties, (CFTypeRef *)&quarentineProperties) == noErr) && quarentineProperties)
			return (NSDictionary *)CFMakeCollectable(quarentineProperties);
	}
	
	return nil;
}


@end