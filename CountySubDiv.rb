#!/usr/bin/env ruby
#
#  Created by Aidan Marcuss on 2007-03-07.
#
#  This file is part of RubyKML.
#
#  RubyKML is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  RubyKML is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with RubyKML.  If not, see <http://www.gnu.org/licenses/>.

class CountySubDiv
  attr_reader :id, :state, :county, :tract, :name, :lsad, :lsadTrans, :data, :polygons
  attr_writer :data
  
  
  def initialize(state, county, tract, name, lsad, lsadTrans, data = 0)
    @state = state
    @county = county
    @tract = tract
    @name = name
    @lsad = lsad
    @lsadTrans = lsadTrans
    @data = data
    @polygons = Hash.new()
  end

  def add_id(id)
    @id.push(id)
  end

  def to_s
    "State: #{@state}\n - County: #{@county}\n - Tract: #{@tract}\n - Name: #{@name}\n - Data: #{data}\n"
  end

  def complete_id
    CountySubDiv.get_complete_id(@state, @county, @tract)
  end
  
  def complete_name
    "#{@name}"
  end
  
  def CountySubDiv.get_complete_id(state, county, tract)
    "#{state}#{county}#{tract}"
  end


end

def loadCountySubDivMetaData(fileName, polygons)

  puts "Loading CountySubDiv objects"

  countySubDivs = Hash.new()

  File.open( fileName,"r") do |file|
    while line = file.gets
      #puts "line #{file.lineno}: #{line}"
      if line.strip != "" 
        id = line.to_i
        if (id != 0)
          
          state = file.gets[/\d+/].ljust(2,"0")
          county = file.gets[/\d+/].rjust(3,"0")
          tract =  file.gets[/\d+/].ljust(5,"0")
          name = file.gets.gsub(/\"|\n/, "")
          lsad = file.gets[/\d+/]
          lsadTrans = file.gets[/\w+/]      
          
          countySubDivId = CountySubDiv.get_complete_id(state, county, tract)
          
          if countySubDivs[countySubDivId] != nil 
            countySubDivs[countySubDivId].polygons[id] = polygons[id]
          else
            countySubDivs[countySubDivId] = CountySubDiv.new(state, county, tract, name, lsad, lsadTrans)
            countySubDivs[countySubDivId].polygons[id] = polygons[id]
          end
          
        end
      end
    end
  end
  
  puts "Done loading CountySubDiv objects. #{countySubDivs.length} CountySubDivs added."
  
  return countySubDivs
  
end

def LoadCountySubDivData(filename, metaHash, factor)

  max = 0
  i = 0

  if filename.empty?
    metaHash.each_value {|value| value.data = 0}
  else
    File.open(filename, "r") do |file|
      header1 = file.gets
      #header2 = file.gets
      while line = file.gets
        if line.strip != ""
          fields = line.split(",")
          #id, data = line.split(",")
          id = fields[1].match(/\d+/)[0]
          id = id.strip.rjust(12,"0")

          data = fields[12].match(/\d+/)[0]
          data = data.strip 
          data = data != "" ? Float(data) * factor : Float(0)
          if metaHash[id] != nil  
            metaHash[id].data = data
            i = i + 1
            if data > max
                max = data
            end
          else
            #puts "- Missing polygon"
          end
        end
      end
    end
  end
  
  puts "Mapped data to #{i} of #{metaHash.length}"
  
  return max
  
end
