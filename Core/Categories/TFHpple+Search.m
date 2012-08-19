#import "TFHpple+Search.h"



@implementation TFHpple (AJKSearch)


- (NSArray *)search:(NSString *)xPathOrCSS
{
	return [self searchWithXPathQuery:xPathOrCSS];
}


@end
