class AJKSegmentedCell < NSSegmentedCell


	def drawWithFrame(frame, inView:view)
		# Draw each segments image
		for segmentIndex in 0...segmentCount
			drawForSegment(segmentIndex, inFrame:frame)
		end
	end


	def drawForSegment(segmentIndex, inFrame:frame)
		image = imageForSegment(segmentIndex)
		
		if image
			tintColor = (selectedSegment == segmentIndex) ? selectedColor : normalColor
			image = image.tintedImageWithColor(tintColor)
			segmentFrame = rectForSegment(segmentIndex, inFrame:frame)
			
			NSGraphicsContext.saveGraphicsState
			transform = NSAffineTransform.transform
			transform.translateXBy(segmentFrame.origin.x, yBy:segmentFrame.origin.y + segmentFrame.size.height)
			transform.scaleXBy(1.0, yBy:-1.0)
			transform.concat
			
			imageBounds = image.bounds
			destinationPoint = NSMakePoint(0, 0)
			destinationPoint.x = segmentFrame.origin.x + ((segmentFrame.size.width - imageBounds.size.width)/2).ceil
			destinationPoint.y = segmentFrame.origin.y + ((segmentFrame.size.height - imageBounds.size.height)/2).ceil
			
			
			image.drawAtPoint(destinationPoint, fromRect:imageBounds, operation:NSCompositeSourceOver, fraction:1)
			NSGraphicsContext.restoreGraphicsState
		end
		
	end


	def rectForSegment(segmentIndex, inFrame:frame)
		segmentFrame = frame
		segmentFrame.size.width = (frame.size.width/segmentCount).floor
		segmentFrame.origin.x += segmentFrame.size.width * segmentIndex
		segmentFrame
	end


	def normalColor
		@normalColor ||= NSColor.colorWithCalibratedHue(0.6, saturation:0.039, brightness:0.55, alpha:1.0)
	end


	def selectedColor
		@selectedColor ||= NSColor.colorWithCalibratedHue(0.578, saturation:0.2, brightness:0.451, alpha:1.0)
	end


end