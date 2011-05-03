class AJKSplitViewController < AJKViewController
	attr_accessor :toolbarPaneController, :searchPaneController, :referencePaneController
	attr_accessor :mainSplitView, :toolbarPaneContainerView, :searchPaneContainerView, :referencePaneContainerView
	attr_accessor :documentationSetButton, :documentationSetButtonContainer, :tabBar


	def initWithNibName(nibName, bundle:bundle, windowController:windowController)
		super
		
		self.loadView
		@mainSplitView.delegate = self
		
		# Load the main reference pane
		@referencePaneController = AJKReferencePaneController.alloc.initWithNibName('Reference Pane', bundle:nil, windowController:windowController)
		@referencePaneController.delegate = self
		@referencePaneController.view.frame = @referencePaneContainerView.bounds
		@referencePaneContainerView.addSubview(@referencePaneController.view)
		
		# Load the search pane
		@searchPaneController = AJKSearchPaneController.alloc.initWithNibName('Search Pane', bundle:nil, windowController:windowController)
		@searchPaneController.delegate = self
		@searchPaneController.view.frame = @searchPaneContainerView.bounds
		@searchPaneContainerView.addSubview(@searchPaneController.view)
		
		# Set the documentation sets button style
		documentationSetButtonContainer.backgroundImage = documentationSetBackgroundImageBlock.call(headerColor)
		documentationSetButtonContainer.deactivatedBackgroundImage = documentationSetBackgroundImageBlock.call(deactivatedColor)
		documentationSetButton.image = NSImage.imageNamed("Documentation Popup Arrow")
		
		updateDocumentationSetButton
		
		self
	end


	def performTextFinderAction(sender)
		referencePaneController.performTextFinderAction(sender)
	end


	# Documentation set selection UI

	def updateDocumentationSetButton
		# documentationSet = selectedDocumentationSet
		documentationSet = documentationStore.documentationSetForBundleIdentifier('com.apple.adc.documentation.AppleSnowLeopard.CoreReference', version:nil)
		attributedTitle = attributedTitleForDocumentationSet(documentationSet)
		attributedTitle.addAttributes(documentationSetButtonAttributes, range:NSMakeRange(0, attributedTitle.length))
		
		documentationSetButton.setAttributedTitle(attributedTitle)
	end


	def attributedTitleForDocumentationSet(documentationSet)
		case documentationSet
		when nil
			NSAttributedString.alloc.initWithString('None'.localizedString, attributes:disabledDocumentationSetNameAttributes)
		else
			title = NSMutableAttributedString.alloc.initWithString(documentationSet.simpleName, attributes:documentationSetNameAttributes)
			version = documentationSet.simpleVersion
			
			if version
				versionAttributedString = NSAttributedString.alloc.initWithString("  #{version}", attributes:documentationSetVersionAttributes)
				title.appendAttributedString(versionAttributedString)
			end
			
			title
		end
	end


	def displayDocumentationSetMenu(sender)
		selectedDocumentationSet = documentationStore.documentationSetForBundleIdentifier('com.apple.adc.documentation.AppleSnowLeopard.CoreReference', version:nil)
		allDocumentationSets = documentationStore.allDocumentationSets
		
		# Create the menu
		documentationSetMenu = NSMenu.alloc.initWithTitle('Documentation Sets')
		
		if allDocumentationSets.count > 1
			menuItems = []
			
			allDocumentationSets.each do | documentationSet |
				attributedTitle = attributedTitleForDocumentationSet(documentationSet)
				
				menuItem = NSMenuItem.alloc.initWithTitle(attributedTitle.string, action:nil, keyEquivalent:'')
				menuItem.setAttributedTitle(attributedTitle)
				menuItem.target = self
				menuItem.action = 'selectDocumentationSetForMenuItem:'
				menuItem.setState(NSOnState) if documentationSet == selectedDocumentationSet
				menuItems << menuItem
			end
			
			menuItems.sort! { | x, y | x.name <=> y.name }
			menuItems.each { | menuItem | documentationSetMenu.addItem(menuItem) }
			documentationSetMenu.addItem(NSMenuItem.separatorItem)
		end
		
		title = 'Add a Documentation Set…'.localizedString
		menuItem = NSMenuItem.alloc.initWithTitle(title, action:'addDocumentationSet:', keyEquivalent:'')
		attributedTitle = NSAttributedString.alloc.initWithString(title, attributes:{
			NSFontAttributeName => NSFont.systemFontOfSize(NSFont.smallSystemFontSize + 1)
		})
		
		menuItem.setAttributedTitle(attributedTitle)
		menuItem.target = self
		documentationSetMenu.addItem(menuItem)
		
		menuPosition = NSMakePoint(-5, documentationSetButton.frame.size.height + 7)
		documentationSetMenu.popUpMenuPositioningItem(nil, atLocation:menuPosition, inView:documentationSetButton)
	end


	def selectDocumentationSetForMenuItem(menuItem)
		if menuItem.isKindOfClass(NSMenuItem)
			updateDocumentationSetButton
		end
	end


	# Main split view delegate methods

	def splitView(splitView, resizeSubviewsWithOldSize:oldSize)
		firstSubview = splitView.subviews.objectAtUntestedIndex(0)
		secondSubview = splitView.subviews.objectAtUntestedIndex(1)
		dividerThickness = splitView.dividerThickness
		frame = splitView.frame
		
		firstSubviewFrame = firstSubview.frame		
		existingFirstSubviewFrame = firstSubview.frame
		
		firstSubviewFrame.size.height = frame.size.height
		
		minimumSearchPaneWidth = 375
		maximumSearchPaneWidth = ((splitView.frame.size.width * 3) / 5).floor
		
		if existingFirstSubviewFrame.size.width.floor <= minimumSearchPaneWidth
			if existingFirstSubviewFrame.size.width > ((oldSize.width / 5) * 2).floor
					# If the width of the search pane has gone down to the minimum size,
					# then open up to an ideal width, 2 fifths of the frame seems about right
					firstSubviewFrame.size.width = ((frame.size.width / 5) * 2).floor
			else
					firstSubviewFrame.size.width = minimumSearchPaneWidth
			end
		else
			# Otherwise continue using the ratio between the subview to the full split view
			firstSubviewFrame.size.width = (frame.size.width / (oldSize.width / firstSubviewFrame.size.width)).floor
		end
		
		if firstSubviewFrame.size.width <= minimumSearchPaneWidth
			firstSubviewFrame.size.width = minimumSearchPaneWidth 
		elsif firstSubviewFrame.size.width >= maximumSearchPaneWidth
			firstSubviewFrame.size.width = maximumSearchPaneWidth
		end
		
		firstSubview.frame = firstSubviewFrame
		
		secondSubviewFrame = secondSubview.frame
		secondSubviewFrame.size.height = frame.size.height
		secondSubviewFrame.origin.x = firstSubviewFrame.size.width + dividerThickness;
		secondSubviewFrame.size.width = frame.size.width - firstSubviewFrame.size.width - dividerThickness;
		secondSubview.frame = secondSubviewFrame
	end


	def splitView(splitView, constrainMinCoordinate:proposedMin, ofSubviewAt:dividerIndex)
		if dividerIndex == 0
			minimumCoordinate = 375
			(proposedMin < minimumCoordinate) ? minimumCoordinate : proposedMin
		else
			proposedMin
		end
	end

	
	def splitView(splitView, constrainMaxCoordinate:proposedMax, ofSubviewAt:dividerIndex)
		if dividerIndex == 0
			splitViewWidth = ((splitView.frame.size.width * 3) / 5).floor
			(proposedMax >= splitViewWidth) ? splitViewWidth : proposedMax
		else
			proposedMax
		end
	end
	

	def splitView(splitView, drawDividerInRect:dividerRectValue)
		dividerRect = dividerRectValue.rectValue
		splitViewDividerColor.setFill
		NSRectFill(dividerRect)
		
		headerColor.setFill
		dividerRect.size.height = @searchPaneController.searchFieldBackground.frame.size.height
		NSRectFill(dividerRect)
	end


	def splitView(splitView, additionalEffectiveRectOfDividerAtIndex:dividerIndex)
		dragThumb = searchPaneController.splitViewDragThumb
		return splitView.convertRect(dragThumb.bounds, fromView:dragThumb) if dragThumb
		NSRectZero
	end



	# Documentation Set Button Appearance


	def documentationSetNameAttributes
		@documentationSetNameAttributes ||= {
			NSFontAttributeName => NSFont.fontWithName('Menlo', size:12.0)
		}
	end

	def documentationSetVersionAttributes
		@documentationSetMenuVersionAttributes ||= {
			NSFontAttributeName => NSFont.fontWithName('Menlo Bold', size:12.0)
		}
	end

	def documentationSetButtonAttributes
		@documentationSetButtonAttributes ||= {
			NSForegroundColorAttributeName => NSColor.colorWithCalibratedHue(0.577, saturation:0.4, brightness:0.32, alpha:1.0),
			NSParagraphStyleAttributeName => proc {
				paragraphStyle = NSParagraphStyle.defaultParagraphStyle.mutableCopy
				paragraphStyle.setAlignment(NSCenterTextAlignment)
				paragraphStyle.setLineBreakMode(NSLineBreakByTruncatingTail)
			}.call
		}
		
	end

	def disabledDocumentationSetNameAttributes
		@disabledDocumentationSetNameAttributes ||= documentationSetNameAttributes.merge({
			NSForegroundColorAttributeName => NSColor.colorWithCalibratedWhite(0.32, alpha:1.0)
		})
	end


	def documentationSetBackgroundImageBlock
		Proc.new { | backgroundColor |
			bounds = documentationSetButtonContainer.bounds
			image = NSImage.alloc.initWithSize(bounds.size)
			image.lockFocus
			cornerRadius = 8
		
			tabRect = bounds
			tabRect.size.height -= 2
			tabRect.size.width -= cornerRadius
		
			backgroundPath = NSBezierPath.bezierPath
			backgroundPath.moveToPoint(NSMakePoint(-cornerRadius, tabRect.size.height))
			backgroundPath.lineToPoint(NSMakePoint(tabRect.size.width - cornerRadius, tabRect.size.height))
			backgroundPath.curveToPoint(NSMakePoint(tabRect.size.width, tabRect.size.height - cornerRadius),
										controlPoint1:NSMakePoint(tabRect.size.width, tabRect.size.height),
										controlPoint2:NSMakePoint(tabRect.size.width, tabRect.size.height))
			backgroundPath.lineToPoint(NSMakePoint(tabRect.size.width,  cornerRadius))
			backgroundPath.curveToPoint(NSMakePoint(tabRect.size.width + cornerRadius, 0),
										controlPoint1:NSMakePoint(tabRect.size.width, 0),
										controlPoint2:NSMakePoint(tabRect.size.width, 0))
			backgroundPath.lineToPoint(NSMakePoint(tabRect.size.width, -cornerRadius))
			backgroundPath.lineToPoint(NSMakePoint(-cornerRadius, -cornerRadius))
			backgroundPath.closePath
		
			# Draw a thin shadow
			backgroundColor.setFill
			backgroundPath.fill
		
			image.unlockFocus
			image
		}
	end


end