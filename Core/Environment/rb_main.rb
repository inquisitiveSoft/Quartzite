framework 'Cocoa'
require 'AJKEntityAccess'

puts "Hello World"

# Loading all the Ruby project files.
main = File.basename(__FILE__, File.extname(__FILE__))
dir_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation
Dir.glob(File.join(dir_path, '*.{rb,rbo}')).map { |x| File.basename(x, File.extname(x)) }.uniq.each do |path|
	if path != main
		puts "require(attempt): " + path
		require(path)
		puts "require(success): " + path
	end
end

# Starting the Cocoa main loop.
NSApplicationMain(0, nil)