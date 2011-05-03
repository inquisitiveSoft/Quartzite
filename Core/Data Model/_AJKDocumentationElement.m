// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AJKDocumentationElement.m instead.

#import "_AJKDocumentationElement.h"

@implementation AJKDocumentationElementID
@end

@implementation _AJKDocumentationElement

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DocumentationElement" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DocumentationElement";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DocumentationElement" inManagedObjectContext:moc_];
}

- (AJKDocumentationElementID*)objectID {
	return (AJKDocumentationElementID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"typeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"type"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"orderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"order"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic type;



- (short)typeValue {
	NSNumber *result = [self type];
	return [result shortValue];
}

- (void)setTypeValue:(short)value_ {
	[self setType:[NSNumber numberWithShort:value_]];
}

- (short)primitiveTypeValue {
	NSNumber *result = [self primitiveType];
	return [result shortValue];
}

- (void)setPrimitiveTypeValue:(short)value_ {
	[self setPrimitiveType:[NSNumber numberWithShort:value_]];
}





@dynamic name;






@dynamic order;



- (int)orderValue {
	NSNumber *result = [self order];
	return [result intValue];
}

- (void)setOrderValue:(int)value_ {
	[self setOrder:[NSNumber numberWithInt:value_]];
}

- (int)primitiveOrderValue {
	NSNumber *result = [self primitiveOrder];
	return [result intValue];
}

- (void)setPrimitiveOrderValue:(int)value_ {
	[self setPrimitiveOrder:[NSNumber numberWithInt:value_]];
}





@dynamic parentName;






@dynamic urlString;






@dynamic url;






@dynamic documentationSet;

	

@dynamic parentElement;

	

@dynamic childElements;

	
- (NSMutableSet*)childElementsSet {
	[self willAccessValueForKey:@"childElements"];
	NSMutableSet *result = [self mutableSetValueForKey:@"childElements"];
	[self didAccessValueForKey:@"childElements"];
	return result;
}
	





@end
