#import "AJKTabBar.h"

#import "AJKTabBarDelegate.h"
#import "AJKTabBarItem.h"
#import "AJKBackgroundView.h"
#import "AJKBlockFunctions.h"

#import "NSArray+UntestedIndex.h"
#import "NSColor+CGColor.h"


@implementation AJKTabBar
@synthesize delegate;
@synthesize minimumTabWidth, maximumTabWidth, leftPadding, rightPadding, tabSpacing;
@synthesize clickedButton, highlightedButton, selectedTab, highlightedTab;
@synthesize textColor, selectedTextColor, tabColor, selectedTabColor, borderColor, selectedBorderColor;


- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	if(self) {
		// Set some reasonable values
		self.minimumTabWidth = 80;
		self.maximumTabWidth = 200;
		self.leftPadding = 7;
		self.rightPadding = 7;
		self.tabSpacing = -11;
		
		pageBackground = [CALayer layer];
		pageBackground.delegate = self;
		
		tabItems = [[NSMutableArray alloc] init];
	}
	
	return self;
}


- (void)awakeFromNib
{
	trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingInVisibleRect | NSTrackingActiveInActiveApp) owner:self userInfo:nil];
	[self addTrackingArea:trackingArea];

	[self setWantsLayer:TRUE];
	rootLayer = [CALayer layer];
	[self setLayer:rootLayer];
	NSRect bounds = NSRectToCGRect([self bounds]);
	rootLayer.bounds = bounds;
	rootLayer.autoresizingMask = kCALayerWidthSizable;
	
	pageBackground.autoresizingMask = kCALayerWidthSizable;
	
	bounds.origin.x = -1.0;
	bounds.origin.y = -14.0;
	bounds.size.height = 20.0;
	bounds.size.width += 2.0;
	
	pageBackground.frame = bounds;
	pageBackground.borderWidth = 1.0;
	pageBackground.zPosition = 1;
	pageBackground.cornerRadius = 0.0;
	
	[rootLayer addSublayer:pageBackground];
	
	self.tabColor = [NSColor lightGrayColor];
	self.selectedTabColor = [NSColor whiteColor];
	self.selectedBorderColor = [NSColor colorWithCalibratedWhite:0.6 alpha:1.0];
	self.borderColor = [NSColor colorWithCalibratedWhite:0.6 alpha:1.0];
}



#pragma mark -
#pragma mark Manage Tab Item


- (NSInteger)indexForTab:(AJKTabBarItem *)tabItemToFind
{
	NSInteger tabItemIndex = 0;
	for(AJKTabBarItem *tabItem in tabItems) {
		if(tabItem == tabItemToFind)
			return tabItemIndex;
		
		tabItemIndex++;
	}
	
	return NSNotFound;
}


- (AJKTabBarItem *)tabAtIndex:(NSInteger)tabIndex
{
	if(tabIndex < 0)
		tabIndex = 0;
	else if(tabIndex >= [tabItems count])
		tabIndex = [tabItems count] - 1;
	
	return [tabItems objectAtUntestedIndex:tabIndex];
}


- (AJKTabBarItem *)tabForRepresentedObject:(id)representedObject
{
	for(AJKTabBarItem *tabItem in tabItems) {
		if([[tabItem representedObject] isEqual:representedObject])
			return tabItem;
	}
	
	return nil;
}


- (void)insertTab:(AJKTabBarItem *)tabBarItem
{
	[self insertTab:tabBarItem atIndex:[tabItems count]];
}


- (void)insertTab:(AJKTabBarItem *)tabItem atIndex:(NSInteger)index
{
	if((index < 0) || (index > [tabItems count])) {
		qLog(@"The requested index %d was outsoud the range of existing tab items", index, tabItem);
		index = [tabItems count];
	}
	
	if(tabItem) {
		tabItem.delegate = self;
		[tabItems insertObject:tabItem atIndex:index];
		[[self layer] addSublayer:tabItem];
		[self selectTab:tabItem];
		
		[self layoutTabs];
		[tabItem setNeedsDisplay];
	} else
		qLog(@"Can't insert a nil tab item");
}


