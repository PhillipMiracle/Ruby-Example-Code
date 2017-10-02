#!/usr/bin/ruby

# login_report.rb
# Phillip Miracle	
# CIT 383, Spring 2017
# 4/13/2017


require 'optparse'

#Intial variable declarations
userHash = Hash.new
userCount = Hash.new
lastTXT = 'last'
output = $stdout

#Code to handle options passed to command
optparser = OptionParser.new
optparser.on('-i', "--ip") { lastTXT << ' -i' }  # set input file name
optparser.on('-w', "--wide") { lastTXT << ' -w' } # set output file name
optparser.on('-f INFILE', "--file INFILE") do  |file| 
	lastTXT << " -f #{file}"
end
optparser.on('-o OUTFILE', "--out OUTFILE") do  |file| 
  output = File.open(file, "w")
end

optparser.on('-h', "--help") do
	puts "-i, --ip" + "                         " + "--pass-through to the last command, telling it to convert FQDNs to IP addresses"
	puts "-w, --wide" + "                       " + "--pass-through to the last command, telling it to convert FQDNs to IP addresses"
	puts "-f <file>, --file<file>" + "          " + "--pass-through to the last command, telling it to convert FQDNs to IP addresses"
	puts "-o <outfile> , --out<outfile>" + "    " + "--send the output to the named file"
	puts "-h, --help" + "                       " + "--show the command usage summary"
	exit
end

#begin rescue to capture iunvalid options
begin
  optparser.parse! 
rescue => e 
  puts e.class
	puts " "
  puts "Enter -h, --help for a list of available options"
  exit
end


#loop to split command results into report fields
(`#{lastTXT}`).each_line do |line|
	#if line is empty breaks loop
	if line.strip!.empty?
		break
	end
	
	lineArray = line.split
	userID = lineArray[0]
	
	#Adds new ip and increments userCount
	if userHash.has_key?(userID)
		ip = lineArray[2]
		array = userHash[userID]
		if !array.include?(ip)
			userHash[userID] << ip
		end
		userCount[userID] += 1
		userHash[userID][3] = userCount[userID].to_s
	
	#standard new user creation in hash
	else
		userArray = []
		userArray << userID
		gecosArray = `getent passwd #{userID}`.split(':')
		gecos = gecosArray[4].to_s
		userArray << gecos
		date = lineArray[4] + ' ' + lineArray[5] + ' ' + lineArray[6]
		userArray << date
		userCount[userID] = 1
		userArray << userCount[userID].to_s
		ip = lineArray[2]
		userArray << ip
		userHash[userID] = userArray
	end	
end

#For loops to print out report
output.print 'UserName,FullName,Last Login,Total Logins,IP Address List'
output.puts ' '
userHash.each do |key, user|
	user.each do |item|
		if item.match(/([[:digit:]]{,3})\.([[:digit:]]{,3})\.([[:digit:]]{,3})\.([[:digit:]]{,3})/)
			output.print item + ';'
		else
			output.print item + ","
		end
	end
	output.puts ' '
end

