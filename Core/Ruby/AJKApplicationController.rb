class AJKApplicationController
	attr_accessor :documentationStore, :currentElement
	attr_accessor :indexingWindowController
	attr_accessor :globalEventHandler, :localEventHandler
	attr_accessor :haveLoadedWebKit


	def init
		super
		
		haveLoadedWebKit = false
		
		self
	end


	def applicationDidFinishLaunching(notification)
		setupNotifications
		setupEventHandling
		presentIndexingWindowIfNecessary
	end


	def setupNotifications
		NSNotificationCenter.defaultCenter.addObserver(self, selector:'didStartIndexing:', name:(:AJKDocumentationDidStartIndexingNotification), object:nil)
		NSNotificationCenter.defaultCenter.addObserver(self, selector:'didStartLocatingReferences:', name:(:AJKDocumentationDidStartLocatingReferencesNotification), object:nil)
	end


	def setupEventHandling
		globalEventHandler = NSEvent.addGlobalMonitorForEventsMatchingMask(NSKeyDownMask, handler:Proc.new{ | event |			
			if event.commandAndOptionHeld.boolValue and event.charactersIgnoringModifiers == '/'
				NSApplication.sharedApplication.activateIgnoringOtherApps(true)
				self.focusFilterField(nil)
				nil
			else
				event
			end
		})
		
		localEventHandler = NSEvent.addLocalMonitorForEventsMatchingMask(NSKeyDownMask, handler:Proc.new{ | event |
			if event.commandAndOptionHeld.boolValue && event.charactersIgnoringModifiers == 'f'
				self.focusFilterField(nil)
				nil
			else
				event
			end
		})
	end


	#

	def applicationOpenUntitledFile(application)
		return presentIndexingWindowIfNecessary
	end


	def presentIndexingWindowIfNecessary
		error = Pointer.new_with_type('@')
		error[0] = nil
		
		return false unless documentationStore.indexDocumentationSets(error) or error[0]
		
		if !error[0]
			indexingWindowController.showWindow(nil)
		elsif error[0].code == 1
				indexingWindowController.presentAlertForError(error[0])
		else
			NSAlert.presentAlertForError(error[0])
		end
		
		true
	end


	def presentLoadingOverlayIfNecessary
		if !haveLoadedWebKit
			
		end
		
		haveLoadedWebKit = true
	end


	# def applicationShouldHandleReopen(application, hasVisibleWindows:flag)
	# 	
	# end


	def applicationShouldTerminateAfterLastWindowClosed(application)
		false
	end


	def applicationWillTerminate(notification)
		documentationStore.cancelIndexing		# Give any indexing operation the opportunity to save
	end


	def presentDocumentationForElement(element)
		document = activeDocument
		document.showWindows
		document.displayDocumentationForElement(element)
	end


	def documentationStore
		@documentationStore ||= AJKDocumentationStore.alloc.init
	end


	def documentController
		@documentController ||= AJKDocumentController.alloc.init
	end


	def indexingWindowController
		@indexingWindowController ||= AJKIndexingWindowController.alloc.initWithWindowNibName('Indexing Window')
	end


	def presentIndexingWindow
		indexingWindowController.showWindow(nil)
	end


	# Indexing

	def shouldIndex
		documentationSets = documentationStore.allDocumentationSets
		
		needsIndexing = false
		documentationSets.each { | documentation |
			if !documentation.hasBeenIndexed
				needsIndexing =  true
				break
			end
		}
		
		return true
	end


	def rebuildIndex(sender)
		@documentationStore = nil
		
		presentIndexingWindow if documentationStore.indexDocumentationSets
	end


	def didStartLocatingReferences(notification)
		presentIndexingWindow
		presentIndexingWindow.didStartLocatingReferences(notification)
	end


	def didStartIndexing(notification)
		presentIndexingWindow
		indexingWindowController.indexingViewController.didStartIndexing(notification)
		
		NSNotificationCenter.defaultCenter.addObserver(self, selector:'didFinishIndexing:', name:(:AJKDocumentationDidFinishIndexingNotification), object:nil)
		NSNotificationCenter.defaultCenter.addObserver(self, selector:'didCancelIndexing:', name:(:AJKDocumentationDidCancelIndexingNotification), object:nil)
	end


	def didFinishIndexing(notification)
		focusFilterField(nil)
	end


	def didCancelIndexing(notification)
		raise 'AJKApplicationController needs to handle didCancelIndexing"'
	end


	def activeDocument
		currentDocument = documentController.currentDocument
		currentDocument ||= documentController.documents.objectAtUntestedIndex(0)
	
		error = Pointer.new_with_type('@')
		currentDocument ||= documentController.openUntitledDocumentAndDisplay(true, error:error)
		
		return currentDocument
	end


	def focusFilterField(sender)
		document = activeDocument
		document.showWindows
		document.focusFilterField(nil)
	end


	def goForward(sender)
		document = documentController.currentDocument
		document.goForward(sender)
	end

	def goBack(sender)
		document = documentController.currentDocument
		document.goBack(sender)
	end


	def validateUserInterfaceItem(userInterfaceItem)
		return false unless userInterfaceItem.action
		
		case userInterfaceItem.action.to_s
		when 'goForward:'
			currentDocument = documentController.currentDocument
			currentDocument and currentDocument.canGoForward
		when 'goBack:'
			currentDocument = documentController.currentDocument
			currentDocument and currentDocument.canGoBack
		else
			false		# The application delegate is last in the responder chain, so no nextResponder to ask
		end
	end


end