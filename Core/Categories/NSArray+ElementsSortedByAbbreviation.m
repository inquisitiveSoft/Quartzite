#import "NSArray+ElementsSortedByAbbreviation.h"
#import "NSString+ScoreForAbbreviation.h"
#import "AJKDocumentationElement.h"


// Private methods and functions
@interface NSArray ()

NSComparisonResult compareElementsByRating(AJKDocumentationElement *firstElement, AJKDocumentationElement *secondElement, void *context);

@end

@implementation NSArray (ElementsSortedByAbbreviation)


- (NSArray *)elementsSortedByAbbreviation:(NSString *)abbreviationString
{
	if([abbreviationString length] == 0)
		return self;
	
	[self calculateScoresForAbbreviation:abbreviationString];
	
	return [self elementsSortedByAbbreviation];
}


- (void)calculateScoresForAbbreviation:(NSString *)abbreviationString
{
	[self enumerateObjectsWithOptions:0 usingBlock:^(AJKDocumentationElement *element, NSUInteger indexOfObject, BOOL *stop) {
		element.scoreForAbbreviation = [[element name] scoreForAbbreviation:abbreviationString];
	}];
}


- (NSArray *)elementsSortedByAbbreviation
{
	return [self sortedArrayUsingFunction:compareElementsByRating context:NULL];
}




NSComparisonResult compareElementsByRating(AJKDocumentationElement *firstElement, AJKDocumentationElement *secondElement, void *context) {
	CGFloat firstElementRating = [firstElement scoreForAbbreviation];
	CGFloat secondElementRating = [secondElement scoreForAbbreviation];
	
	if(firstElementRating < secondElementRating)
		return NSOrderedDescending;
	else if(firstElementRating > secondElementRating)
		return NSOrderedAscending;
	
	return [[firstElement name] localizedCompare:[secondElement name]];
}


@end