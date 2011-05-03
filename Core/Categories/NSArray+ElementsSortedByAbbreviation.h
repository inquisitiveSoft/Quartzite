@class AJKDocumentationElement;

@interface NSArray (ElementsSortedByAbbreviation)

- (NSArray *)elementsSortedByAbbreviation;
- (NSArray *)elementsSortedByAbbreviation:(NSString *)abbreviationString;
- (void)calculateScoresForAbbreviation:(NSString *)abbreviationString;

@end