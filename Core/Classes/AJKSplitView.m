#import "AJKSplitView.h"

@implementation AJKSplitView


- (void)drawDividerInRect:(NSRect)dividerRect
{
	SEL drawDividerSelector = @selector(splitView:drawDividerInRect:);
	
	if ([[self delegate] respondsToSelector:drawDividerSelector])
		[[self delegate] performSelector:drawDividerSelector withObject:self withObject:[NSValue valueWithRect:dividerRect]];
	else
		[super drawDividerInRect:dividerRect];
}


@end