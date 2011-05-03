#import "AJKViewController.h"

@interface AJKSearchPaneController : AJKViewController {
	
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectTab:(id)item;
- (NSString *)outlineView:(NSOutlineView *)outlineView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tc item:(id)item mouseLocation:(NSPoint)mouseLocation;


@end