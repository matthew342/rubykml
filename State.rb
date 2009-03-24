#!/usr/bin/env ruby
#
#  Created by Aidan Marcuss on 2007-04-09.
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

class State
  attr_reader :id, :fipsID, :stateName, :lsad, :lsadTrans, :data, :polygons
  attr_writer :data
    
  def initialize(fipsID, stateName, lsad, lsadTrans, data = 0)
    @fipsID = fipsID
    @stateName = stateName
    @lsad = lsad
    @lsadTrans = lsadTrans
    @data = data
    @polygons = Hash.new()
  end

  def to_s
    "State: #{@stateName}\n - FIPS: #{@fipsID}\n - LSAD: #{@lsad}\n - Data: #{data}\n"
  end

  def complete_id
    State.get_complete_id(@fipsID)
  end
  
  def complete_name
    "#{@stateName}"
  end
  
  def State.get_complete_id(fipsID)
    "#{fipsID}"
  end

end

def loadStateMetaData(fileName, polygons)

  puts "Loading State objects"

  states = Hash.new()

  File.open( fileName,"r") do |file|
    while line = file.gets
      #puts "line #{file.lineno}: #{line}"
      if line.strip != "" 
        id = line.to_i
        if (id != 0)
          
          fipsID = file.gets[/\d+/]
          stateName = file.gets.gsub(/ |\"|\n/, "")
          lsad = file.gets.gsub(/ |\"|\n/, "")
          lsadTrans = file.gets.gsub(/ |\"|\n/, "")

          if (fipsID != nil)        
            
            stateId = State.get_complete_id(fipsID)
          
            if states[stateId] != nil 
              states[stateId].polygons[id] = polygons[id]
            else
              states[stateId] = State.new(fipsID, stateName, lsad, lsadTrans)
              states[stateId].polygons[id] = polygons[id]
            end
            
          else
            puts " *** Skipped Polygon #{id} because the metadata was empty."
          end
          
        end
      end
    end
  end
  
  puts "Done loading State objects. #{states.length} State added."
  
  return states
  
end