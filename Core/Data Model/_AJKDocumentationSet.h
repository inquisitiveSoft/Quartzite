// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AJKDocumentationSet.h instead.

#import <CoreData/CoreData.h>


@class AJKDocumentationElement;

@class NSObject;








@class NSObject;

@interface AJKDocumentationSetID : NSManagedObjectID {}
@end

@interface _AJKDocumentationSet : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (AJKDocumentationSetID*)objectID;



@property (nonatomic, retain) NSObject *properties;

//- (BOOL)validateProperties:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *family;

//- (BOOL)validateFamily:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *platformVersion;

//- (BOOL)validatePlatformVersion:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *indexingProgress;

@property float indexingProgressValue;
- (float)indexingProgressValue;
- (void)setIndexingProgressValue:(float)value_;

//- (BOOL)validateIndexingProgress:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *bundleIdentifier;

//- (BOOL)validateBundleIdentifier:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *numberOfIndexedDocuments;

@property int numberOfIndexedDocumentsValue;
- (int)numberOfIndexedDocumentsValue;
- (void)setNumberOfIndexedDocumentsValue:(int)value_;

//- (BOOL)validateNumberOfIndexedDocuments:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDecimalNumber *version;

//- (BOOL)validateVersion:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *hasBeenIndexed;

@property BOOL hasBeenIndexedValue;
- (BOOL)hasBeenIndexedValue;
- (void)setHasBeenIndexedValue:(BOOL)value_;

//- (BOOL)validateHasBeenIndexed:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSObject *url;

//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* references;
- (NSMutableSet*)referencesSet;




@end

@interface _AJKDocumentationSet (CoreDataGeneratedAccessors)

- (void)addReferences:(NSSet*)value_;
- (void)removeReferences:(NSSet*)value_;
- (void)addReferencesObject:(AJKDocumentationElement*)value_;
- (void)removeReferencesObject:(AJKDocumentationElement*)value_;

@end

@interface _AJKDocumentationSet (CoreDataGeneratedPrimitiveAccessors)


- (NSObject*)primitiveProperties;
- (void)setPrimitiveProperties:(NSObject*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveFamily;
- (void)setPrimitiveFamily:(NSString*)value;




- (NSString*)primitivePlatformVersion;
- (void)setPrimitivePlatformVersion:(NSString*)value;




- (NSNumber*)primitiveIndexingProgress;
- (void)setPrimitiveIndexingProgress:(NSNumber*)value;

- (float)primitiveIndexingProgressValue;
- (void)setPrimitiveIndexingProgressValue:(float)value_;




- (NSString*)primitiveBundleIdentifier;
- (void)setPrimitiveBundleIdentifier:(NSString*)value;




- (NSNumber*)primitiveNumberOfIndexedDocuments;
- (void)setPrimitiveNumberOfIndexedDocuments:(NSNumber*)value;

- (int)primitiveNumberOfIndexedDocumentsValue;
- (void)setPrimitiveNumberOfIndexedDocumentsValue:(int)value_;




- (NSDecimalNumber*)primitiveVersion;
- (void)setPrimitiveVersion:(NSDecimalNumber*)value;




- (NSNumber*)primitiveHasBeenIndexed;
- (void)setPrimitiveHasBeenIndexed:(NSNumber*)value;

- (BOOL)primitiveHasBeenIndexedValue;
- (void)setPrimitiveHasBeenIndexedValue:(BOOL)value_;




- (NSObject*)primitiveUrl;
- (void)setPrimitiveUrl:(NSObject*)value;





- (NSMutableSet*)primitiveReferences;
- (void)setPrimitiveReferences:(NSMutableSet*)value;


@end
