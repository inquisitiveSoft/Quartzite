#import "AJKTabBarItem.h"

#import "NSObject+PerformSelectorAdditions.h"
#import "NSColor+CGColor.h"


@implementation AJKTabBarItem
@synthesize representedObject, textColor;


+ (NSDictionary *)fontAttributes
{
	static NSDictionary *fontAttributes = nil;
	static dispatch_once_t createFontAttributes;
	dispatch_once(&createFontAttributes, ^{
		fontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSFont fontWithName:@"Lucida Grande" size:12.0], NSFontAttributeName,
								nil];
	});
	
	return fontAttributes;
}


- (id)init
{
	self = [super init];
	
	if(self) {
		layoutSpacing = 10;
		closeButtonSize = 12;
		
		closeButton = [CALayer layer];
		closeButton.delegate = self;
		closeButton.name = @"Close Button";
		closeButton.frame = CGRectMake(layoutSpacing, 9, closeButtonSize, closeButtonSize);
		[self addSublayer:closeButton];
		[closeButton setNeedsDisplay];
		
		textLayer = [CATextLayer layer];
		textLayer.frame = CGRectMake((layoutSpacing * 1.1) + closeButtonSize, 9, 100, 14);
		textLayer.font = @"Lucida Grande";
		textLayer.fontSize = 12.0;
		textLayer.truncationMode = kCATruncationEnd;
		
		[self addSublayer:textLayer];
		
		self.anchorPoint = CGPointMake(0, 0);
		self.autoresizingMask = kCALayerHeightSizable;
		self.textColor = [NSColor colorWithCalibratedWhite:0.4 alpha:1.0];
		self.needsDisplayOnBoundsChange = TRUE;
	}
	
	return self;
}


- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[self layout];
}


- (void)layout
{
	CGRect textLayerFrame = [textLayer frame];
	textLayerFrame.size.width = [self bounds].size.width - closeButtonSize - (layoutSpacing * 2.2);	
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	textLayer.frame = textLayerFrame;
	[CATransaction commit];
}


- (void)setLabel:(NSString *)label
{
	textLayer.string = label;
	[[self delegate] tryToPerformSelector:@selector(layoutTabs)];
}


- (NSString *)label
{
	return [textLayer string];
}


- (CGFloat)optimalWidth
{
	NSSize fontSize = [[self label] ? : @"" sizeWithAttributes:[AJKTabBarItem fontAttributes]];
	CGFloat tabWidth = fontSize.width + closeButtonSize + (layoutSpacing * 2.75);
	CGFloat minimumTabWidth = [[self delegate] floatForSelector:@selector(minimumTabWidth)];
	CGFloat maximumTabWidth = [[self delegate] floatForSelector:@selector(maximumTabWidth)];
	
	if(tabWidth < minimumTabWidth)
		tabWidth = minimumTabWidth;
	else if(tabWidth > maximumTabWidth)
		tabWidth = maximumTabWidth;
	
	return ceil(tabWidth);
}


