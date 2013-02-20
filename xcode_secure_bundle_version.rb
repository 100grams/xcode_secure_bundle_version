#!/usr/bin/ruby
#
# This script copies CFBundleShortVersionString in Info.plist to a header file of your choice.
# Add this as a "Run Script" phase to your Xcode build. 
# This is a useful security measure to prevent external manipulation of the bundle version in info.plist  

# Fail if not run from Xcode
raise "Must be run from Xcode's Run Script Build Phase" unless ENV['XCODE_VERSION_ACTUAL']

# Info.plist
plistFile = "#{ENV['BUILT_PRODUCTS_DIR']}/#{ENV['INFOPLIST_PATH']}"
headerFile = 'acetrax/defines.h'

# Convert the binary plist to xml based
`/usr/bin/plutil -convert xml1 #{plistFile}`

# Open Info.plist and get the CFBundleVersion value
lines = IO.readlines(plistFile).join
xmlString   = '<key>CFBundleShortVersionString</key>'
startIndex  = lines.index(xmlString) + xmlString.length + 10
endIndex    =   lines[startIndex,100].index('</string>')
version     = lines[start, endIndex]

# Convert back to binary plist
`/usr/bin/plutil -convert binary1 #{plistFile}`

# Copy the bundle version number to the header file
lines = IO.readlines(headerFile).join
lines.gsub! /(#define kBundleVersion\s)(\w.+)/, "\\1#{version}"
File.open(headerFile, 'w') {|f| f.puts lines}

# Report to the user
puts "CFBundleVersion #{version} copied into #{headerFile}"


