class AJKSearchPaneController
	attr_accessor :searchFilter, :searchFilterTimer, :linksDivider, :detailMode, :filterLimit
	
	# UI Elements
	attr_accessor :resultsSplitView, :referencesOutlineView, :detailsOutlineView
	attr_accessor :searchField, :splitViewDragThumb
	attr_accessor :searchFieldBackground, :detailModeBackgroundView
	attr_accessor :detailSegmentedPlaceholder, :detailSegmentedControl
	
	# Keys
	:outlineViewSpacer
	:AJKDocumentationElementPasteboardType
	
	# 
	DETAIL_MODE_REFERENCE = -1
	DETAIL_MODE_FILTER = 0
	DETAIL_MODE_CHILDREN = 1


	def init
		super
		
		detailMode = NSUserDefaults.standardUserDefaults.integerForKey('AJKSearchPaneDetailMode') || DETAIL_MODE_FILTER
		
		self
	end


	def awakeFromNib
		#
		searchField.delegate = self
		splitViewDragThumb.backgroundImage = NSImage.imageNamed('Split View Drag Thumb')
		
		searchFieldBackground.backgroundColor = headerColor
		searchFieldBackground.deactivatedBackgroundColor = deactivatedColor
		
		detailSegmentedControl.setFrame(detailSegmentedPlaceholder.frame)
		detailSegmentedControl.setAutoresizingMask(detailSegmentedPlaceholder.autoresizingMask)
		detailSegmentedPlaceholder.superview.replaceSubview(detailSegmentedPlaceholder, with:detailSegmentedControl)
		
		referencesOutlineView.dataSource = self
		referencesOutlineView.delegate = self
		
		detailsOutlineView.dataSource = self
		detailsOutlineView.delegate = self
		
		self.addObserver(self, forKeyPath:"filterLimit", options:0, context:nil)
		updateSearchFilter(nil)
	end


	def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
		if keyPath == 'filterLimit'
			updateFilterLimit(nil)
		else
			super
		end
	end


	def referenceOutlineViewItems
		@referenceOutlineViewItems ||= []
	end

	def detailOutlineViewItems
		@detailOutlineViewItems ||= []
	end

	def detailMode=(newMode)
		willChangeValueForKey('detailMode')
		@detailMode = newMode
		NSUserDefaults.standardUserDefaults.setInteger(newMode, forKey:'AJKSearchPaneDetailMode')
		didChangeValueForKey('detailMode')
	end


	def filterLimit
		@filterLimit ||= NSUserDefaults.standardUserDefaults.floatForKey('AJKFilterLimit')
	end


	def focusFilterField(sender)
		window = view.window
		window.makeKeyAndOrderFront(nil) if window
		makeFirstResponder(searchField)
	end


	def pasteToFilterField(sender)
		pasteboard = NSPasteboard.generalPasteboard
		pasteboardType = pasteboard.availableTypeFromArray([NSStringPboardType])
		
		if pasteboardType
			stringFromPasteboard = pasteboard.stringForType(pasteboardType)
			
			if stringFromPasteboard and stringFromPasteboard.length > 0
				stringFromPasteboard = stringFromPasteboard.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet)
				searchField.setStringValue(stringFromPasteboard) if stringFromPasteboard and stringFromPasteboard.length > 0
			end
		end
		
		makeFirstResponder(searchField)
		controlTextDidChange(nil)
	end


	def controlTextDidChange(notification)
		searchFilterTimer.invalidate if searchFilterTimer
		searchFilterTimer = NSTimer.scheduledTimerWithTimeInterval(0.4, target:self, selector:'updateSearchFilter:', userInfo:nil, repeats:FALSE)
	end


	def updateSearchFilter(sender=nil)
		existingSearchFilter = @searchFilter
		@searchFilter = (searchField.stringValue || "")
		@searchFilter = @searchFilter.componentsSeparatedByCharactersInSet(NSCharacterSet.illegalFilterCharacters).join
		@searchFilter = @searchFilter.gsub(/\s+/, ':').gsub(/::+/, ':')
		
		switchToFilteredDetailMode(sender)
		update(sender, shouldSelectElement:true) if @searchFilter != existingSearchFilter
	end


	def updateFilterLimit(sender)
		NSUserDefaults.standardUserDefaults.setFloat(filterLimit, forKey:'AJKFilterLimit')
		update
	end


	def setFilterLimitToNone(sender)
		setFilterLimit(1)
	end

	def setFilterLimitToFull(sender)
		setFilterLimit(0)
	end


	def update(sender=nil, shouldSelectElement=false)
		# Only go to the expense of renewing the search if the search filter has changed
		if @lastSearchFilter != @searchFilter
			@elements = documentationStore.findElementsMatchingString(@searchFilter)
			@elements.calculateScoresForAbbreviation(@searchFilter)
		end
		
		# Retain the previously selected element
		previouslySelectedElement = @selectedOutlineView ?  @selectedOutlineView.selectedElement : nil
		
		# Before removing all objects from the outline views
		referenceOutlineViewItems.removeAllObjects
		detailOutlineViewItems.removeAllObjects
		
		
		elementToSelect = nil
		itemToSelect = nil
		
		minimumNumberOfItems = 2
		filterFraction = NSPoint.pointAlongBezier(NSPoint.new(0, 0), NSPoint.new(0.6, 0.0), NSPoint.new(0.4, 0.8), NSPoint.new(1, 1), filterLimit).y
		minimumScore = 0.65
		elementTypesToFilter = (detailMode == DETAIL_MODE_FILTER) ? AJKEntityAccess.elementTypes : AJKEntityAccess.referenceTypes
		
		elementTypesToFilter.each do | elementType |
			predicate = NSPredicate.predicateWithFormat("type == %@ and scoreForAbbreviation > %@", argumentArray:[elementType, minimumScore])
			elementsForType = @elements.filteredArrayUsingPredicate(predicate)
			
			#
			next if !elementsForType || elementsForType.count == 0
			elementsForType = elementsForType.elementsSortedByAbbreviation
			
			#
			rootElement = AJKOutlineViewItem.itemWithName(AJKEntityAccess.nameForType(elementType))
			rootElement.type = elementType
			
			outlineItemsForType = elementsForType.collect { | element |
				outlineItem = AJKOutlineViewItem.itemWithName(element.name)
				outlineItem.element = element
				outlineItem
			}
			
			numberOfItemsForType = outlineItemsForType.count
			
			if numberOfItemsForType > minimumNumberOfItems
				numberOfItemsForType = minimumNumberOfItems + ((numberOfItemsForType - minimumNumberOfItems) * filterFraction).ceil
				outlineItemsForType = outlineItemsForType[0..numberOfItemsForType]
			end
			
			
			rootElement.children = outlineItemsForType
			
			
			# Find the element with the highest ranking
			if !elementToSelect || elementsForType[0].scoreForAbbreviation > elementToSelect.scoreForAbbreviation
				elementToSelect = elementsForType[0]
				itemToSelect = outlineItemsForType[0]
			end
			
			if AJKEntityAccess.referenceTypes.include?(elementType)
				referenceOutlineViewItems << rootElement
			else
				detailOutlineViewItems << rootElement
			end
		end	
		
		
		# Add a space to the bottom of the outline views
		outlineViewItem = AJKOutlineViewItem.itemWithName('')
		outlineViewItem.type = :outlineViewSpacer
		referenceOutlineViewItems << outlineViewItem
		
		if detailMode == DETAIL_MODE_FILTER
			outlineViewItem = AJKOutlineViewItem.itemWithName('')
			outlineViewItem.type = :outlineViewSpacer
			detailOutlineViewItems << outlineViewItem
		else
			# Update detail view if it is in the children mode
			updateChildDetailsForParent(elementToSelect) if shouldSelectElement
		end
		
		@lastSearchFilter = @searchFilter
		
		#
		referencesOutlineView.reloadData
		referencesOutlineView.expandItem(nil, expandChildren:true)
		
		detailsOutlineView.reloadData
		detailsOutlineView.expandItem(nil, expandChildren:true)
		
		# Either select the highest rated item or reinstate the previous selection
		elementToSelect = itemToSelect ? itemToSelect.element : nil
		elementToSelect = shouldSelectElement ? elementToSelect : previouslySelectedElement
		selectElement(elementToSelect)
	end


	def updateChildDetailsForParent(parentElement)
		detailOutlineViewItems.removeAllObjects
		
		if parentElement
			childElements = parentElement.childElements.allObjects
			
			AJKEntityAccess.detailTypes.each do | elementType |
				predicate = NSPredicate.predicateWithFormat("type == %@", argumentArray:[elementType])
				elementsForType = childElements.filteredArrayUsingPredicate(predicate)
				
				#
				next if !elementsForType || elementsForType.count == 0
				elementsForType = elementsForType.sortedArrayUsingDescriptors([nameSortDescriptor]) 	# Sort alphabetically
				
				#
				rootElement = AJKOutlineViewItem.itemWithName(AJKEntityAccess.nameForType(elementType))
				rootElement.type = elementType
				
				outlineItemsForType = elementsForType.collect { | element |
					outlineItem = AJKOutlineViewItem.itemWithName(element.name)
					outlineItem.element = element
					outlineItem
				}
				
				rootElement.children = outlineItemsForType
				detailOutlineViewItems << rootElement
			end
		end
		
		detailsOutlineView.reloadData
		detailsOutlineView.expandItem(nil, expandChildren:true)
	end


	def selectElement(elementToSelect)
		selectElement(elementToSelect, shouldBecomeFocused:false)
	end


	def selectElement(elementToSelect, shouldBecomeFocused:shouldFocus)
		if elementToSelect and !elementToSelect.isKindOfClass(AJKDocumentationElement)
			puts "Couldn't select element. Invalid elementToSelect: '#{elementToSelect.className}'"
			puts backtrace
			return
		end
		
		itemForElement = nil
		
		rootOutlineViewItems = referenceOutlineViewItems + detailOutlineViewItems
		outlineViewItems = rootOutlineViewItems.collect { | rootOutlineViewItem | rootOutlineViewItem.children }.flatten
		
		outlineViewItems.each do | outlineViewItem |
			if outlineViewItem.element == elementToSelect
				itemForElement = outlineViewItem
				break
			end
		end
		
		selectItem(itemForElement, shouldBecomeFocused:shouldFocus)
	end


	def selectItem(itemToSelect)
		selectItem(itemToSelect, shouldBecomeFocused:false)
	end


	def selectItem(itemToSelect, shouldBecomeFocused:shouldFocus)
		return nil unless itemToSelect.respondsToSelector(:element) and itemToSelect.element
				
		# Find the AJKOutlineViewItem to select
		indexToSelect = referencesOutlineView.rowForItem(itemToSelect)
		window = self.view.window
		
		if indexToSelect >= 0
			@selectedOutlineView = referencesOutlineView
			referencesOutlineView.selectRowIndexes(NSIndexSet.indexSetWithIndex(indexToSelect), byExtendingSelection:false)
			window.makeFirstResponder(referencesOutlineView) if shouldFocus and window
			
			# Unselect the items in the other outline view
			detailsOutlineView.selectRowIndexes(nil, byExtendingSelection:false)
		else
			indexToSelect = detailsOutlineView.rowForItem(itemToSelect)
			
			if indexToSelect >= 0
				@selectedOutlineView = detailsOutlineView
				detailsOutlineView.selectRowIndexes(NSIndexSet.indexSetWithIndex(indexToSelect), byExtendingSelection:false)
				window.makeFirstResponder(detailsOutlineView) if shouldFocus and window
			end
			
			# Unselect the items in the other outline view
			referencesOutlineView.selectRowIndexes(nil, byExtendingSelection:false) unless detailMode == DETAIL_MODE_CHILDREN
		end
		
		didSelectElement(itemToSelect.element)
	end


	# Split view delegate methods

	def splitView(splitView, drawDividerInRect:dividerRectValue)
		splitViewDividerColor.setFill
		NSRectFill(dividerRectValue.rectValue)
	end



	# Outline view data source methods
	def outlineView(outlineView, numberOfChildrenOfItem:item)
		return item.children ? item.children.count : 0 if item
		return referenceOutlineViewItems.count if outlineView == referencesOutlineView
		return detailOutlineViewItems.count # if outlineView == detailsOutlineView
	end


	def outlineView(outlineView, child:index, ofItem:item)
		return item.childAtIndex(index) if item
		return referenceOutlineViewItems.objectAtUntestedIndex(index) if outlineView == referencesOutlineView
		return detailOutlineViewItems.objectAtUntestedIndex(index)
	end


	def outlineView(outlineView, isItemExpandable:item)
		return false if !item
		
		children = item.children
		children ? children.count > 0 : false
	end


	# Outline view delegate methods
	def outlineView(outlineView, isGroupItem:item)
		item && !item.element
	end

	
	def outlineView(outlineView, heightOfRowByItem:item)
		return 21.0 if detailMode == DETAIL_MODE_CHILDREN and outlineView == detailsOutlineView
		return 24.0
	end
	
	
	def outlineView(outlineView, dataCellForTableColumn:tableColumn, item:item)
		return searchDetailCell if item.element
		return nil
	end
	
	
	def outlineView(outlineView, objectValueForTableColumn:tableColumn, byItem:item)
		item ? item.name : 'Unknown Element'
	end


	def searchDetailCell
		@searchDetailCell ||= AJKOutlineViewCell.alloc.initTextCell("Text Cell")
	end
	
	
	def outlineView(outlineView, willDisplayCell:cell, forTableColumn:tableColumn, item:item)
		if outlineView == detailsOutlineView
			cell.representedObject = item.element if item
			cell.mode = detailMode if cell.respondsToSelector(:mode)
		elsif cell.respondsToSelector(:mode)
			cell.mode = DETAIL_MODE_REFERENCE
		end
	end
	
	
	def outlineView(outlineView, shouldEditTableColumn:tableColumn, item:item)
		false
	end


	# Selection handling

	def outlineView(outlineView, shouldSelectItem:item)
		
		if item && item.element
			# Unselect the items in the other outline view
			@selectedOutlineView = outlineView
			
			if outlineView == referencesOutlineView
				detailsOutlineView.selectRowIndexes(nil, byExtendingSelection:false)
			elsif detailMode != DETAIL_MODE_CHILDREN
				referencesOutlineView.selectRowIndexes(nil, byExtendingSelection:false)
			end
			
			return true
		end
		
		false
	end
	
	
	def outlineViewSelectionDidChange(notification)
		outlineView = notification.object
		
		if outlineView == @selectedOutlineView
			# Get the selected item
			@selectedElement = outlineView.selectedElement
	
			# Update the UI to reflect the new selection
			displayDocumentationForElement(@selectedElement)
			updateChildDetailsForParent(@selectedElement) if outlineView == referencesOutlineView and detailMode == DETAIL_MODE_CHILDREN
			
			selectedRow = outlineView.selectedRow
			selectedRow = 0 if selectedRow <= 4
			outlineView.scrollRowToVisible(selectedRow)
			didSelectElement(@selectedElement)
		end
	end


	def didSelectElement(element)
		documentationStore.appendToHistory(element) if element
	end


