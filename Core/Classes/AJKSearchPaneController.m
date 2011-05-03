#import "AJKSearchPaneController.h"


@implementation AJKSearchPaneController


// It's a pain, but these methods seem to cause crashes if their implemented in MacRuby. No idea why.

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectTab:(id)item
{
	SEL elementSelector = @selector(element);
	return [item respondsToSelector:elementSelector] && [item performSelector:elementSelector];
}


- (NSString *)outlineView:(NSOutlineView *)outlineView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tc item:(id)item mouseLocation:(NSPoint)mouseLocation
{
	SEL nameSelector = @selector(name);
	
	if([item respondsToSelector:nameSelector])
		return [item performSelector:nameSelector];
	
	return @"";
}


@end