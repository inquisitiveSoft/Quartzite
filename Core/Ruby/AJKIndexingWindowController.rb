class AJKIndexingWindowController < XSWindowController
	attr_accessor :backgroundView, :progressItems, :progressItemsArrayController, :progressCollectionView


	def initWithWindowNibName(nibName)
		super
		@progressItems = NSMutableArray.array
		
		NSNotificationCenter.defaultCenter.addObserver(self, selector:'didFinishIndexing:', name:(:AJKDocumentationDidFinishIndexingNotification), object:nil)
		NSNotificationCenter.defaultCenter.addObserver(self, selector:'didCancelIndexing:', name:(:AJKDocumentationDidCancelIndexingNotification), object:nil)
		NSNotificationCenter.defaultCenter.addObserver(self, selector:'updateIndexingProgress:', name:(:AJKDocumentationIndexingProgressDidChangeNotification), object:nil)
		self
	end	


	def backgroundColor
		NSColor.colorWithCalibratedHue(0.596, saturation:0.045, brightness:0.847, alpha:1.0)
	end


	# 

	def presentAlertForError(error)
		puts "presentAlertForError: '#{error.description}'"
		
		if error
			window.makeKeyAndOrderFront(nil)
			
			item = progressItemForIdentifier('identifier')
			item.name = error.description
		end
	end


	def progressItemForIdentifier(identifier)
		progressItem = nil
		
		if identifier
			if @progressItems && @progressItems.count > 0
				@progressItems.each do | item |
					progressItem = item if item.uniqueIdentifier = identifier
					break if progressItem
				end
			end
			
			if !progressItem
				progressItem = AJKProgressStatus.alloc.init
				progressItem.uniqueIdentifier = identifier
				@progressItemsArrayController.addObject(progressItem)
			end
		end
		
		progressItem
	end


	def removeProgressItemForIdentifier(identifier)
		itemToRemove = nil
		@progressItems.each do | item |
			itemToRemove = item if item.uniqueIdentifier = identifier
			break if itemToRemove
		end
		
		@progressItemsArrayController.removeObject(itemToRemove) if itemToRemove
	end


	#

	def didStartLocatingReferences(notification)
		progressItem = progressItemForIdentifier(notification.userInfo[:AJKDocumentationURL])
		progressItem.name = 'Locating references for '.localizedString + notification.userInfo[:AJKDocumentationName]
		progressItem.progress = notification.userInfo[:AJKDocumentationIndexingProgress]
	end
	
	
	def didStartIndexing(notification)
		progressItem = progressItemForIdentifier(notification.userInfo[:AJKDocumentationURL])
		progressItem.name = 'Indexing '.localizedString + notification.userInfo[:AJKDocumentationName]
		updateIndexingProgress(notification)
	end
	
	
	def didFinishIndexing(notification)
		progressItem = progressItemForIdentifier(notification.userInfo[:AJKDocumentationURL])
		progressItem.progress = 1 if progressItem
		
		glassSound = NSSound.soundNamed('Glass')
		glassSound.play if glassSound
	end


	def didCancelIndexing(notification)
		removeProgressItemForIdentifier(notification.userInfo[:AJKDocumentationURL])
	end


	def updateIndexingProgress(notification)
		userInfo = notification.userInfo
		
		progressItem = progressItemForIdentifier(notification.userInfo[:AJKDocumentationURL])
		numberOfDocuments = notification.userInfo[:AJKDocumentationNumberOfDocuments].floatValue || 0
		numberOfIndexedDocuments = notification.userInfo[:AJKDocumentationNumberOfIndexedDocuments].floatValue || 0
		
		progressItem.progress = (numberOfIndexedDocuments / numberOfDocuments) if numberOfDocuments >= 1 && numberOfIndexedDocuments >= 1
	end

end


class AJKProgressStatus
	attr_accessor :progress, :name, :uniqueIdentifier

	def copyWithZone(zone)
		copy = super.copyWithZone(zone)
		
		copy.progress = @progress
		copy.name = @name
		copy.uniqueIdentifier = @uniqueIdentifier
		
		return copy
	end

end


class AJKCollectionView < NSCollectionView
	attr_accessor :alertPrototypeView


	def newItemForRepresentedObject(representedObject)
		puts "newItemForRepresentedObject: '#{representedObject.description}'"
		
		if representedObject.isKindOfClass(NSError)
			# representedObject
		end
		
		super
	end

end