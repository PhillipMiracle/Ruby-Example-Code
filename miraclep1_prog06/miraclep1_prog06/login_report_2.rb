#!/usr/bin/ruby

# login_report_2.rb
# Phillip Miracle	
# CIT 383, Spring 2017
# 5/02/2017


require 'optparse'
require 'csv'

#Intial variable declarations
userHash = Hash.new
userCount = Hash.new
dailyCount = Hash.new
lastTXT = 'last'
title = 'Placeholder'
#Variables to store 
CsvOutput = 'login_report.csv'
GraphOutput = 'login_report.png'

#Code to handle options passed to command
optparser = OptionParser.new
optparser.on('-i', "--ip") { lastTXT << ' -i' }  # set input file name
optparser.on('-w', "--wide") { lastTXT << ' -w' } # set output file name
optparser.on('-f INFILE', "--file INFILE") do  |file| 
	lastTXT << " -f #{file}"
end
optparser.on('-c OUTFILE', "--csv OUTFILE") do  |file| 
  CsvOutput.replace file << '.csv'
end

optparser.on('-g OUTFILE', "--graph OUTFILE") do  |file| 
  GraphOutput.replace file << '.png'
end
optparser.on('-h', "--help") do
	puts "-i, --ip" + "                         " + "--pass-through to the last command, telling it to convert FQDNs to IP addresses"
	puts "-w, --wide" + "                       " + "--pass-through to the last command, telling it to convert FQDNs to IP addresses"
	puts "-f <wtmp_file>, --file<wtmp_file>" + "          " + "--pass-through to the last command, telling it to convert FQDNs to IP addresses"
	puts "-c <csv_file>, --csv <csv_file>" + "    		" + "--send the CSV output to the named file"
	puts "-g <png_file>, --csv <png_file>" + "    		" + "--send the Graph output to the named file"
	puts "-h, --help" + "                       " + "--show the command usage summary"
	exit
end

#begin rescue to capture invalid options
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
		next
	end
	
	lineArray = line.split
	if(lineArray[0] == 'wtmp')
		title = line
		break
	end
	userID = lineArray[0]
	if !dailyCount.has_key?(lineArray[5])
		dailyCount[lineArray[5]] = 1
	else
		dailyCount[lineArray[5]] += 1
	end
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

#Creates CSV
CSV.open(CsvOutput, 'wb') do |csv|
	csv << ['UserName','FullName','Last Login','Total Logins','IP Address List']
	userHash.each do |key, user|
		csv << user
	end
end

require 'gruff'
# Creates Graph
g = Gruff::Line.new
g.title = title
g.data('Logins', dailyCount.map { |s| s[1]})
dailyCount.keys.each.with_index { |date, i| g.labels[i] = date}
g.x_axis_label = 'Date'
g.y_axis_label = 'Number of Logins'
g.minimum_value = 0
g.write(GraphOutput)