- (void)removeTab:(AJKTabBarItem *)tabItem
{
	if(tabItem) {
		SEL shouldRemoveTabSelector = @selector(tabBar:shouldRemoveTab:);
		NSObject <AJKTabBarDelegate> *tabBarDelegate = [self delegate];
		if(tabBarDelegate && [tabBarDelegate respondsToSelector:shouldRemoveTabSelector]
			&& ![tabBarDelegate tryToPerformBOOLSelector:shouldRemoveTabSelector withObject:self withObject:tabItem])
			return;
		
		NSInteger selectionIndex = NSNotFound;
		if([self selectedTab] == tabItem)
			selectionIndex = [self indexForTab:tabItem];
		
		[tabItem removeFromSuperlayer];
		[tabItems removeObject:tabItem];
		[self layoutTabs];
		
		SEL didRemoveItemSelector = @selector(tabBar:didRemoveItem:);
		if([tabBarDelegate respondsToSelector:didRemoveItemSelector])
			[tabBarDelegate performSelector:didRemoveItemSelector withObject:self withObject:tabItem];
		
		if(selectionIndex != NSNotFound)
			[self selectTab:[self tabAtIndex:selectionIndex]];
	}
}


- (void)selectTab:(AJKTabBarItem *)tabItem
{
	NSObject <AJKTabBarDelegate> *tabBarDelegate = [self delegate];
	SEL didSelectTabSelector = @selector(tabBar:shouldSelectTab:);
	if(![tabBarDelegate respondsToSelector:didSelectTabSelector]
		|| [tabBarDelegate tryToPerformBOOLSelector:didSelectTabSelector withObject:self withObject:tabItem]) {
		
		self.selectedTab = tabItem;
		
		SEL didSelectTabSelector = @selector(tabBar:didSelectTab:);
		if([[self delegate] respondsToSelector:didSelectTabSelector])
			[[self delegate] tabBar:self didSelectTab:tabItem];
	}
}


- (void)moveTab:(AJKTabBarItem *)tabItem toIndex:(NSInteger)index
{
	if(index != [self indexForTab:tabItem]) {
		[self removeTab:tabItem];
		[self insertTab:tabItem atIndex:index];	// Does the necessary bounds checking
	}
}


- (void)layoutTabs
{
	CGRect containerBounds = [rootLayer bounds];
	CGPoint tabPosition = containerBounds.origin;
	tabPosition.x += leftPadding;
	tabPosition.y += containerBounds.origin.y;
		
	for(AJKTabBarItem *tabItem in tabItems) {
		CGFloat tabWidth = [tabItem optimalWidth];
		tabItem.frame = CGRectMake(tabPosition.x, tabPosition.y, tabWidth, containerBounds.size.height);
		tabPosition.x += tabWidth + tabSpacing;
	}
	
	[self arrangeTabDepths];
}


- (void)arrangeTabDepths
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	AJKTabBarItem *currentTab = [self selectedTab];

	CGFloat tabFraction = 1.0 / [tabItems count];
	NSInteger tabIndex = 1;
	BOOL beforeSelectedTab = TRUE;
	
	for(AJKTabBarItem *tabItem in tabItems) {
		if(tabItem == currentTab) {
			tabItem.zPosition = 2;
			beforeSelectedTab = FALSE;
		} else if(beforeSelectedTab)
			tabItem.zPosition = -(1 - (tabFraction * tabIndex));
		else
			tabItem.zPosition = -(tabFraction * tabIndex);
		
		tabIndex += 1;
	}
	
	[CATransaction commit];
}


