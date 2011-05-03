class AJKReferencesDocument < NSDocument
	attr_accessor :tabs, :currentTab
	attr_accessor :currentElement
	attr_accessor :mainWebView


	def readFromURL(absoluteURL, ofType:typeName, error:outError)
		super
		
		puts "readFromURL: '#{absoluteURL.urlString}'"
		
		self
	end


	def writeToURL(absoluteURL, ofType:typeName, error:outError)
		super
		
		puts "writeToURL: '#{absoluteURL.urlString}'"
		
		self
	end



	# Document window
	
	def windowNibName
		'Document Window'
	end

	def makeWindowControllers
		if !@documentationWindowController
			@documentationWindowController = AJKDocumentationWindowController.alloc.initWithWindowNibName(windowNibName, owner:self)
			addWindowController(@documentationWindowController)
		end
	end


	def tabs
		@tabs ||= []
	end


	def actionHandlers
		@actionHandlers ||= []
	end

	def addActionHandler(actionHandler)
		actionHandlers << actionHandler
	end
	
	def removeActionHandler(actionHandler)
		actionHandlers.removeObject(actionHandler) if actionHandler
	end


	def method_missing(symbol, *arguments, &block)	
		showWindows
		
		actionHandlers.each do | descendant |
			return descendant.send(symbol, *arguments, &block) if descendant.respond_to?(symbol)
		end
		
		super
	end


	def displayDocumentationForElement(element)
		displayDocumentationForURL(element ? element.url : nil)
	end


end