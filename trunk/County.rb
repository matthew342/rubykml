#!/usr/bin/env ruby
#
#  Created by Aidan Marcuss on 2007-03-19.
#  Copyright (c) 2007. All rights reserved.

class County
  
  attr_reader :id, :state, :county, :name, :lsad, :lsadTrans, :data, :dataFileCounty, :dataFileState 
  attr_writer :data, :dataFileCounty, :dataFileState 
    
  def initialize(id, state, county, name, lsad, lsadTrans, data = 0, dataFileCounty = "", dataFileState = "")
    @id = Array.new()
    @id.push(id)
    @state = state
    @county = county
    @name = name
    @lsad = lsad
    @lsadTrans = lsadTrans
    @data = data
    @dataFileCounty = dataFileCounty
    @dataFileState  = dataFileState
  end

  def add_poly_id(id)
    @id.push(id)
  end

  def to_s
    "ID: #{@id.join(", ")}\n - State: #{@state}\n - County: #{@county}\n - Name: #{@name}\n - Data: #{data}"
  end

  def complete_id
    get_complete_id(@state, @county)
  end

  def County.get_complete_id(state, county)
    "#{state}#{county}"
  end

end

def loadCountyMeta(filename)
  
  puts "Loading County metadata"
  
  countyHash = Hash.new()
  polygonCount = 0;

  File.open(filename,"r") do |file|
    while line = file.gets
      
      #puts "line #{file.lineno}: #{line}"
      
      if line.strip != "" 
        
        id = line.to_i
        
        if (id != 0)
          
          state = file.gets[/\d+/].ljust(2,"0")
          county = file.gets[/\d+/]
          name = file.gets.gsub(/\"|\n/, "")
          lsad = file.gets[/\d+/]
          lsadTrans = file.gets[/\w+/]
                
          countyId = County.get_complete_id(state, county)       
          
          if countyHash[countyId] != nil 
            countyHash[countyId].add_poly_id(id)
          else
            countyHash[countyId] = County.new(id, state, county, name, lsad, lsadTrans)
            puts "  Added: #{countyId}"
          end
          
          polygonCount = polygonCount + 1
          
        end
      end
    end
  end
  
  puts "Done loading County metadata. #{countyHash.length} counties added. #{polygonCount} polygons added."
  
  return countyHash
  
end

def LoadCountyData(filename, metaHash, factor, dataColumn)

  puts "Loading county data"

  max = 0
  i = 0

  if filename.empty?
    metaHash.each_value {|value| value.data = 0}
  else
    File.open(filename, "r") do |file|
      header1 = file.gets
      header2 = file.gets
      while line = file.gets
        if line.strip != ""
          raw_data = line.split("|")
          geo_id = raw_data[0].strip
          id = raw_data[1].strip.rjust(5,"0")
          
          dataFileCounty, dataFileState = raw_data[3].split(",")
          dataFileCounty.delete!("\"").strip!
          dataFileState.delete!("\"").strip!
                          
          data = raw_data[dataColumn].strip 
          data = data != "" ? Float(data) * factor : Float(0)        
          
          #puts " ID: #{id} Data: #{data} dataFileCounty: '#{dataFileCounty}' dataFileState: '#{dataFileState}'"
          
          if metaHash[id] != nil  
            
            metaHash[id].data = data
            metaHash[id].dataFileCounty = dataFileCounty
            metaHash[id].dataFileState = dataFileState
         
            i = i + 1
            if data > max
                max = data
            end
          else
            puts " Missing polygon for #{id}"
          end
        end
      end
    end
  end
  
  puts "Done loading county data. Data added to #{i} counties."
    
  return max
  
end