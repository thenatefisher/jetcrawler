#! /usr/bin/env ruby
#
#   JetCrawler entry script
#   aka Harvest
#   
#   Author: Nate Fisher, 2012
#   
#   Runs logic to scrape, crawl, beg or otherwise assimilate the data from all
#   sources in the sources directory. 
#
#

# start the clock
start_time = Time.now()

# set rails env
ENV["RAILS_ENV"] ||= "production"

# use Rails models
require File.dirname(__FILE__) + '/../../config/environment'

# require all libraries
require File.join(File.dirname(__FILE__), "lib", "jetcrawler_base.rb")
Dir.glob(File.join(File.dirname(__FILE__), "lib", "*.rb")).each do |f| 
    require f
end    

# require all sources
Dir.glob(File.join(File.dirname(__FILE__), "sources", "**", "*.rb")).each do |f| 
    require f
end    

# scope the threads collection
threads = Array.new

# for every directory in the /sources folder
Dir.entries(File.join(File.dirname(__FILE__), "sources")).each do |f|

   # skip if not a source folder
   next if f == ".." || f == "." 

   # ensure that the entry class exists
   entryClassName = "#{f.downcase.capitalize}Entry"
   next if eval "defined?(#{entryClassName}) != 'constant' || #{entryClassName}.class != Class"

   begin 

       # create an entry object based on the folder name
       entryClass = eval entryClassName
       entry = entryClass.new
       
       # execute its run() method
       #threads << Thread.new{ entry.run }
       entry.run
   
   rescue
   
        # this source had a problem running
        puts "Did not harvest from: #{f}"
        next
   
   end
   
end

# join all threads
threads.each {|t| t.join}

# print finished message
puts "Jetcrawl Completed in #{((Time.now() - start_time)/60).to_i} minutes at #{Time.now}"
