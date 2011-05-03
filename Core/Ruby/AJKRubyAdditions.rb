class NSObject

	def backtrace(depth=2)
		begin
		  raise
		rescue => exception
			backtrace = exception.backtrace[depth..-1].collect { | line |  line[%r{/[^/]+.rb:.*}] }.join("\n")
		end
	end

end


class NilClass
	
	# Emulate Objective-C's ability to send methods to nil, tho' log it as an error
	def method_missing(method, *args)
		puts "Undefined method '#{method}' for a nil object"
		puts backtrace
		
		return nil
	end

end


class NSAlert

	def self.displayAlertForError(error)
		if error.isKindOfClass(NSError)
			puts "Encountered an error: #{error.code} within the '#{error.domain}' domain: '#{error.userInfo.description}'"
			puts backtrace
			
			alert = NSAlert.alertWithError(error)
			underlyingException = error.userInfo['NSUnderlyingException']
			alert.informativeText = "#{underlyingException.name}\n\n#{underlyingException.reason}\n\nuserInfo: #{underlyingException.userInfo ? underlyingException.userInfo.description : ''}" if underlyingException
			alert.runModal
		else
			puts "Invalid error : '#{error.description}'\n" + backtrace + "\n"
		end
	end

end



class NSPoint
	
	def self.pointAlongBezier(a, b, c, d, intersection)
		ab = pointBetween(a, b, intersection)
		bc = pointBetween(b, c, intersection)
		cd = pointBetween(c, d, intersection)
		abbc = pointBetween(ab, bc, intersection)
		bccd = pointBetween(bc, cd, intersection)
		pointBetween(abbc, bccd, intersection)
	end
	
	
	def self.pointBetween(a, b, intersection)
		new(a.x + (b.x - a.x) * intersection, a.y + (b.y - a.y) * intersection)
	end
	
end


def Proc
	
	def performAfterDelay(delay)
		performBlockAfterDelay(self, delay)
	end
	
end


class AJKDocumentationSet


	def simpleName
		case family
		when 'macosx'
			"Mac OS X".localizedString
		else
			name
		end
	end


	def simpleVersion
		if platformVersion and platformVersion.length
			platformVersion
		else
			nil
		end
	end


end



class NSCharacterSet

	def self.illegalFilterCharacters
		NSCharacterSet.characterSetWithCharactersInString('()[]{}<>')
	end

end



class NSImage

	def tintedImageWithColor(tintColor)
		tintedImage = NSImage.alloc.initWithSize(size)
		return tintedImage unless tintColor
		
		tintedImage.lockFocus
		drawAtPoint(NSZeroPoint, fromRect:bounds, operation:NSCompositeSourceOver, fraction:1)
		
		tintColor.set
		NSRectFillUsingOperation(bounds, NSCompositeSourceAtop)
		tintedImage.unlockFocus
	end


	def bounds
		imageSize = size
		NSMakeRect(0, 0, imageSize.width, imageSize.height)
	end


end