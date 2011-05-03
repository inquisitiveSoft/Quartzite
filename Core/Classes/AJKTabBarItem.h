#import <QuartzCore/QuartzCore.h>

@interface AJKTabBarItem : CALayer {
	CATextLayer *textLayer;
	CALayer *closeButton;
	
	CGFloat layoutSpacing, closeButtonSize;
	NSBezierPath *backgroundPath;
	NSColor *textColor;
}

@property (assign) id representedObject;
@property (assign) NSColor *textColor;

- (id)init;
- (void)layout;

- (void)setLabel:(NSString *)label;
- (NSString *)label;

+ (NSDictionary *)fontAttributes;
- (CGFloat)optimalWidth;

- (void)drawInContext:(CGContextRef)context;
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context; // Draws the close button

- (CALayer *)hitTest:(CGPoint)pointToTest; // Overridden to take aount of the close button and tab shape

@end