class AJKDocumentationStore
	include AJKEntityAccess
	attr_accessor :delegate, :storeURL
	
	# attr_accessor :managedObjectModel, :managedObjectContext, :persistentStoreCoordinator, :persistentStore

	def init
		super
		
		@managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
		@persistentStoreCoordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(@managedObjectModel)
	
		@managedObjectContext = NSManagedObjectContext.alloc.init
		@managedObjectContext.persistentStoreCoordinator = @persistentStoreCoordinator
		
		fileManager = NSFileManager.alloc.init
		@storeURL = fileManager.applicationSupportFolderURL(TRUE).URLByAppendingPathComponent('Documentation Store.sqlite')
		
		error = Pointer.new_with_type('@')
		@persistentStore = @persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:@storeURL, options:nil, error:error)
		error = error[0]
		
		@history = NSMutableArray.alloc.init
		
		
		if !@persistentStore && error
			case error.code
			
			when NSPersistentStoreIncompatibleVersionHashError
				error = NSError.errorWithDomain(:AJKDocumentationStoreError, code:1, userInfo:{
					NSLocalizedDescriptionKey => "Unable to read the Documentation Store".localizedString,
					NSLocalizedFailureReasonErrorKey => error.localizedFailureReason,
					NSLocalizedRecoveryOptionsErrorKey => ["Rebuild Index".localizedString]
				})
				
				NSAlert.displayAlertForError(error)
				fileManager.removeItemAtURL(@storeURL, error:nil)
				NSApplication.sharedApplication.delegate.rebuildIndex(self)
			else
				# Otherwise display the error
				NSAlert.displayAlertForError(error)
			end
		end
		
		NSNotificationCenter.defaultCenter.addObserver(self, selector:"mergeManagedObjectContexts:", name:NSManagedObjectContextDidSaveNotification, object:nil)
		
		self
	end


	def indexingOperationQueue
		@indexingOperationQueue ||= NSOperationQueue.alloc.init
	end
	

	def indexDocumentationSets(error)
		needToIndex = false
			
		documentationSetURLs = availableDocumentationSetURLs
		if documentationSetURLs && documentationSetURLs.count > 0
			documentationSetURLs.each do | documentationURL |
				documentationSet = documentationSetForURL(documentationURL)
				
				if !documentationSet.hasBeenIndexed || documentationSet.hasBeenIndexed.to_int == 0
					needToIndex = true
					startIndexingDocumentationSet(documentationSet)
				end
			end
		else
			error[0] = NSError.errorWithDomain(:AJKDocumentationStoreError, code:1, userInfo:{
				NSLocalizedDescriptionKey => "Couldn't find any documentation sets".localizedString,
			})
		end
		
		needToIndex
	end


	def availableDocumentationSetURLs
		documentationSetURLs = []
		documentationDirectoryURLs = [NSURL.fileURLWithPath('/Library/Developer/Documentation/DocSets')]
		fileManager = NSFileManager.alloc.init
		
		documentationDirectoryURLs.each do | documentationDirectoryURL |
			next unless fileManager.fileExistsAtPath(documentationDirectoryURL.path)
			
			errorPointer = Pointer.new_with_type('@')
			contentsOfDocumentationDirectory = fileManager.contentsOfDirectoryAtURL(documentationDirectoryURL, includingPropertiesForKeys:[NSURLIsDirectoryKey], options:0, error:errorPointer)
			
			if !contentsOfDocumentationDirectory
				NSAlert.displayAlertForError(errorPointer[0]) if errorPointer[0]
				next
			end
			
			contentsOfDocumentationDirectory.each do | documentationSetURL |
				documentationSetURLs << documentationSetURL if documentationSetURL and documentationSetURL.isDirectory and documentationSetURL.lastPathComponent.include?("CoreReference")
			end
		end
		
		documentationSetURLs
	end
	

	def startIndexingDocumentationSet(documentationSet)
		return unless documentationSet
		
		save
		currentlyIndexingIdentifiers = indexingOperationQueue.operations.collect { | operation | operation.documentationSetID }
		
		documentationSetID = documentationSet.objectID
		return if currentlyIndexingIdentifiers && currentlyIndexingIdentifiers.include?(documentationSetID)
		
		indexingOperation = AJKDocumentationIndexingOperation.alloc.initWithDocumentationSetIdentifier(documentationSetID, persistentStoreCoordinator:@persistentStoreCoordinator)
		indexingOperationQueue.addOperation(indexingOperation)
	end
	
	
	def resumeIndexingDocumentationSet(documentationSet)
		# Not yet
	end
	
	
	def cancelIndexing
		indexingOperationQueue.cancelAllOperations
	end


	def mergeManagedObjectContexts(notification)
		return unless notification && notification.object != @managedObjectContext
		
		# The notification may be triggered on any thread with a managed object context
		if NSThread.isMainThread
			@managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
		else
			performSelectorOnMainThread("mergeManagedObjectContexts:", withObject:notification, waitUntilDone:TRUE)
		end
	end


	# History

	def appendToHistory(element)
		return if element and @history.lastObject == element
		
		@history << element if element
	end


	def recentHistory
		numberOfRecentItems = NSUserDefaults.standardUserDefaults.integerForKey('AJKRecentItems')
		numberOfRecentItems = 20 if numberOfRecentItems <= 0
		
		recentHistory = @history.uniq
		recentHistory = recentHistory[0..numberOfRecentItems] if recentHistory.count > numberOfRecentItems
		recentHistory.reverse
	end


	# Retrieve various recent items

	def lastElementOfType(elementType)
		lastElementMatchingTypes([elementType])
	end


	def lastElementMatchingTypes(elementTypes)
		return nil if elementTypes.count <= 0
		lastElement = nil
		
		@history.reverse_each do | historyItem |
			if historyItem
				itemType = historyItem.type
				
				if elementTypes.index(itemType)
					lastElement = historyItem
					break
				end
			end
		end
		
		lastElement
	end


	def lastReferenceElement
		lastElementMatchingTypes(AJKEntityAccess.referenceTypes)
	end


	def lastDetailElement
		lastElementMatchingTypes(AJKEntityAccess.detailTypes)
	end


end