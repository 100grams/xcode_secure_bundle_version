#!/usr/bin/ruby
#
# This script copies CFBundleShortVersionString in Info.plist to a header file of your choice.
# Add this as a "Run Script" phase to your Xcode build.
# This is a useful security measure to prevent external manipulation of the bundle version in info.plist

# Fail if not run from Xcode
raise "Must be run from Xcode's Run Script Build Phase" unless ENV['XCODE_VERSION_ACTUAL']

# Info.plist
plist_file = "#{ENV['BUILT_PRODUCTS_DIR']}/#{ENV['INFOPLIST_PATH']}"

header_file = 'Classes/defines.h'

# Convert the binary plist to xml based
`/usr/bin/plutil -convert xml1 #{plist_file}`

# Open Info.plist and get the line after the CFBundleShortVersionString, which contains our version number,
# read that line and pull out the value from the XML string
target_line = nil
File.open(plist_file, 'r').each_with_index { |line, line_number| target_line = line_number + 1 if line =~/<key>CFBundleShortVersionString<\/key>/ }
raise "No version number found" if target_line == nil
version = IO.readlines(plist_file)[target_line].scan(/<string>(.*?)<\/string>/)

# Convert back to binary plist
`/usr/bin/plutil -convert binary1 #{plist_file}`

# Copy the bundle version number to the header file
file = IO.readlines(header_file).join
if file =~ /#define kBundleVersion/
    file.gsub!(/(#define kBundleVersion\s)(.+)/, "\\1@\"#{version}\"")
else
    file << "\n// Secure version number, do not edit manually, handled by script! \n#define kBundleVersion #{version}"
end
File.open(header_file, 'w') {|f| f.puts file}

# Report to the user
puts "CFBundleVersion #{version} copied into #{header_file}"
