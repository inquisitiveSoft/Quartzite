# Notifications related to indexing documentation
:AJKDocumentationDidStartLocatingReferencesNotification

:AJKDocumentationDidStartIndexingNotification
:AJKDocumentationDidCancelIndexingNotification
:AJKDocumentationDidFinishIndexingNotification
:AJKDocumentationIndexingProgressDidChangeNotification

# Keys used in the userInfo dictionaries
:AJKDocumentationName
:AJKDocumentationURL
:AJKDocumentationNumberOfDocuments
:AJKDocumentationNumberOfIndexedDocuments
:AJKDocumentationIndexingProgress

AJKFilterIntervalDefault = 'AJKFilterIntervalDefault'


class AJKDocumentationIndexingOperation < NSOperation
	include AJKEntityAccess

	def initWithDocumentationSetIdentifier(identifier, persistentStoreCoordinator:persistentStoreCoordinator)
		init
			
		raise "Can't create a AJKDocumentationIndexingOperation without a valid managed object identifier" unless identifier.isKindOfClass(NSManagedObjectID)
		@documentationSetID = identifier
		@persistentStoreCoordinator = persistentStoreCoordinator
		
		self
	end
	
	def documentationSetID
		@documentationSetID ||= nil
	end
	

	def main
		NSProcessInfo.processInfo.disableSuddenTermination
		@managedObjectContext = NSManagedObjectContext.new
		@managedObjectContext.undoManager = nil
		@managedObjectContext.persistentStoreCoordinator = @persistentStoreCoordinator
		
		documentationSet = @managedObjectContext.existingObjectWithID(documentationSetID, error:nil)
		raise "Couldn't find a documentation set object for the #{documentationSetID} identifier" unless documentationSet
		
		# Look for reference html files within the documentation set
		documentsToIndex = referencesWithinDocumentationSet(documentationSet)
		numberOfDocuments = documentsToIndex.count
		return if numberOfDocuments == 0
		
		# If were resuming a previous indexing operation then start from the last saved point
		# This assumes that the urls contained in the documentsToIndex array are ordered in a reproducible way
		lastProgressNotificationPoint = 0
		numberOfIndexedDocuments = documentationSet.numberOfIndexedDocuments || 0
		lastSavePoint = numberOfIndexedDocuments
		documentsToIndex = documentsToIndex[numberOfIndexedDocuments..-1] if numberOfIndexedDocuments > 0 and numberOfIndexedDocuments < documentsToIndex.count
		
		
		Dispatch::Queue.main.sync do
			NSNotificationCenter.defaultCenter.postNotificationName(:AJKDocumentationDidStartIndexingNotification, object:documentationSet.objectID, userInfo:{
																															:AJKDocumentationName => documentationSet.name,
																															:AJKDocumentationURL => documentationSet.url,
																															:AJKDocumentationNumberOfDocuments => numberOfDocuments,
																															:AJKDocumentationNumberOfIndexedDocuments => numberOfIndexedDocuments
																																})
		end
		
		
		documentsToIndex.each do | documentationFileURL |
			break if isCancelled	# Stop indexing if the operation has been canceled
			
			
			if numberOfIndexedDocuments > lastProgressNotificationPoint + 10
				lastProgressNotificationPoint = numberOfIndexedDocuments
				
				Dispatch::Queue.main.sync do
					NSNotificationCenter.defaultCenter.postNotificationName(:AJKDocumentationIndexingProgressDidChangeNotification, object:documentationSet.objectID, userInfo:{
																																	:AJKDocumentationName => documentationSet.name,
																																	:AJKDocumentationURL => documentationSet.url,
																																	:AJKDocumentationNumberOfDocuments => numberOfDocuments,
																																	:AJKDocumentationNumberOfIndexedDocuments => numberOfIndexedDocuments
																																		})
				end
			end
			
			
			# Read in the html document
			htmlDocument = TFHpple.alloc.initWithHTMLData(NSData.dataWithContentsOfURL(documentationFileURL))
			next unless htmlDocument
			
			referenceNameElement = htmlDocument.search('/html/body/article/a[starts-with(@name, \'//apple_ref/occ/\')]').objectAtUntestedIndex(0)
			next unless referenceNameElement
			
			referenceElement = elementForReferencePath(referenceNameElement.objectForKey('name'), inDocumentationSet:documentationSet)
			referenceElement.url = documentationFileURL
			referenceElement.urlString = documentationFileURL.absoluteString
			
			# # Currently not bothering to look for a class structure
			# if referenceElement.type == DOCUMENTATION_TYPE_CLASS
			# 	superclassesLinkElements = htmlDocument.search('//*[@class="InheritsFrom"]/ancestor::td/following-sibling::td//a[@href]')
			# 
			# 	superclassesLinkElements.each do | superclass |
			# 		puts "superclass: '#{superclass.description}'"
			# 	end
			# end
			
			parentElement = AJKEntityAccess.referenceTypes.include?(referenceElement.type) ? referenceElement : nil
			childElements = htmlDocument.search("//*[@id='Tasks_section']//a[contains(@href, '//apple_ref/occ/')]")
			
			childElements.each do | childElement |
				child = elementForReferencePath(childElement.objectForKey('href'), withParentElement:parentElement, inDocumentationSet:documentationSet)
			end
			
			
			numberOfIndexedDocuments += 1
			
			if numberOfIndexedDocuments > lastSavePoint + 50
				lastSavePoint = numberOfIndexedDocuments
				documentationSet.numberOfIndexedDocuments = numberOfIndexedDocuments
				
				documentationSet.indexingProgress = numberOfIndexedDocuments.floatValue/numberOfDocuments.floatValue
				save
			end
		end
		
		
		
				
		if !isCancelled
			documentationSet.hasBeenIndexed = true
			documentationSet.indexingProgress = 0			
			documentationSet.numberOfIndexedDocuments = 0
			save
		
			Dispatch::Queue.main.sync do
				NSNotificationCenter.defaultCenter.postNotificationName(:AJKDocumentationDidFinishIndexingNotification, object:documentationSet.objectID, userInfo:{
																																:AJKDocumentationName => documentationSet.name,
																																:AJKDocumentationURL => documentationSet.url,
																																:AJKDocumentationNumberOfDocuments => numberOfDocuments
																																	})
			end
		else
			documentationSet.numberOfIndexedDocuments = numberOfIndexedDocuments
			documentationSet.indexingProgress = numberOfIndexedDocuments/numberOfDocuments			
			save
		
			Dispatch::Queue.main.sync do
				NSNotificationCenter.defaultCenter.postNotificationName(:AJKDocumentationDidCancelIndexingNotification, object:documentationSet.objectID, userInfo:{
																																:AJKDocumentationName => documentationSet.name,
																																:AJKDocumentationURL => documentationSet.url
																																	})
			end
		end
		
		NSProcessInfo.processInfo.enableSuddenTermination
	end



	def referencesWithinDocumentationSet(documentationSet)
		return nil unless documentationSet
		
		Dispatch::Queue.main.sync do
			NSNotificationCenter.defaultCenter.postNotificationName(:AJKDocumentationDidStartLocatingReferencesNotification, object:documentationSet.objectID, userInfo:{
																															:AJKDocumentationName => documentationSet.name,
																															:AJKDocumentationURL => documentationSet.url,
																															:AJKDocumentationIndexingProgress => documentationSet.indexingProgress
																																})
		end
		
		
		documentationDirectoryEnumerator = NSFileManager.defaultManager.enumeratorAtURL(documentationSet.url, includingPropertiesForKeys:[NSURLIsDirectoryKey, NSURLIsRegularFileKey, NSURLLocalizedNameKey, NSURLTypeIdentifierKey], options:(NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles), errorHandler:nil)
	
		filesToIgnore = ['toc.html', 'History.html', 'index_of_book.html', 'RevisionHistory.html', 'revision_history.html']
		directoriesToIgnore = ['Conceptual', 'History', 'DeveloperTools', 'gcc', 'qa', 'samplecode', 'gdb', 'SafariWebContent', 'FoundationRefUpdate', 'RefUpdate']
		documentsToIndex = NSMutableArray.alloc.init
	
		while url = documentationDirectoryEnumerator.nextObject do
			next unless url.pathExtension.isEqualToString('html')
			fileName = url.lastPathComponent		# It would be better to use pre-cached url keys
		
			if filesToIgnore.include?(fileName) || directoriesToIgnore.include?(fileName)
				documentationDirectoryEnumerator.skipDescendants
				next
			end
			
			# Ignore the index.html file if a Reference/Reference.html file exists
			if fileName == 'index.html'
				directoryURL = url.URLByDeletingLastPathComponent
				next if NSFileManager.defaultManager.fileExistsAtPath(directoryURL.path.stringByAppendingPathComponent('Reference/Reference.html')) or NSFileManager.defaultManager.fileExistsAtPath(directoryURL.path.stringByAppendingPathComponent('CompositePage.html'))
			end
			
			documentsToIndex << url
		end
		
		documentsToIndex
	end


	def elementForReferencePath(path, inDocumentationSet:documentationSet)
		elementForReferencePath(path, withParentElement:nil, inDocumentationSet:documentationSet)
	end
	
	
	def elementForReferencePath(path, withParentElement:parentElement, inDocumentationSet:documentationSet)
		return nil unless path && path.length > 4
		
		pathComponents = path.gsub(/^#*\/*/, '').pathComponents		# Remove any # or / characters from the start of the path
		numberOfPathComponents = pathComponents.count
		return nil unless numberOfPathComponents >= 4
		
		name = pathComponents[3]
		return nil unless name and name.length > 0
		
		type = case pathComponents[2]
			when 'cl'
				DOCUMENTATION_TYPE_CLASS
			when 'cat'
				DOCUMENTATION_TYPE_CATEGORY
			when 'clm', 'intfcm'
				DOCUMENTATION_TYPE_CLASS_METHOD
			when 'instm', 'intfm'
				DOCUMENTATION_TYPE_INSTANCE_METHOD
			when 'instp'
				DOCUMENTATION_TYPE_INSTANCE_PROPERTY
			when 'intf'
				DOCUMENTATION_TYPE_PROTOCOL
			when 'binding'
				DOCUMENTATION_TYPE_BINDING
			else
				# Warn if we find an unexpected element type, ignoring depreciation appendixes for now
				puts "Encountered unidentified element type: '#{pathComponents[2]}' with path: #{path}"	unless path.include?('DeprecationAppendix')
				DOCUMENTATION_TYPE_UNIDENTIFIED
		end
		return nil if type == DOCUMENTATION_TYPE_UNIDENTIFIED
			
		
		case type
			when DOCUMENTATION_TYPE_CLASS_METHOD, DOCUMENTATION_TYPE_INSTANCE_METHOD, DOCUMENTATION_TYPE_INSTANCE_PROPERTY
				return nil unless numberOfPathComponents >= 4
				name = pathComponents[4]
		end
		
		# Look for an existing element with that name, parent element, and type within the current documentation set
		existingElements = findObjectsOfEntity(elementEntity, matchingFormat:'documentationSet == %@ && type == %@ && parentElement == %@ && name == %@', withArguments:[documentationSet, type, parentElement, name])
		existingElement = existingElements ? existingElements.objectAtUntestedIndex(0) : nil
		return existingElement if existingElement
		
		# Otherwise create a new element
		element = AJKDocumentationElement.alloc.initWithEntity(elementEntity, insertIntoManagedObjectContext:@managedObjectContext)
		element.documentationSet = documentationSet
		element.name = name
		element.type = type
		
		# Locate it in the hierarchy
		if parentElement
			element.parentElement = parentElement
			element.parentName = parentElement.name
			
			parentURL = parentElement.url
			
			if parentURL
				url = NSURL.URLWithString(path, relativeToURL:parentURL)
				element.url = url
				element.urlString = url.absoluteString
			end
		end
		
		return element
	end


end