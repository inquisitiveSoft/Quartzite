class AJKDocumentationWindowController < XSWindowController
	include AJKDocumentationStoreAccess


	def windowDidLoad
		window.delegate = self
		window.setMovableByWindowBackground(true)
		
		attachToolbarWindow
		window.setContentView(splitViewController.view)
	end


	def windowTitleForDocumentDisplayName(displayName)
		''
	end


	def splitViewController
		@splitViewController ||= AJKSplitViewController.alloc.initWithNibName('Split View', bundle:nil, windowController:self)
	end



	# Toolbar methods

	def toolbarViewController
		@toolbarViewController ||= AJKToolbarViewController.alloc.initWithNibName('Toolbar View', bundle:nil, windowController:self)
	end


	def toolbarFrame
		toolbarView = toolbarViewController.view
		
		if toolbarView
			windowFrame = self.window.frame
			
			toolbarFrame = toolbarView.bounds
			toolbarFrame.origin.x = windowFrame.origin.x + windowFrame.size.width - toolbarFrame.size.width - 65
			toolbarFrame.origin.y = windowFrame.origin.y + windowFrame.size.height - toolbarFrame.size.height - 4
			toolbarFrame
		else
			NSZeroRect
		end
	end


	def attachToolbarWindow
		if !@toolbarWindow
			toolbarView = toolbarViewController.view
			raise "attachToolbarWindow: Can't find the view for the document windows toolbar" if !toolbarView
			
			@toolbarWindow = NSWindow.alloc.initWithContentRect(toolbarFrame, styleMask:NSBorderlessWindowMask, backing:NSBackingStoreBuffered, defer:TRUE)
			@toolbarWindow.setContentView(toolbarView)
			@toolbarWindow.setOpaque(false)
			@toolbarWindow.backgroundColor = NSColor.clearColor
			@toolbarWindow.ignoresMouseEvents = false
			
			window.addChildWindow(@toolbarWindow, ordered:NSWindowAbove)
			@toolbarWindow.orderFront(self)
		end
	end


	def removeToolbarWindow
		if @toolbarWindow
			@toolbarWindow.orderOut(self)
			self.window.removeChildWindow(@toolbarWindow)
			@toolbarViewController, @toolbarWindow = nil
		end
	end



	# Menu actions

	def focusFilterField(sender)
		splitViewController.searchPaneController.focusFilterField(sender)
	end

	def pasteToFilterField(sender)
		splitViewController.searchPaneController.pasteToFilterField(sender)
	end


	def jumpToNextCategory(sender)
		splitViewController.searchPaneController.jumpToNextCategory(sender)
	end
	
	def jumpToPreviousCategory(sender)
		splitViewController.searchPaneController.jumpToPreviousCategory(sender)
	end
	
	def focusDetailsOutlineView(sender)
		splitViewController.searchPaneController.focusDetailsOutlineView(sender)
	end
	
	def focusReferencesOutlineView(sender)
		splitViewController.searchPaneController.focusReferencesOutlineView(sender)
	end
	
	def focusDocumentationWebView(sender)
		self.window.makeFirstResponder(splitViewController.referencePaneController.webView)
	end
	
	def toggleDetailMode(sender)
		splitViewController.searchPaneController.toggleDetailMode(sender)
	end


	def performTextFinderAction(sender)
		splitViewController.performTextFinderAction(sender)
	end

	def copySelectedElement(sender)
		splitViewController.searchPaneController.copySelectedElement(sender)
	end


	def displayRecentHistory(sender)
		puts documentationStore.recentHistory.collect { | historyElement | historyElement.name }.description
	end


	# Window delegate methods

	def windowDidResize(notification)
		@toolbarWindow.setFrame(toolbarFrame, display:true, animate:false) if @toolbarWindow and @toolbarWindow.parentWindow == window
	end


	# Methods relating to being displayed fullscreen

	def customWindowsToEnterFullScreenForWindow(window)
		[window]
	end


	# def window(window, startCustomAnimationToEnterFullScreenWithDuration:duration)
	# 	window.setFrame(window.screen.frame, display:true, animate:true)
	# end


end