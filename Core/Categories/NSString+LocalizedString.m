#import "NSString+LocalizedString.h"

@implementation NSString (AJKLocalizedString)


- (NSString *)localizedString
{
	return NSLocalizedString(self, nil);
}


- (NSString *)localizedStringWithHint:(NSString *)hint
{
	return NSLocalizedString(self, hint);
}


@end