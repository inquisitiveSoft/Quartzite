// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AJKDocumentationElement.h instead.

#import <CoreData/CoreData.h>


@class AJKDocumentationSet;
@class AJKDocumentationElement;
@class AJKDocumentationElement;






@class NSObject;

@interface AJKDocumentationElementID : NSManagedObjectID {}
@end

@interface _AJKDocumentationElement : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (AJKDocumentationElementID*)objectID;



@property (nonatomic, retain) NSNumber *type;

@property short typeValue;
- (short)typeValue;
- (void)setTypeValue:(short)value_;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *order;

@property int orderValue;
- (int)orderValue;
- (void)setOrderValue:(int)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *parentName;

//- (BOOL)validateParentName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *urlString;

//- (BOOL)validateUrlString:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSObject *url;

//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) AJKDocumentationSet* documentationSet;
//- (BOOL)validateDocumentationSet:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) AJKDocumentationElement* parentElement;
//- (BOOL)validateParentElement:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSSet* childElements;
- (NSMutableSet*)childElementsSet;




@end

@interface _AJKDocumentationElement (CoreDataGeneratedAccessors)

- (void)addChildElements:(NSSet*)value_;
- (void)removeChildElements:(NSSet*)value_;
- (void)addChildElementsObject:(AJKDocumentationElement*)value_;
- (void)removeChildElementsObject:(AJKDocumentationElement*)value_;

@end

@interface _AJKDocumentationElement (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveType;
- (void)setPrimitiveType:(NSNumber*)value;

- (short)primitiveTypeValue;
- (void)setPrimitiveTypeValue:(short)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (int)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(int)value_;




- (NSString*)primitiveParentName;
- (void)setPrimitiveParentName:(NSString*)value;




- (NSString*)primitiveUrlString;
- (void)setPrimitiveUrlString:(NSString*)value;




- (NSObject*)primitiveUrl;
- (void)setPrimitiveUrl:(NSObject*)value;





- (AJKDocumentationSet*)primitiveDocumentationSet;
- (void)setPrimitiveDocumentationSet:(AJKDocumentationSet*)value;



- (AJKDocumentationElement*)primitiveParentElement;
- (void)setPrimitiveParentElement:(AJKDocumentationElement*)value;



- (NSMutableSet*)primitiveChildElements;
- (void)setPrimitiveChildElements:(NSMutableSet*)value;


@end