- (void)drawInContext:(CGContextRef)context
{
	CGFloat inset = 12;
	CGRect bounds = [self bounds];
	bounds.size.height = 20;
	bounds.origin.y = 6;
	
	NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:graphicsContext];
	
	BOOL isSelected = ([[self delegate] tryToPerformSelector:@selector(selectedTab)] == self);
	BOOL isHighlighted = ([[self delegate] tryToPerformSelector:@selector(highlightedTab)] == self);
	
	if(isSelected || isHighlighted) {
		NSColor *selectedTabColor = [[self delegate] tryToPerformSelector:@selector(selectedTabColor)];
		selectedTabColor = selectedTabColor ? : [NSColor colorWithDeviceWhite:1 alpha:1];
		[selectedTabColor setFill];
	} else {
		NSColor *normalTabColor = [[self delegate] tryToPerformSelector:@selector(tabColor)];
		normalTabColor = normalTabColor ? : [NSColor colorWithCalibratedHue:0.593 saturation:0.025 brightness:0.75 alpha:1.0];
		[normalTabColor setFill];
	}
	
	backgroundPath = [NSBezierPath bezierPath];	
	[backgroundPath moveToPoint:NSMakePoint(bounds.origin.x, bounds.origin.y)];
	[backgroundPath curveToPoint:NSMakePoint(inset, bounds.size.height + bounds.origin.y) controlPoint1:NSMakePoint((inset*3)/4, bounds.origin.y) controlPoint2:NSMakePoint(inset/3, bounds.size.height + bounds.origin.y)];
	[backgroundPath lineToPoint:NSMakePoint(bounds.size.width - inset, bounds.size.height + bounds.origin.y)];
	[backgroundPath curveToPoint:NSMakePoint(bounds.size.width, bounds.origin.y) controlPoint1:NSMakePoint(bounds.size.width - (inset/3), bounds.origin.y + bounds.size.height) controlPoint2:NSMakePoint(bounds.size.width - ((inset*3)/4), bounds.origin.y)];
	[backgroundPath setLineWidth:2];
	
	[backgroundPath fill];
	
	if(isSelected || isHighlighted) {
		NSColor *selectedBorderColor = [[self delegate] tryToPerformSelector:@selector(selectedBorderColor)];
		selectedBorderColor ? : [[NSColor colorWithDeviceWhite:0.75 alpha:1.0] setStroke];
		[selectedBorderColor setStroke];
	} else {
		NSColor *borderColor = [[self delegate] tryToPerformSelector:@selector(borderColor)];
		borderColor ? : [[NSColor colorWithDeviceWhite:0.75 alpha:1.0] setStroke];
		[borderColor setStroke];
	}
	
	[backgroundPath setLineWidth:0.0];
	[backgroundPath stroke];
	
	bounds.origin.y -= 20;
	NSRectFill(bounds);
	
	[NSGraphicsContext restoreGraphicsState];
}


- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
	if(layer == closeButton) {
		NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
		[NSGraphicsContext saveGraphicsState];
		[NSGraphicsContext setCurrentContext:graphicsContext];
		
		BOOL closeButtonIsHighlighted = ([[self delegate] tryToPerformSelector:@selector(highlightedButton)]) == closeButton;
		if(closeButtonIsHighlighted) {
			[[NSColor colorWithDeviceWhite:0.55 alpha:1] setFill];
			[[NSBezierPath bezierPathWithOvalInRect:NSRectFromCGRect([closeButton bounds])] fill];
		}
		
		NSBezierPath *cross = [NSBezierPath bezierPath];
		[cross moveToPoint:NSMakePoint(closeButtonSize/3, closeButtonSize/3)];
		[cross lineToPoint:NSMakePoint((closeButtonSize/3)*2, (closeButtonSize/3)*2)];
		[cross moveToPoint:NSMakePoint(closeButtonSize/3, (closeButtonSize/3)*2)];
		[cross lineToPoint:NSMakePoint((closeButtonSize/3)*2, closeButtonSize/3)];
		[cross setLineWidth:2];
		[cross setLineCapStyle:NSSquareLineCapStyle];
		
		if(closeButtonIsHighlighted)
			[[NSColor colorWithDeviceWhite:0.95 alpha:1] setStroke];
		else
			[[NSColor colorWithDeviceWhite:0.65 alpha:1] setStroke];
		
		[cross stroke];
		
		[NSGraphicsContext restoreGraphicsState];
	} else
		[super drawLayer:layer inContext:context];
}


- (CALayer *)hitTest:(CGPoint)pointToTest
{
	pointToTest = [self convertPoint:pointToTest fromLayer:[self superlayer]];
	NSBezierPath *closeButtonHitArea = [NSBezierPath bezierPathWithOvalInRect:NSRectFromCGRect([closeButton frame])];
	if([closeButtonHitArea containsPoint:NSPointFromCGPoint(pointToTest)])
		return closeButton;
	
	CGRect bottomRect = [self bounds];
	bottomRect.size.height = 6;
	if([backgroundPath containsPoint:NSPointFromCGPoint(pointToTest)] || CGRectContainsPoint(bottomRect, pointToTest))
		return self;
	
	return nil;
}


- (void)setTextColor:(NSColor *)color
{
	textColor = color;
	textLayer.foregroundColor = [color CGColor];
}


@end