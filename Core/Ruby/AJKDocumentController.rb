class AJKDocumentController < NSDocumentController

	def self.sharedDocumentController
		@@sharedDocumentController ||= AJKDocumentController.alloc.init
	end


	def self.restoreWindowWithIdentifier(identifier, state:state, completionHandler:completionHandler)
		puts "restoreWindowWithIdentifier: '#{identifier.description}'"
	end


	def maximumRecentDocumentCount
		30
	end

end