class AJKViewController
	include AJKDocumentationStoreAccess
	attr_accessor :delegate

	def initWithNibName(name, bundle:bundle, windowController:windowController)
		super
		
		windowController.owner.addActionHandler(self)
		
		self
	end


	def makeFirstResponder(responder)
		window = self.view.window
		window.makeFirstResponder(responder) if window
	end

	# Forwards unsupported methods to the document or to the application controller

	def method_missing(symbol, *arguments, &block)
		if windowController.owner.respond_to?(symbol)
			windowController.owner.send symbol, *arguments, &block
		else
			super
		end
	end


	# Access common colors

	def headerColor
		NSColor.colorWithCalibratedHue(0.578, saturation:0.104, brightness:0.836, alpha:1.0)
	end

	def deactivatedColor
		NSColor.colorWithCalibratedHue(0.583, saturation:0.03, brightness:0.856, alpha:1.0)
	end
	
	def splitViewDividerColor
		NSColor.colorWithCalibratedHue(0.578, saturation:0.12, brightness:0.78, alpha:1.0)
	end


end