- (void)dragTab:(AJKTabBarItem *)draggedTabBarItem toPosition:(CGFloat)draggedTabPosition
{
	// Check that the dragged tab lies within the appropriate bounds
	if(draggedTabPosition <= leftPadding)
		draggedTabPosition = leftPadding;
	else {
		CGFloat rightmostPosition = [self bounds].size.width - [draggedTabBarItem bounds].size.width - rightPadding;
		if(draggedTabPosition > rightmostPosition)
			draggedTabPosition = rightmostPosition;
	}
	
	CGRect containerBounds = [rootLayer bounds];
	CGPoint tabPosition = containerBounds.origin;
	tabPosition.x += leftPadding;
	tabPosition.y += containerBounds.origin.y;
		
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	[draggedTabBarItem setPosition:CGPointMake(draggedTabPosition, tabPosition.y)];
	[CATransaction commit];
	
	
	NSInteger indexOfDraggedTabItem = NSNotFound;	
	CGFloat tabHeight = [[self layer] bounds].size.height;
	CGRect draggedTabBarItemBounds = [draggedTabBarItem bounds];
	
	NSUInteger tabIndex = 0;
	for(AJKTabBarItem *tabItem in tabItems) {
		if((indexOfDraggedTabItem == NSNotFound) && (tabPosition.x + (draggedTabBarItemBounds.size.width / 2) > draggedTabPosition)) {
			indexOfDraggedTabItem = tabIndex;
			tabIndex += 1;
			tabPosition.x += [draggedTabBarItem optimalWidth] + tabSpacing;
		}
		
		if(tabItem != draggedTabBarItem) {
			CGFloat tabWidth = [tabItem optimalWidth];
			
			// Will be animated:
			tabItem.frame = CGRectMake(tabPosition.x, tabPosition.y, tabWidth, tabHeight);
			
			tabIndex += 1;
			tabPosition.x += tabWidth + tabSpacing;
		}
	}
	
	
	if(indexOfDraggedTabItem == NSNotFound)
		indexOfDraggedTabItem = tabIndex;

	[self moveTab:draggedTabBarItem toIndex:indexOfDraggedTabItem];
	[self arrangeTabDepths];
}



#pragma mark -
#pragma mark Handle Mouse Actions


- (void)mouseEntered:(NSEvent *)theEvent
{
	[self mouseMoved:theEvent];
}


- (void)mouseMoved:(NSEvent *)theEvent
{
	if(highlightedButton)
		[self setHighlightedButton:FALSE];
	
	NSPoint hitPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	CALayer *layer = [rootLayer hitTest:NSPointToCGPoint(hitPoint)];
	
	if(layer && (layer != rootLayer) && [[layer name] isEqualToString:@"Close Button"])
		[self setHighlightedButton:layer];
}


- (void)mouseExited:(NSEvent *)theEvent
{
	if(highlightedButton) {
		[self mouseDown:theEvent];
		[self setHighlightedButton:nil];
	}
}


- (void)mouseDown:(NSEvent *)theEvent
{	
	NSPoint mousePosition = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	initialMouseDownPosition = NSPointToCGPoint(mousePosition);
	CALayer *layer = [rootLayer hitTest:initialMouseDownPosition];
	
	if(layer && (layer != rootLayer)) {
		if([layer isKindOfClass:[AJKTabBarItem class]]) {
			AJKTabBarItem *tabBarItem = (AJKTabBarItem *)layer;
			self.highlightedTab = tabBarItem;
			self.selectedTab = tabBarItem;
			
			hitPositionWithinSelectedTab = [tabBarItem convertPoint:mousePosition fromLayer:[self layer]];
			dragHasExcededStickyTolerance = FALSE;
			
			mouseUpHandler = [NSEvent addLocalMonitorForEventsMatchingMask:NSLeftMouseUpMask handler:(void *)^(NSEvent *event) {
				[self layoutTabs];
				[NSEvent removeMonitor:mouseUpHandler];
				
				self.highlightedButton = nil;
				self.clickedButton = nil;
				self.highlightedTab = nil;
			}];
		} else if([[layer name] isEqualToString:@"Close Button"]) {
			self.highlightedButton = layer;
			self.clickedButton = layer;
		}
	} else
		[super mouseDown:theEvent];
}


