#!/usr/bin/env ruby
#
#  Created by Aidan Marcuss on 2007-04-09.
#  Copyright (c) 2007. All rights reserved.

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