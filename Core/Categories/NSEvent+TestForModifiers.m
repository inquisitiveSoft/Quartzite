// #import "NSEvent+TestForModifiers.h"

@implementation NSEvent (AJKTestForModifiers)


- (BOOL)commandAndOptionHeld
{
	return (([self modifierFlags] & NSCommandKeyMask) != 0) && ([self modifierFlags] & NSAlternateKeyMask) != 0;
}


@end