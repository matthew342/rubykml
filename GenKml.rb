#!/usr/bin/env ruby
#
#  Created by Aidan Marcuss on 2007-03-06.
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

require "rexml/document"
require "BlockGroups"
require "Colors"
include REXML
include Colors

bgMetaIdData = LoadBlockGroupMetaData()
LoadBlockGroupData(bgMetaIdData)

bgPolyIdHash = Hash.new()
bgMetaIdData.each_value {|value| 
  for i in 0...value.id.length
    bgPolyIdHash[value.id[i]] = value
  end }


#bgSimpleIdHash.to_a.each_index {|x| puts x}


availablePalette = buildHexColorTable( Colors::BaseColors )
#availablePalette = buildRedHexColorTable(Colors::BaseColors, "ff")
#availablePalette = buildGreenHexColorTable(Colors::BaseColors, "ff")
#availablePalette = buildBlueHexColorTable(Colors::BaseColors, "ff")

#availablePalette = [ "00ff66", "33ff66", "66ff66", "99ff66", "ccff66", "ffff66" ]

#puts availablePalette

xml = Document.new(File.open("document.xml"))

a = Hash.new
bgStart = true
bg = 0

File.open("bg25_d00.dat","r") do |file|
  while line = file.gets
    if line.strip == "END" 
      bgStart = true
    elsif bgStart 
      bg, lon, lat = line.split
      bg = Integer(bg)
      a[bg] = Array.new
      #a[bg].push([Float(lon), Float(lat),0])
      bgStart = false
  else
      lon, lat = line.split
      if bg > 0
        a[bg].push([Float(lon), Float(lat), bgPolyIdHash[bg].data])
      else
        a[bg].push([Float(lon), Float(lat), 0])
      end
    end
  end
end

#data = Hash.new

#File.open("BG Data.csv", "r") do |file|
#  while line = file.gets
#    blockGroupId, blockGroupData = line.split(",")
#    data[Integer(blockGroupId)] = Float(blockGroupData)
#  end
#end

folder = XPath.first(xml, "//Folder")

xml.elements.delete_all "//Placemark"

for i in 1..bg

  placemark = folder.add_element "Placemark"

  name = placemark.add_element "name"
  name.text = i
  description = placemark.add_element "description"
  description.text = bgPolyIdHash[i].to_s
  visibility = placemark.add_element "visibility"
  visibility.text = "1"

  style = placemark.add_element "Style"

  lineStyle = style.add_element "LineStyle"
  lineColor = lineStyle.add_element "color"
  lineColor.text = "00ffffff"
  lineWidth = lineStyle.add_element "width"
  lineWidth.text = "1"

  hexColor = dataColor(bgPolyIdHash[i].data, 6131, availablePalette)

  polyStyle = style.add_element "PolyStyle"
  polyColor = polyStyle.add_element "color"
  polyColor.text = "ff" + hexColor
  polyOutline = polyStyle.add_element "outline"
  polyOutline.text = "1"

  polygon = placemark.add_element "Polygon"	
  extrude = polygon.add_element "extrude"
  extrude.text = "1"
  tessellate = polygon.add_element "tessellate"
  tessellate.text = "1"
  altitudeMode = polygon.add_element "altitudeMode"
  #clampToGround relativeToGround absolute
  altitudeMode.text = "absolute"
  outerBoundaryIs = polygon.add_element "outerBoundaryIs"
  linearRing = outerBoundaryIs.add_element "LinearRing"
  coordinates = linearRing.add_element "coordinates"
  coordList = String.new
  a[i].each {|b| coordList += b.join(", ") + "\n"}
  coordinates.text = coordList

end


#coord = XPath.first( xml, "//coordinates")
#coord.text = output
#xml.write( $stdout, 0 )
xml.write( File.new("output.kml","w+"), 0 )
puts "#{bg} block groups mapped."
puts "Done!"