#import "AJKXMLParser.h"
#import "NSObject+PerformSelectorAdditions.h"

@implementation AJKXMLParser
@synthesize result, target, resultSelector;


- (id)initWithData:(NSData *)data
{
	self = [super initWithData:data];
	if (self == nil) return nil;
	
	self.delegate = self;
	result = [[NSMutableString alloc] init];
	
	return self;
}


- (BOOL)parse
{
	[[NSGarbageCollector defaultCollector] disableCollectorForPointer:self];
	return [super parse];
}


#pragma mark -
#pragma mark Parse contents from the raw xml data


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributesDictionary
{
	if(isInsideEnclosingTags)
		[result appendString:@" "];
	else if([elementName isEqualToString:@"body"])
		isInsideEnclosingTags = TRUE;
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if(isInsideEnclosingTags)
		[result appendString:string];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if([elementName isEqualToString:@"body"])
		isInsideEnclosingTags = FALSE;
}


- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	SEL selector = [self resultSelector];
	if([[self target] respondsToSelector:selector])
		[[self target] performSelector:selector withObject:result];
	
	[[NSGarbageCollector defaultCollector] enableCollectorForPointer:self];
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	qLog(@"%@", [parseError localizedDescription]);
	[[NSGarbageCollector defaultCollector] enableCollectorForPointer:self];
}


- (void)finalize
{
	[self abortParsing];
	[super finalize];
}

@end