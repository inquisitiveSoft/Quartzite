// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AJKDocumentationSet.m instead.

#import "_AJKDocumentationSet.h"

@implementation AJKDocumentationSetID
@end

@implementation _AJKDocumentationSet

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DocumentationSet" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DocumentationSet";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DocumentationSet" inManagedObjectContext:moc_];
}

- (AJKDocumentationSetID*)objectID {
	return (AJKDocumentationSetID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"indexingProgressValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"indexingProgress"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"numberOfIndexedDocumentsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"numberOfIndexedDocuments"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"hasBeenIndexedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hasBeenIndexed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic properties;






@dynamic name;






@dynamic family;






@dynamic platformVersion;






@dynamic indexingProgress;



- (float)indexingProgressValue {
	NSNumber *result = [self indexingProgress];
	return [result floatValue];
}

- (void)setIndexingProgressValue:(float)value_ {
	[self setIndexingProgress:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveIndexingProgressValue {
	NSNumber *result = [self primitiveIndexingProgress];
	return [result floatValue];
}

- (void)setPrimitiveIndexingProgressValue:(float)value_ {
	[self setPrimitiveIndexingProgress:[NSNumber numberWithFloat:value_]];
}





@dynamic bundleIdentifier;






@dynamic numberOfIndexedDocuments;



- (int)numberOfIndexedDocumentsValue {
	NSNumber *result = [self numberOfIndexedDocuments];
	return [result intValue];
}

- (void)setNumberOfIndexedDocumentsValue:(int)value_ {
	[self setNumberOfIndexedDocuments:[NSNumber numberWithInt:value_]];
}

- (int)primitiveNumberOfIndexedDocumentsValue {
	NSNumber *result = [self primitiveNumberOfIndexedDocuments];
	return [result intValue];
}

- (void)setPrimitiveNumberOfIndexedDocumentsValue:(int)value_ {
	[self setPrimitiveNumberOfIndexedDocuments:[NSNumber numberWithInt:value_]];
}





@dynamic version;






@dynamic hasBeenIndexed;



- (BOOL)hasBeenIndexedValue {
	NSNumber *result = [self hasBeenIndexed];
	return [result boolValue];
}

- (void)setHasBeenIndexedValue:(BOOL)value_ {
	[self setHasBeenIndexed:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveHasBeenIndexedValue {
	NSNumber *result = [self primitiveHasBeenIndexed];
	return [result boolValue];
}

- (void)setPrimitiveHasBeenIndexedValue:(BOOL)value_ {
	[self setPrimitiveHasBeenIndexed:[NSNumber numberWithBool:value_]];
}





@dynamic url;






@dynamic references;

	
- (NSMutableSet*)referencesSet {
	[self willAccessValueForKey:@"references"];
	NSMutableSet *result = [self mutableSetValueForKey:@"references"];
	[self didAccessValueForKey:@"references"];
	return result;
}
	





@end
