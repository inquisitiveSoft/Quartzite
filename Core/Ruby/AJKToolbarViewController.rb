class AJKToolbarViewController < AJKViewController

	def awakeFromNib
		view.backgroundImage = NSImage.imageNamed('References Divider')
	end


	def displayFavoritesMenu(sender)
		puts 'displayFavoritesMenu'
	end


	def displayHistoryMenu(sender)
		puts 'displayHistoryMenu'
	end


end