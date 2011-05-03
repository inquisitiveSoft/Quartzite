class AJKReferencePaneController < AJKViewController
	attr_accessor :headerMode, :searchString

	# UI Elements
	attr_accessor :headerBackgroundView, :arrowsDivider, :webView, :pageTitle, :findButton, :searchField
	
	REFERENCE_PANE_HEADER_MODE_NORMAL = 0
	REFERENCE_PANE_HEADER_MODE_FIND = 1


	def awakeFromNib
		headerBackgroundView.backgroundColor = headerColor
		headerBackgroundView.deactivatedBackgroundColor = deactivatedColor
				
		searchField.removeFromSuperview
		searchField.delegate = self
		
		@headerMode = REFERENCE_PANE_HEADER_MODE_NORMAL
		updateHeaderMode(false)
		
		# Setup web view
		webView.frameLoadDelegate = self
		webView.UIDelegate = self
		
		# Add notifications
		
	end


	def displayDocumentationForURL(url)
		if url.isKindOfClass(NSNotification)
			userInfo = url.userInfo
			url = userInfo ? userInfo[:url] : nil
		end
		
		mainFrameURL = webView ? webView.currentURL : nil
		@currentURL = url
		@currentURL ||= AJKWebView.placeholderPageURL
		
		if !mainFrameURL || (mainFrameURL != @currentURL)
			urlRequest = NSURLRequest.requestWithURL(@currentURL)
			
			mainFrame = webView.mainFrame if webView
			mainFrame.loadRequest(urlRequest) if mainFrame and urlRequest
		end
	end


	def goForward(sender)
		webView.goForward(sender)
	end

	def goBack(sender)
		webView.goBack(sender)
	end

	def canGoForward
		webView ? webView.canGoForward : false
	end

	def canGoBack
		webView ? webView.canGoBack : false
	end



# WebFrameLoad delegate methods

	def webView(sender, didReceiveTitle:title, forFrame:frame)
		return unless sender == webView
		if title or @currentURL.lastPathComponent != 'Placeholder.html'
			pageTitle.stringValue = title.gsub(/ Reference$/, "").gsub(/ Reference Protocol$/, "")
		else
			pageTitle.stringValue = ''
		end
	end


	def webView(sender, didCommitLoadForFrame:frame)
		if frame == webView.mainFrame
			# Update the sidebar to reflect the new url
			webView.currentURL
		end
	end	


