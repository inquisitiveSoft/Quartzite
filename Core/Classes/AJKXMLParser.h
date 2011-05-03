#import "AJKBlockFunctions.h"

typedef void (^PKParseStringResultBlock)(NSString *);
typedef void (^PKParseAttributesResultBlock)(NSDictionary *);


// Parse contents from the raw xml data

@interface AJKXMLParser : NSXMLParser <NSXMLParserDelegate> {
	BOOL isInsideEnclosingTags;
}

@property (assign) NSMutableString *result;
@property (assign) id target;
@property (assign) SEL resultSelector;

- (id)initWithData:(NSData *)data;

// Parse contents from the raw xml data
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName;

- (void)parserDidEndDocument:(NSXMLParser *)parser;
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError;


@end