- (void)mouseDragged:(NSEvent *)theEvent
{
	if(highlightedButton)
		[self setHighlightedButton:nil];
	
	NSPoint hitPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	CALayer *hitLayer = [rootLayer hitTest:NSPointToCGPoint(hitPoint)];
	CGFloat stickyTolerance = 6.0;
	
	AJKTabBarItem *tabItem = [self highlightedTab];
	if(tabItem) {
		if(dragHasExcededStickyTolerance || (hitPoint.x > initialMouseDownPosition.x + stickyTolerance) || (hitPoint.x < initialMouseDownPosition.x - stickyTolerance)) {
			[self dragTab:tabItem toPosition:(hitPoint.x - hitPositionWithinSelectedTab.x)];
			dragHasExcededStickyTolerance = TRUE;
		}
	} else if(!clickedButton || ((clickedButton == hitLayer) && !highlightedTab && hitLayer
				&& (hitLayer != rootLayer) && [[hitLayer name] isEqualToString:@"Close Button"])) {
		[self setHighlightedButton:hitLayer];
	} else
		[super mouseDragged:theEvent];
}


- (void)mouseUp:(NSEvent *)theEvent
{
	NSPoint hitPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	CALayer *layer = [rootLayer hitTest:NSPointToCGPoint(hitPoint)];
	
	if(layer == clickedButton) {
		[self removeTab:(AJKTabBarItem *)[layer superlayer]];
		return;
	}
	
	[self layoutTabs];
	
	if([layer isKindOfClass:[AJKTabBarItem class]])
		[self selectTab:(AJKTabBarItem *)layer];
	
	[super mouseUp:theEvent];
}


- (void)setSelectedTab:(AJKTabBarItem *)tabToSelect
{
	CALayer *previouslySelectedTab = selectedTab;
	selectedTab = tabToSelect;
	
	[selectedTab setNeedsDisplay];
	[previouslySelectedTab setNeedsDisplay];
	[self arrangeTabDepths];
	
	for(AJKTabBarItem *tabItem in tabItems)
		tabItem.textColor = (tabItem == selectedTab) ? [self selectedTextColor] : [self textColor];
}


- (void)setHighlightedTab:(AJKTabBarItem *)tabToHighlight {
	CALayer *previouslyHighlightedTab = highlightedTab;
	highlightedTab = tabToHighlight;
		
	[highlightedTab setNeedsDisplay];
	[previouslyHighlightedTab setNeedsDisplay];
}


- (void)setHighlightedButton:(CALayer *)buttonToHighlight
{
	CALayer *currentlyHighlightedButton = highlightedButton;
	highlightedButton = buttonToHighlight;
	
	[buttonToHighlight setNeedsDisplay];
	[currentlyHighlightedButton setNeedsDisplay];
}


#pragma mark -
#pragma mark Colors


- (void)setTextColor:(NSColor *)color
{
	textColor = color;
	
	for(AJKTabBarItem *tabBarItem in tabItems)
		[self selectedTab].textColor = color;
}


- (void)setSelectedTextColor:(NSColor *)color
{
	selectedTextColor = color;
	[self selectedTab].textColor = color;
}


- (void)setTabColor:(NSColor *)color
{
	tabColor = color;
	
	for(AJKTabBarItem *tabBarItem in tabItems)
		[tabBarItem setNeedsDisplay];
}


- (void)setSelectedTabColor:(NSColor *)color
{
	pageBackground.backgroundColor = [color CGColor];
	selectedTabColor = color;
	
	[[self selectedTab] setNeedsDisplay];
}


- (void)setBorderColor:(NSColor *)color
{
	borderColor = color;
	
	for(AJKTabBarItem *tabBarItem in tabItems)
		[tabBarItem setNeedsDisplay];
}


- (void)setSelectedBorderColor:(NSColor *)color
{
	pageBackground.borderColor = [color CGColor];
	selectedBorderColor = color;
	[[self selectedTab] setNeedsDisplay];
}


@end