# WebUIDelegate methods

	def webView(sender, contextMenuItemsForElement:element, defaultMenuItems:defaultMenuItems)
		browserMenuItem = NSMenuItem.alloc.initWithTitle("Open in External Browser".localizedString, action:'openInDefaultBrowser:', keyEquivalent:'o')
		browserMenuItem.target = self
		browserMenuItem.keyEquivalentModifierMask = NSCommandKeyMask | NSAlternateKeyMask
		
		defaultMenuItems + [NSMenuItem.separatorItem, browserMenuItem]
	end


	def openInDefaultBrowser(sender)
		currentURL = webView.currentURL
		
		if currentURL.conformsToUniformTypeIdentifier('public.html')
			
			if currentURL.quarantineProperties
			
			end
			
			currentURL.removeQuarantine if quarantineURL and quarantineURL.absoluteString.hasPrefix('http://developer.apple.com/rss/com.apple.adc.documentation')
			NSWorkspace.sharedWorkspace.openURL(currentURL) if currentURL and currentURL != AJKWebView.placeholderPageURL
		else
			raise "Couldn't retrieve the file UTI from "
		end
	end
	
	
	def availableBrowsersForURL(url)
		availableBrowsers = NSWorkspace.sharedWorkspace.applicationURLsForURL(url).reject { | applicationURL |
			applicationIdentifier = NSBundle.bundleWithURL(applicationURL).bundleIdentifier
			
			isRecognizedBrowser = false
			AJKReferencePaneController.browserIdentifiers.each do | validIdentifier |
				isRecognizedBrowser = true if applicationIdentifier.downcase == validIdentifier.downcase
			end
			
			isRecognizedBrowser
		}
		
		puts "availableBrowsers: '#{availableBrowsers.description}'"
		availableBrowsers
	end


	def self.browserIdentifiers
		if !@@browserIdentifiers
			browserIdentifiersURL = NSBundle.mainBundle.URLForResource('Browser Identifiers', withExtension:'plist')
			
			if !browserIdentifiersURL
				puts "Couldn't find the 'Browser Identifiers.plist' file. Weird."
				return []
			else
				@@browserIdentifiers = NSArray.arrayWithContentsOfURL(browserIdentifiersURL)
			end
		end
		
		@@browserIdentifiers
	end


	# Search within the current document

	def performTextFinderAction(sender)
		switchToFindHeaderMode(sender)
	end


	def searchString
		@searchString || ""
	end


	def controlTextDidChange(notification)
		searchString = searchField.stringValue
	end

	
	def controlTextDidEndEditing(notification)
		searchString = searchField.stringValue
		switchToNormalHeaderMode(nil) unless searchString and searchString.length > 0
	end


	def findWithinReference(sender)
		searchString = searchField.stringValue
		
		if searchString and searchString.length > 0
			# webView.searchFor(searchString, direction:true, caseSensitive:false, wrap:true)
		else
			
		end
	end


	def control(control, textView:textView, doCommandBySelector:selector)
		if selector.to_s == 'cancelOperation:' and searchField.stringValue.length <= 0
			switchToNormalHeaderMode(nil)
			return true
		end
		
		false
	end


	def switchToNormalHeaderMode(sender)
		@headerMode = REFERENCE_PANE_HEADER_MODE_NORMAL
		updateHeaderMode
	end


	def switchToFindHeaderMode(sender)
		@headerMode = REFERENCE_PANE_HEADER_MODE_FIND
		updateHeaderMode
	end


	def updateHeaderMode(animated=true)
		bounds = headerBackgroundView.bounds
	
		pageTitleFrame = pageTitle.frame
		pageTitleFrame.size.width = bounds.size.width - pageTitleFrame.origin.x - 100
		pageTitleFrame.size.width -= ((searchFieldWidth * 2)/3).floor + searchFieldInset if @headerMode == REFERENCE_PANE_HEADER_MODE_FIND
		(animated ? pageTitle.animator : pageTitle).frame = pageTitleFrame
	
		findButtonFrame = findButton.frame
		findButtonFrame.origin.y = bounds.origin.y
		findButtonFrame.origin.x = bounds.size.width - findButtonFrame.size.width
		findButtonFrame.origin.x -= searchFieldWidth + searchFieldInset if @headerMode == REFERENCE_PANE_HEADER_MODE_FIND
	
		findButtonTarget = (animated ? findButton.animator : findButton)
		findButtonTarget.frame = findButtonFrame
		findButtonTarget.setAlphaValue((@headerMode == REFERENCE_PANE_HEADER_MODE_FIND) ? 0 : 1)
		
		
		searchFieldTarget = (animated ? searchField.animator : searchField)
		
		case @headerMode
		when REFERENCE_PANE_HEADER_MODE_NORMAL
			if searchField.superview == headerBackgroundView				
				searchFieldFrame = searchField.frame
				searchFieldFrame.origin.x = (bounds.size.width - (searchFieldWidth / 2) - searchFieldInset).floor
				searchFieldFrame.origin.y = ((headerBackgroundView.frame.size.height - searchFieldFrame.size.height) / 2).floor
				searchFieldFrame.size.width = searchFieldWidth/2
				
				searchFieldTarget.frame = searchFieldFrame
				searchFieldTarget.setSelectable(false)
				searchFieldTarget.setAlphaValue(0)
			end
		when REFERENCE_PANE_HEADER_MODE_FIND
			if searchField.superview != headerBackgroundView
				searchFieldFrame = searchField.frame
				searchFieldFrame.origin.x = (bounds.size.width - (searchFieldWidth / 2) - searchFieldInset).floor
				searchFieldFrame.origin.y = ((headerBackgroundView.frame.size.height - searchFieldFrame.size.height) / 2).floor
				searchFieldFrame.size.width = searchFieldWidth/2
	
				searchField.setAlphaValue(0)
				searchField.frame = searchFieldFrame
				headerBackgroundView.addSubview(searchField, positioned:NSWindowBelow, relativeTo:findButton)
			end
			
			searchFieldFrame = searchField.frame
			searchFieldFrame.origin.x = (bounds.size.width - searchFieldWidth - searchFieldInset).floor
			searchFieldFrame.size.width = searchFieldWidth
			
			searchFieldTarget.frame = searchFieldFrame
			searchFieldTarget.setAlphaValue(1)
			
			searchFieldTarget.setEditable(true)
			window = self.view.window
			window.makeFirstResponder(searchField) if window
		end
	end


	def searchFieldWidth
		196
	end
	
	def searchFieldInset
		10
	end


end



class AJKWebView < WebView
	attr_accessor :stringRepresentation
	
	def self.placeholderPageURL
		@@placeholderPageURL ||= NSBundle.mainBundle.URLForResource('Placeholder', withExtension:'html')
	end
	
	
	def currentURL
		return nil unless mainFrame
		
		dataSource = mainFrame.provisionalDataSource || mainFrame.dataSource
		dataSource ? dataSource.request.URL : nil
	end

	
	def calculateStringRepresentation
		url = currentURL
		xmlDocument = url ? NSXMLDocument.alloc.initWithContentsOfURL(url, options:NSXMLDocumentTidyHTML, error:nil) : nil
		
		if xmlDocument
			xmlParser = AJKXMLParser.alloc.initWithData(xmlDocument.XMLData)
			xmlParser.target = self
			xmlParser.resultSelector = 'setStringRepresentation:'
			
			xmlParser.parse
		end
	end
	
	
	def goForward(sender)
		forwardItem = backForwardList.forwardItem
		
		if backForwardList.forwardListCount > 1
			relativeItemIndex = 1
			
			while forwardItem
				if forwardItem.originalURLString == self.class.placeholderPageURL.absoluteString
					forwardItem = backForwardList.itemAtIndex(relativeItemIndex)
					relativeItemIndex += 1
				else
					goToBackForwardItem(forwardItem)
					return
				end
			end
		end
		
		goToBackForwardItem(forwardItem) if forwardItem
	end


	def goBack(sender)
		backItem = backForwardList.backItem
		
		if backForwardList.backListCount > 1
			relativeItemIndex = -1
			
			while backItem
				if backItem.originalURLString == self.class.placeholderPageURL.absoluteString
					backItem = backForwardList.itemAtIndex(relativeItemIndex)
					relativeItemIndex -= 1
				else
					goToBackForwardItem(backItem)
					return
				end
			end
		end
		
		goToBackForwardItem(backItem) if backItem
	end
	

end


class AJKSearchField < NSSearchField

end