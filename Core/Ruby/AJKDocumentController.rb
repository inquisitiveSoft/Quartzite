class AJKDocumentController < NSDocumentController

	def self.sharedDocumentController
		@@sharedDocumentController ||= AJKDocumentController.alloc.init
	end


#	When requiring this file on 10.8 it hangs at a psynch_mutexwait
#	Commenting out the following class method avoids this issue. why???
#
#	def self.restoreWindowWithIdentifier(identifier, state:state, completionHandler:completionHandler)
#		puts "restoreWindowWithIdentifier: '#{identifier.description}'"
#	end


	def maximumRecentDocumentCount
		30
	end

end