# Should outline view items be expanded

	def outlineView(outlineView, shouldExpandItem:item)
		true
	end

	def outlineView(outlineView, shouldCollapseItem:item)
		true
	end

	def outlineView(outlineView, itemForPersistentObject:object)
		
	end

	def outlineView(outlineView, persistentObjectForItem:item)
		# element = item.element
		# 
		# if element
		# 	puts "item: '#{element.description}'"
		# end
	end


	# Implement copying of items from the outline views

	def copySelectedElement(sender)
		copy(@selectedOutlineView)
	end


	def copy(sender)
		if sender.isKindOfClass(NSOutlineView)
			element = sender.selectedElement
			
			if element
				generalPasteboard = NSPasteboard.generalPasteboard
				generalPasteboard.clearContents
				
				pasteboardItem = NSPasteboardItem.alloc.init
				pasteboardItem.setString(element.name, forType:NSPasteboardTypeString)
				generalPasteboard.writeObjects([pasteboardItem])
			end
		end
	end


	def jumpToNextCategory(sender)
		iterateThroughCategories(1)
	end
	
	def jumpToPreviousCategory(sender)
		iterateThroughCategories(-1)
	end


	def iterateThroughCategories(direction)
		rootOutlineViewItems = (direction > 0) ? (referenceOutlineViewItems.reverse + detailOutlineViewItems) : (referenceOutlineViewItems + detailOutlineViewItems.reverse)
		rootOutlineViewItems.reject! { | rootObject | rootObject.type == :outlineViewSpacer}
		return unless rootOutlineViewItems.count > 0
		
		
		rootOutlineViewItems << rootOutlineViewItems.first
		
		selectedRow = @selectedOutlineView ? @selectedOutlineView.selectedRow : 0
		currentItem = @selectedOutlineView.itemAtRow(selectedRow)
		currentItem = rootOutlineViewItems.first.childAtIndex(0) if !currentItem
		
		itemToSelect = nil
		foundCurrentElementType = false
		currentElementType = currentItem.element.type
		
		rootOutlineViewItems.each do | rootItem |
			if rootItem.type == currentElementType
				foundCurrentElementType = true
			elsif foundCurrentElementType
				elementToSelect = documentationStore.lastElementOfType(rootItem.type)
				itemForElement = nil
				
				rootItem.children.each do | outlineViewItem |
					if outlineViewItem.element == elementToSelect
						itemToSelect = outlineViewItem
						break
					end
				end
				
				itemToSelect = rootItem.childAtIndex(0) if !itemToSelect
				break if itemToSelect
			end
		end
		
		selectItem(itemToSelect, shouldBecomeFocused:true)
	end


	def focusReferencesOutlineView(sender)
		focusOutlineView(referencesOutlineView)
	end


	def focusDetailsOutlineView(sender)
		focusOutlineView(detailsOutlineView)
	end
	
	
	def focusOutlineView(outlineView)
		elementToSelect = outlineView.selectedElement
		
		if !elementToSelect
			outlineViewItems = nil
		
			case outlineView
			when referencesOutlineView
				outlineViewItems = referenceOutlineViewItems
				elementToSelect = documentationStore.lastReferenceElement
			when detailsOutlineView
				outlineViewItems = detailOutlineViewItems
				elementToSelect = documentationStore.lastDetailElement
			else
				puts "Can't focus an unrecognized outline view: #{outlineView}" 
			end			
			
			foundElement = false
			
			if elementToSelect
				outlineViewItems.each do | outlineViewItem |
					if outlineViewItem.containsElement(elementToSelect)
						foundElement = true
						break
					end
				end
			end
			
			if !foundElement
				outlineViewItems.each do | outlineViewItem |
					outlineViewItem = outlineViewItem.childAtIndex(0)
					
					if outlineViewItem and outlineViewItem.respondsToSelector('element')
						elementToSelect = outlineViewItem.element
						break
					end
				end
			end
		end
		
		selectElement(elementToSelect, shouldBecomeFocused:true)
	end


	def updateDetailMode(sender)
		case detailMode
		when DETAIL_MODE_FILTER
			switchToFilteredDetailMode(sender)
		when DETAIL_MODE_CHILDREN
			switchToChildrenDetailMode(sender)
		end
		
		update
	end


	def toggleDetailMode(sender)
		case detailMode
		when DETAIL_MODE_FILTER
			switchToChildrenDetailMode(sender)
		when DETAIL_MODE_CHILDREN
			switchToFilteredDetailMode(sender)
		end
	end


	def switchToFilteredDetailMode(sender)
		if detailMode != DETAIL_MODE_FILTER
			self.detailMode = DETAIL_MODE_FILTER
			update
		end
	end


	def switchToChildrenDetailMode(sender)
		if detailMode != DETAIL_MODE_CHILDREN
			self.detailMode = DETAIL_MODE_CHILDREN
			update
		end
	end


	def nameSortDescriptor
		@orderSortDescriptor ||= NSSortDescriptor.sortDescriptorWithKey("name", ascending:TRUE)
	end


	def orderSortDescriptor
		@orderSortDescriptor ||= NSSortDescriptor.sortDescriptorWithKey("order", ascending:TRUE)
	end


