#!/usr/bin/ruby


#apache_report_2.rb
# Phillip Miracle	
# CIT 383, Spring 2017
# 3/30/2017

#ip report creation
def ipReport(array)
ips = Hash.new
array.each do |line|
	token1 = line.scan(/([[:digit:]]{,3})\.([[:digit:]]{,3})\.([[:digit:]]{,3})\.([[:digit:]]{,3}) /)
	#Adds values to the ip address hash
	if ips.has_key?(token1)
		ips[token1] += 1
	else
		ips[token1] = 1
	end
end
puts " "
#IP address report creation
puts "Frequency of Client IP Addresses:"
	ips.each do |key, value|
		printf("%-20s","#{key.join('.')}")
		0.upto(value) { print "*" }
		puts " "
	end
	
end
#url Report creation
def urlReport(array)
urls = Hash.new
array.each do |line|
	token2 = line.scan(/( \/[a-zA-z0-9\.\/]*)/)
	#Adds values to the url hash
	if urls.has_key?(token2)
		urls[token2] += 1
	else
		urls[token2] = 1
	end	
end
puts " "
#Url report creation
puts "Frequency of URLs Accessed:"
	urls.each do |key, value|
		printf("%-50s","#{key.join}")
		print "#{value}"
		puts " "
	end
end	
#http Report creation
def httpReport(array)
status = Hash.new
array.each do |line|
	#tokens = line.split(' ')
	token3 = line.scan(/\" ([[:digit:]]{3})/)
	#Adds values to the status hash	
	if status.has_key?(token3)
		status[token3] += 1
	else
		status[token3] = 1
	end	
end
puts " "
#HTTP Status report creation
puts "HTTP Status Codes Summary: "
	status.each do |key, value|
		print "#{key.join}\t"
		percent = (value.to_f/array.size) * 100
		print "#{percent.round}%"
		puts " "
	end
end



#Begin Rescue Block to catch file exceptions
begin
	line_array = File.readlines("access_log")
rescue
	puts "File Access Error"
else
puts "----------------------------------------------------"
puts "Statistics for the Apache log file access_log"
puts "----------------------------------------------------"
ipReport(line_array)
urlReport(line_array)
httpReport(line_array)
end




