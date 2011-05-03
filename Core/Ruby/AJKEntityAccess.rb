module AJKEntityAccess

	DOCUMENTATION_TYPE_UNIDENTIFIED = 0
	DOCUMENTATION_TYPE_CLASS = 1
	DOCUMENTATION_TYPE_CATEGORY = 2
	DOCUMENTATION_TYPE_CLASS_METHOD = 3
	DOCUMENTATION_TYPE_INSTANCE_METHOD = 4
	DOCUMENTATION_TYPE_INSTANCE_PROPERTY = 5
	DOCUMENTATION_TYPE_PROTOCOL = 6
	DOCUMENTATION_TYPE_PROTOCOL_CLASS_METHOD = 7
	DOCUMENTATION_TYPE_BINDING = 8


	def self.nameForType(type)
		case type
			when DOCUMENTATION_TYPE_UNIDENTIFIED
				"Unidentified Type"
			when DOCUMENTATION_TYPE_CLASS
				"Classes"
			when DOCUMENTATION_TYPE_CATEGORY
				"Categories"
			when DOCUMENTATION_TYPE_CLASS_METHOD
				"Class Methods"
			when DOCUMENTATION_TYPE_INSTANCE_METHOD
				"Instance Methods"
			when DOCUMENTATION_TYPE_INSTANCE_PROPERTY
				"Properties"
			when DOCUMENTATION_TYPE_PROTOCOL
				"Protocols"
			when DOCUMENTATION_TYPE_BINDING
				"Bindings"
		end
	end
	
	
	def self.referenceTypes
		@referenceTypes ||= [AJKEntityAccess::DOCUMENTATION_TYPE_CLASS,
											  AJKEntityAccess::DOCUMENTATION_TYPE_CATEGORY,
											  AJKEntityAccess::DOCUMENTATION_TYPE_PROTOCOL,
		 									  AJKEntityAccess::DOCUMENTATION_TYPE_BINDING]
	end

	def self.detailTypes
		@detailTypes ||= [AJKEntityAccess::DOCUMENTATION_TYPE_CLASS_METHOD,
										 AJKEntityAccess::DOCUMENTATION_TYPE_INSTANCE_METHOD,
										 AJKEntityAccess::DOCUMENTATION_TYPE_INSTANCE_PROPERTY]
	end	
	
	
	def self.elementTypes
		@elementTypes ||= referenceTypes + detailTypes
	end
	

	def save
		# Must be called from the same thread as the managedObjectContext
		error = Pointer.new_with_type('@')
		NSAlert.displayAlertForError(error[0]) unless @managedObjectContext.save(error[0])
	end


	# Entities
	def documentationSetEntity
		@documentationSetEntity ||= NSEntityDescription.entityForName("DocumentationSet", inManagedObjectContext:@managedObjectContext)
	end

	def elementEntity
		@elementEntity ||= NSEntityDescription.entityForName("DocumentationElement", inManagedObjectContext:@managedObjectContext)
	end
	
	def characterNodeEntity
		@characterNodeEntity ||= NSEntityDescription.entityForName("CharacterNode", inManagedObjectContext:@managedObjectContext)
	end
	
	
	# Find entities
	def allObjectsOfEntity(entity)
		findObjectsOfEntity(entity, matchingFormat:nil, withArguments:nil)
	end
	
	def findObjectsOfEntity(entity, matchingFormat:format, withArguments:argumentArray)
		findObjectsOfEntity(entity, matchingFormat:format, withArguments:argumentArray, fetchLimit:nil)
	end
	
	def findObjectsOfEntity(entity, matchingFormat:format, withArguments:argumentArray, fetchLimit:fetchLimit)
		if !entity
			puts "Can't execute a fetch request without an entity"
			return
		end
		
		fetchRequest = NSFetchRequest.alloc.init;
		fetchRequest.entity = entity
		fetchRequest.predicate = NSPredicate.predicateWithFormat(format, argumentArray:argumentArray) if format
		fetchRequest.fetchLimit = fetchLimit if fetchLimit and fetchLimit > 0
		
		error = Pointer.new_with_type('@')
		results = @managedObjectContext.executeFetchRequest(fetchRequest, error:error)
		NSAlert.displayAlertForError(error[0]) if error[0]
		
		results
	end
	
	
	def numberOfObjectsOfEntity(entity)
		numberOfObjectsOfEntity(entity, matchingFormat:nil, withArguments:nil)
	end
	
	
	def numberOfObjectsOfEntity(entity, matchingFormat:format, withArguments:argumentArray)
		if !entity
			puts "Can't execute a fetch request without an entity"
			return
		end
		
		fetchRequest = NSFetchRequest.alloc.init;
		fetchRequest.entity = entity
		fetchRequest.predicate = NSPredicate.predicateWithFormat(format, argumentArray:argumentArray) if format
		
		error = Pointer.new_with_type('@')
		numberOfResults = @managedObjectContext.countForFetchRequest(fetchRequest, error:error)
		NSAlert.displayAlertForError(error[0]) if error[0]
		
		numberOfResults
	end
	
	
	# Find specific entities
	
	def numberOfDocumentationSets
		numberOfObjectsOfEntity(documentationSetEntity)
	end
	
	def allDocumentationSets
		allObjectsOfEntity(documentationSetEntity)
	end


	def numberOfDocumentationElements
		numberOfObjectsOfEntity(self.elementEntity)
	end
	
	def allDocumentationElements
		allObjectsOfEntity(self.elementEntity)
	end


	def numberOfCharacterNodes
		numberOfObjectsOfEntity(self.characterNodeEntity)
	end
	
	def allCharacterNodes
		allObjectsOfEntity(self.characterNodeEntity)
	end
	
	
	# Find specific element types
	
	def numberOfClasses
		numberOfObjectsOfEntity(self.elementEntity, matchingFormat:'type == %@', withArguments:[DOCUMENTATION_TYPE_CLASS])
	end
	
	def allClasses
		findObjectsOfEntity(self.elementEntity, matchingFormat:'type == %@', withArguments:[DOCUMENTATION_TYPE_CLASS])
	end


	def documentationSetForURL(documentationURL)
		return nil unless documentationURL
		documentationSetProperties = NSDictionary.dictionaryWithContentsOfURL(documentationURL.URLByAppendingPathComponent('Contents/Info.plist'))
		return nil unless documentationSetProperties or documentationSetProperties['DocSetPublisherIdentifier'] == 'com.apple.adc.documentation'
		
		bundleIdentifier = documentationSetProperties['CFBundleIdentifier']
		version = NSDecimalNumber.decimalNumberWithString(documentationSetProperties['CFBundleVersion']);
		
		documentationSet = documentationSetForBundleIdentifier(bundleIdentifier, version:version)
		
		if documentationSet
			documentationSet.url ||= documentationURL
			documentationSet.properties = documentationSetProperties
			documentationSet.name = documentationSetProperties['CFBundleName']
			documentationSet.family = documentationSetProperties['DocSetPlatformFamily']
			documentationSet.platformVersion = documentationSetProperties['DocSetPlatformVersion']
			documentationSet.version = version
		end
		
		documentationSet
	end


	def documentationSetForBundleIdentifier(bundleIdentifier, version:version)
		return unless (bundleIdentifier.length > 0) && !bundleIdentifier.include?('AppleXcode')
		
		# Find out if a managed object already exists for this documentation set
		existingDocumentationSets = case version
		when nil
			findObjectsOfEntity(documentationSetEntity, matchingFormat:'bundleIdentifier == %@', withArguments:[bundleIdentifier])
		else
			findObjectsOfEntity(documentationSetEntity, matchingFormat:'bundleIdentifier == %@ and version == %@', withArguments:[bundleIdentifier, version])
		end
		
		return existingDocumentationSets.objectAtUntestedIndex(0) if existingDocumentationSets && existingDocumentationSets.count > 0
		
		# Otherwise create a new one with the hasBeenIndexed flag set to FALSE
		newDocumentationSet = AJKDocumentationSet.alloc.initWithEntity(documentationSetEntity, insertIntoManagedObjectContext:@managedObjectContext)
		newDocumentationSet.bundleIdentifier = bundleIdentifier
		newDocumentationSet.version = version
		newDocumentationSet.hasBeenIndexed = false
		
		return newDocumentationSet
	end


	def findElementsOfType(documentationType, matchingString:filterString)
		return allClasses unless filterString && filterString.length > 0
		
		filterRegex = filterString.split(//).join(".*") if filterString.length > 1
		filterRegex = "(?i).*" + filterRegex + ".*"
		
		fetchLimit = (filterString.length <= 1) ? 100 : nil
		findObjectsOfEntity(self.elementEntity, matchingFormat:"type == %@ && name matches %@", withArguments:[documentationType, filterRegex], fetchLimit:fetchLimit)
	end
	
	
	def findElementsMatchingString(filterString)
		return allDocumentationElements unless filterString && filterString.length > 0
		
		fetchLimit = (filterString.length <= 1) ? 100 : nil
		
		filterString = filterString.split(//).join(".*") if filterString.length > 1
		filterString = "(?i).*" + filterString + ".*"
		findObjectsOfEntity(self.elementEntity, matchingFormat:"name matches %@", withArguments:[filterString], fetchLimit:fetchLimit)
	end


end



module AJKDocumentationStoreAccess

	def documentationStore
		appDelegate = NSApplication.sharedApplication.delegate
		raise "Couldn't find a vali application delegate" unless appDelegate.isKindOfClass(AJKApplicationController)
		
		appDelegate.documentationStore
	end

end
