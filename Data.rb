#!/usr/bin/env ruby
#
#  Created by Aidan Marcuss on 2007-04-05.
#  Copyright (c) 2007. All rights reserved.

def loadRandomData(geographies, randMax)

  puts "Loading Random Data"
  
  loadedGeographies = 0  
  maxData = 0
  
  geographies.each do |key, object|
    
    object.data = rand(randMax)
  
    if (object.data > maxData) 
      maxData = object.data
    end
  
    loadedGeographies = loadedGeographies + 1
  
  end
  
  puts "Done loading data. #{loadedGeographies} geographies loaded. Max data: #{maxData}"
  
  return maxData
    
end

def loadData(filename, separator, headerLines, idCol, dataCol, geographies)

  puts "Loading Data"
  
  loadedGeographies = 0
  missingGeographies = 0
  maxData = 0
  
  File.open(filename, "r") do |file|
    
    #Skip headers
    for i in 0...headerLines
      file.gets
    end
    
    while line = file.gets
      if line.strip != ""
        
        lineFields = line.split( separator )
        
        id = lineFields[idCol].strip
        
        data = lineFields[dataCol].strip
        if (data != "")
          data = Float(data)
        else
          data = Float(0)
        end
        
        if geographies[id] != nil  
          geographies[id].data = data
          loadedGeographies = loadedGeographies + 1
        else
          puts " Missing geography for id #{id} with data #{data}"
          missingGeographies = missingGeographies + 1
        end
        
        if (data > maxData) 
          maxData = data
        end
        
      end
    end
  end
  
  puts "Done loading data. #{loadedGeographies} geographies loaded. #{missingGeographies} geographies missing."
  
  return maxData
  
end
