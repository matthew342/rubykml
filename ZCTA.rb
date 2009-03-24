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

class ZCTA
  attr_reader :id, :zip, :name, :lsad, :lsadTrans, :data, :polygons
  attr_writer :data
    
  def initialize(zip, name, lsad, lsadTrans, data = 0)
    @zip = zip
    @name = name
    @lsad = lsad
    @lsadTrans = lsadTrans
    @data = data
    @polygons = Hash.new()
  end

  def to_s
    "Zip: #{@zip}\n - Name: #{@name}\n - LSAD: #{@lsad}\n  - LSAD Trans: #{@lsadTrans}\n - Data: #{data}\n"
  end

  def complete_id
    ZCTA.get_complete_id(@zip)
  end
  
  def complete_name
    "#{zip}"
  end
  
  def ZCTA.get_complete_id(zip)
    "#{zip}"
  end

end

def loadZCTAMetaData(fileName, polygons)

  puts "Loading ZCTA objects"

  zctas = Hash.new()

  File.open( fileName, "r") do |file|
    while line = file.gets
      #puts "line #{file.lineno}: #{line}"
      if line.strip != "" 
        id = line.to_i
        if (id != 0)
          
          zip = file.gets[/\d+\w+/]
          name = file.gets[/\d+\w+/]
          lsad = file.gets.gsub(/ |\"|\n/, "")
          lsadTrans = file.gets.gsub(/ |\"|\n/, "")

          if (zip != nil)        
            
            zctaId = ZCTA.get_complete_id(zip)
          
            if zctas[zctaId] != nil 
              zctas[zctaId].polygons[id] = polygons[id]
            else
              zctas[zctaId] = ZCTA.new(zip, name, lsad, lsadTrans)
              zctas[zctaId].polygons[id] = polygons[id]
            end
            
          else
            puts " *** Skipped Polygon #{id} because the metadata was empty."
          end
          
        end
      end
    end
  end
  
  puts "Done loading ZCTA objects. #{zctas.length} ZCTAs added."
  
  return zctas
  
end