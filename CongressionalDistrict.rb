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

require "FIPS"

class CongressionalDistrict
  attr_reader :id, :state, :district, :misc1, :lsad, :lsadTrans, :stateDistrict, :data, :polygons
  attr_writer :data
    
  def initialize(state, district, misc1, lsad, lsadTrans, stateDistrict, data = 0)
    @state = state
    @district = district
    @misc1 = misc1
    @lsad = lsad
    @lsadTrans = lsadTrans
    @stateDistrict = stateDistrict
    @data = data
    @polygons = Hash.new()
  end

  def to_s
    "State: #{@state}\n - District: #{@district}\n - LSAD: #{@lsad}\n - Data: #{data}\n"
  end

  def complete_id
    CongressionalDistrict.get_complete_id(@state, @district)
  end
  
  def complete_name
    "#{FIPS::StateCodeFIPS[@state][1]}: #{@district}"
  end
  
  def CongressionalDistrict.get_complete_id(state, district)
    "#{state}#{district}"
  end

end

def loadCongressionalDistrictMetaData(fileName, polygons)

  puts "Loading CongressionalDistrict objects"

  cds = Hash.new()

  File.open( fileName,"r") do |file|
    while line = file.gets
      #puts "line #{file.lineno}: #{line}"
      if line.strip != "" 
        id = line.to_i
        if (id != 0)
          
          state = file.gets[/\d+/]
          district = file.gets[/\d+/]
          misc1 = file.gets[/\d+/]
          lsad = file.gets.gsub(/ |\"|\n/, "")
          lsadTrans = file.gets.gsub(/ |\"|\n/, "")
          stateDistrict = file.gets[/\d+/]

          if (state != nil)        
            
            cdId = CongressionalDistrict.get_complete_id(state, district)
          
            if cds[cdId] != nil 
              cds[cdId].polygons[id] = polygons[id]
            else
              cds[cdId] = CongressionalDistrict.new(state, district, misc1, lsad, lsadTrans, stateDistrict)
              cds[cdId].polygons[id] = polygons[id]
            end
            
          else
            puts " *** Skipped Polygon #{id} because the metadata was empty."
          end
          
        end
      end
    end
  end
  
  puts "Done loading CongressionalDistrict objects. #{cds.length} CongressionalDistrict added."
  
  return cds
  
end