end


class AJKOutlineViewItem
	attr_accessor :name, :children, :type, :element
	
	def self.itemWithName(name)
		outlineViewItem = AJKOutlineViewItem.alloc.init
		outlineViewItem.name = name
		outlineViewItem
	end
	
	def children
		@children ||= []
	end
	
	def childAtIndex(childIndex)
		children.objectAtUntestedIndex(childIndex)
	end
	
	def containsElement(desiredElement)
		if desiredElement
			children.each do | outlineViewItem |
				return true if outlineViewItem.respondsToSelector('element') and outlineViewItem.element == desiredElement
			end
		end
		
		false
	end
	
end


class AJKOutlineView < NSOutlineView

	def copy(sender)
		delegate.copy(self) if delegate.respondsToSelector('copy:')
	end

	def selectedElement
		item = self.itemAtRow(self.selectedRow)
		return item.element if item and item.respondsToSelector('element')
		nil
	end

end


class AJKOutlineViewCell < NSCell
	attr_accessor :parentAttributes, :mode


	def drawInteriorWithFrame(cellFrame, inView:controlView)
		backgroundRect = cellFrame
		backgroundRect.origin.x = 0
		backgroundRect.size.width = controlView.bounds.size.width
		
		gradient = backgroundGradient
		gradient = disabledHighlightedBackgroundGradient if isHighlighted and controlView.window.firstResponder != controlView
		gradient.drawInRect(backgroundRect, angle:90)
		
		NSColor.colorWithCalibratedHue(0.583, saturation:0.07, brightness:0.84, alpha:1.0).setFill
		NSRectFill(NSMakeRect(cellFrame.origin.x, cellFrame.origin.y + backgroundRect.size.height - 1, cellFrame.size.width, 1))
		
		if mode == AJKSearchPaneController::DETAIL_MODE_REFERENCE
			elementNameFrame = cellFrame
			elementNameFrame.origin.x += 12
			elementNameFrame.origin.y += 2
			elementNameFrame.size.width -= 16
			
			if stringValue && stringValue.length > 0
				if isHighlighted and controlView.window.firstResponder != controlView
					elementNameFrame.size.width -= 12
					stringValue.drawInRect(elementNameFrame, withAttributes:disabledHighlightedElementAttributes)
				else
					stringValue.drawInRect(elementNameFrame, withAttributes:elementAttributes)
				end
			end
		else
			parentNameFrame = cellFrame
			parentNameFrame.origin.y += 3
			parentNameFrame.size.width = 14
		
			if mode != AJKSearchPaneController::DETAIL_MODE_CHILDREN
				parentNameFrame.size.width = 115
				parentNameFrame.origin.x += 5
				parentNameFrame.origin.y += 2
				parentName = representedObject.parentName if representedObject && representedObject.respondsToSelector(:parentName)
				parentName.drawInRect(parentNameFrame, withAttributes:parentAttributes) if parentName && parentName.length > 0
			end
		
			elementNameFrame = cellFrame
			elementNameFrame.origin.x += parentNameFrame.size.width + 7
			elementNameFrame.origin.y -= 3
			elementNameFrame.size.width = controlView.bounds.size.width - parentNameFrame.size.width - 15
			stringValue.drawInRect(elementNameFrame, withAttributes:elementAttributes) if stringValue && stringValue.length > 0
		end
	end


	def backgroundGradient
		@backgroundGradient ||= NSGradient.gradient({
			0.0 => NSColor.colorWithCalibratedHue(0.583, saturation:0.061, brightness:0.91, alpha:1.0),
			0.2 => NSColor.colorWithCalibratedHue(0.583, saturation:0.061, brightness:0.914, alpha:1.0),
			0.85 => NSColor.colorWithCalibratedHue(0.583, saturation:0.061, brightness:0.906, alpha:1.0),
		})
		
		@selectedBackgroundGradient ||= NSGradient.gradient({
			0.0 => NSColor.colorWithCalibratedHue(0.583, saturation:0.25, brightness:0.81, alpha:1.0),
			0.2 => NSColor.colorWithCalibratedHue(0.583, saturation:0.22, brightness:0.814, alpha:1.0),
			0.85 => NSColor.colorWithCalibratedHue(0.583, saturation:0.25, brightness:0.802, alpha:1.0),
		})
		
		
		self.isHighlighted ? @selectedBackgroundGradient : @backgroundGradient
	end
	
	
	def disabledHighlightedBackgroundGradient
		@disabledHighlightedBackgroundGradient ||= NSGradient.gradient({
			0.0 => NSColor.colorWithCalibratedHue(0.583, saturation:0.15, brightness:0.81, alpha:1.0),
			0.2 => NSColor.colorWithCalibratedHue(0.583, saturation:0.12, brightness:0.814, alpha:1.0),
			0.85 => NSColor.colorWithCalibratedHue(0.583, saturation:0.15, brightness:0.802, alpha:1.0),
		})
	end


	def parentAttributes
		@parentAttributes ||= {
				NSForegroundColorAttributeName => NSColor.grayColor,
				NSFontAttributeName => NSFont.fontWithName('Menlo', size:9.0),
				NSParagraphStyleAttributeName => proc {
					paragraphStyle = NSParagraphStyle.defaultParagraphStyle.mutableCopy
					paragraphStyle.setAlignment(NSRightTextAlignment)
					paragraphStyle.setLineBreakMode(NSLineBreakByTruncatingTail)
				}.call
		}
		
		@selectedParentAttributes ||= @parentAttributes.merge({ NSForegroundColorAttributeName => NSColor.colorWithCalibratedHue(0.575, saturation:0.8, brightness:0.3, alpha:1.0) })
		self.isHighlighted ? @selectedParentAttributes : @parentAttributes
	end


	def elementAttributes
		@elementAttributes ||= {
				NSFontAttributeName => NSFont.fontWithName('Menlo', size:11.0),
				NSParagraphStyleAttributeName => proc {
					paragraphStyle = NSParagraphStyle.defaultParagraphStyle.mutableCopy
					paragraphStyle.setLineBreakMode(NSLineBreakByTruncatingTail)
				}.call
		}
		
		@highlightedElementAttributes ||= @elementAttributes.merge({
			NSForegroundColorAttributeName => NSColor.colorWithCalibratedHue(0.575, saturation:0.5, brightness:0.35, alpha:1.0),
			NSFontAttributeName => NSFont.fontWithName('Menlo Bold', size:11.0)
		})
		
		self.isHighlighted ? @highlightedElementAttributes : @elementAttributes
	end
	
	
	def disabledHighlightedElementAttributes
		@disabledHighlightedElementAttributes ||= {
			NSFontAttributeName => NSFont.fontWithName('Menlo Bold', size:11.0),
			NSForegroundColorAttributeName => NSColor.colorWithCalibratedHue(0.575, saturation:0.1, brightness:0.35, alpha:1.0),
			NSParagraphStyleAttributeName => proc {
				paragraphStyle = NSParagraphStyle.defaultParagraphStyle.mutableCopy
				paragraphStyle.setLineBreakMode(NSLineBreakByTruncatingTail)
			}.call
		}
	end


end