#!/usr/bin/env ruby
#
#  Created by Aidan Marcuss on 2007-03-19.
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

class Polygon
  attr_reader :id, :centerLon, :centerLat, :mainCoords, :exCoords
  attr_writer :id, :centerLon, :centerLat
  
  def initialize(id, centerLon, centerLat)
    @id = id
    @centerLon = centerLon
    @centerLat = centerLat
    @mainCoords = Array.new()
    @exCoords = Array.new()
  end

end

def loadPolygonObjs(filename)
  
  puts "Loading Polygon objects"
  
  polygons = Hash.new()

  polyStart = true
  exPoly = false
  
  currentPolygon = nil
  
  mainPolyCount = 0
  exPolyCount = 0

  File.open(filename, "r") do |file|
    while line = file.gets
      if line.strip == "END" 
        
        polyStart = true
        exPoly = false
        
      elsif polyStart 

        id, centerLon, centerLat = line.split
        id = Integer(id)
        
        if (id == -99999)
          if (exPoly == true)
            raise "Two exclude polygons in a row"
          end
          exPoly = true
          exPolyCount = exPolyCount + 1
        else
          centerLon = Float(centerLon)
          centerLat = Float(centerLat)
          currentPolygon = Polygon.new(id, centerLon, centerLat)
          polygons[id] = currentPolygon
          mainPolyCount = mainPolyCount + 1
        end
      
        polyStart = false
        
    else
      
        lon, lat = line.split
        
        if exPoly 
          currentPolygon.exCoords.push([Float(lon), Float(lat)])
        else
          currentPolygon.mainCoords.push([Float(lon), Float(lat)])
        end

      end
    end
  end
  
  puts "Done loading Polygon objects. #{mainPolyCount} polygons added. #{exPolyCount} cutout polygons added."
    
  return polygons
  
end

def loadPolygons(filename)
  
  puts "Loading polygon data"
  
  polygons = Hash.new
  polyStart = true
  cutoutPolygonId = -99999
  
  File.open(filename, "r") do |file|
    while line = file.gets
      if line.strip == "END" 
        polyStart = true
      elsif polyStart 
        id, lon, lat = line.split
        id = Integer(id)
        if (id < 0)
          id = cutoutPolygonId 
          cutoutPolygonId = cutoutPolygonId - 1
        end
        polygons[id] = Array.new
        #a[bg].push([Float(lon), Float(lat),0])
        polyStart = false
    else
        lon, lat = line.split
        if id > 0
          polygons[id].push([Float(lon), Float(lat)])
        else
          polygons[id].push([Float(lon), Float(lat)])
        end
      end
    end
  end
  
  puts "Done loading polygon data. #{polygons.length} polygons added. #{-1 * (cutoutPolygonId + 99999)} cutout polygons added."
    
  return polygons

end

def loadPolygonCenters(filename)
  
  puts "Loading polygon data"
  
  polygonCenters = Hash.new
  polyStart = true
  cutoutPolygonId = -99999
  
  File.open(filename, "r") do |file|
    while line = file.gets
      if line.strip == "END" 
        polyStart = true
      elsif polyStart 
        id, lon, lat = line.split
        id = Integer(id)
        if (id < 0)
          id = cutoutPolygonId 
          cutoutPolygonId = cutoutPolygonId - 1
        end
        polygonCenters[id] = Array[Float(lon), Float(lat)]
        polyStart = false
      end
    end
  end
  
  puts "Done loading polygon center data. #{polygonCenters.length} polygon centers added. #{-1 * (cutoutPolygonId + 99999)} cutout polygon centers added."
    
  return polygonCenters

end