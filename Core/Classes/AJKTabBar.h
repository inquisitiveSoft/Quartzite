#import <QuartzCore/QuartzCore.h>

@class AJKTabBarItem, AJKBackgroundView;
@protocol AJKTabBarDelegate;


@interface AJKTabBar : NSView {
	// Storage
	NSMutableArray *tabItems;
	
	// Appearance
	CALayer *rootLayer, *pageBackground;
	CGFloat minimumTabWidth, maximumTabWidth, leftPadding, rightPadding, tabSpacing;
	NSColor *textColor, *selectedTextColor, *tabColor, *selectedTabColor, *borderColor, *selectedBorderColor;
	
	// Event handling
	NSTrackingArea *trackingArea;
	CGPoint initialMouseDownPosition, hitPositionWithinSelectedTab;
	BOOL dragHasExcededStickyTolerance;
	__block id mouseUpHandler;
}

@property (assign) NSObject <AJKTabBarDelegate> *delegate;
@property (assign) CGFloat minimumTabWidth, maximumTabWidth, leftPadding, rightPadding, tabSpacing;
@property (assign) CALayer *clickedButton, *highlightedButton;
@property (assign) AJKTabBarItem *selectedTab,  *highlightedTab;
@property (assign) NSColor *textColor, *selectedTextColor, *tabColor, *selectedTabColor, *borderColor, *selectedBorderColor;

- (id)initWithFrame:(NSRect)frame;
- (void)awakeFromNib;

// Managing Tab Items
- (NSInteger)indexForTab:(AJKTabBarItem *)tabItemToFind;
- (AJKTabBarItem *)tabAtIndex:(NSInteger)tabIndex;
- (AJKTabBarItem *)tabForRepresentedObject:(id)representedObject;

- (void)insertTab:(AJKTabBarItem *)tabBarItem;
- (void)insertTab:(AJKTabBarItem *)tabBarItem atIndex:(NSInteger)index;

- (void)removeTab:(AJKTabBarItem *)tabItem;

- (void)moveTab:(AJKTabBarItem *)tabItem toIndex:(NSInteger)index;
- (void)selectTab:(AJKTabBarItem *)tabItem;

- (void)layoutTabs;
- (void)arrangeTabDepths;
- (void)dragTab:(AJKTabBarItem *)draggedTabBarItem toPosition:(CGFloat)draggedTabPosition;

@end