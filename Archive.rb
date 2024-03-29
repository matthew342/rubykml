#!/usr/bin/env ruby
#
#  Created by Aidan Marcuss on 2007-04-05.
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

def generateKml(outputFilename, name, alpha, altitudeModeValue, polygons, polygonCenters, idHash, maxData, availablePalette, polyColorModeValue)

  numPolygons = polygons.length
  polygonsDrawn = 0

  xml = Document.new()
  
  xml.add XMLDecl.new()
  kml = xml.add_element "kml"
  kml.add_namespace "http://earth.google.com/kml/2.1"
  
  document = kml.add_element "Document"
  documentName = document.add_element "name"
  documentName.text = name
  documentDescription = document.add_element "description"
  documentDescription.text = CData.new( "Generated by Aidan Marcuss on #{Time.now.getgm}.<br>Published at <a href=\"http://censuskml.blogspot.com/\">CensusKML</a>.<br>US Census data provide by <a href-\"http://factfinder.census.gov/servlet/DownloadDatasetServlet?_lang=en\">American FactFinder</a>. Geographic boundary files provided by US Census <a href=\"http://www.census.gov/geo/www/cob/bdy_files.html\">here</a>.").to_s
  documentVisibility = document.add_element "visibility"
  documentVisibility.text = "1"
  documentOpen = document.add_element "open"
  documentOpen.text = "1"  

  lookAt = document.add_element "LookAt"
  
  lookAtLong = lookAt.add_element "longitude"
  lookAtLong.text = "-95.45175"
  
  lookAtLat = lookAt.add_element "latitude"
  lookAtLat.text = "37.68193"
  
  lookAtRange = lookAt.add_element "range"
  lookAtRange.text = "6371000"
  
  lookAtTilt = lookAt.add_element "tilt"
  lookAtTilt.text = "0"
  lookAtHeading = lookAt.add_element "heading"
  lookAtHeading.text = "0" 
  lookAtAltitudeMode = lookAt.add_element "altitudeMode"
  lookAtAltitudeMode.text = "absolute"
  
  #Base Polygon Style
  baseStyle = document.add_element "Style"
  baseStyle.attributes["id"] = "baseStyle"

  baseLineStyle = baseStyle.add_element "LineStyle"
  baseLineColor = baseLineStyle.add_element "color"
  baseLineColor.text = "ffffffff"
  baseLineWidth = baseLineStyle.add_element "width"
  baseLineWidth.text = "1"
  
  baseLabelStyle = baseStyle.add_element "LabelStyle"
  baseLabelColor = baseLabelStyle.add_element "color"
  baseLabelColor.text = "ffffffff"
  baseLabelColorMode = baseLabelStyle.add_element "colorMode"
  baseLabelColorMode.text = "normal"
  baseLabelScale = baseLabelStyle.add_element "scale"
  baseLabelScale.text = "1"

  baseIconStyle = baseStyle.add_element "IconStyle"
  baseIcon = baseIconStyle.add_element "Icon"

  basePolyStyle = baseStyle.add_element "PolyStyle"
  basePolyColor = basePolyStyle.add_element "color"
  basePolyColor.text = "ffffffff"
  basePolyOutline = basePolyStyle.add_element "outline"
  basePolyOutline.text = "0"
  basePolyColorMode = basePolyStyle.add_element "colorMode"
  basePolyColorMode.text = polyColorModeValue

  polygons.each {|key, value| 

    if (idHash[key] == nil)
      puts " Missing data for Polygon #{key}"
    else    
      
      if (idHash[key].class == County)
        dataFileCounty = idHash[key].dataFileCounty
        dataFileState = idHash[key].dataFileState
      
        stateFolder = document.elements["Folder[name=\"#{dataFileState}\"]"]
      
        if stateFolder == nil
          stateFolder = document.add_element "Folder"
          stateFolderName = stateFolder.add_element "name"
          stateFolderName.text = dataFileState
          stateFolderDescription = stateFolder.add_element "description"
          stateFolderDescription.text = ""
          documentOpen = document.add_element "open"
          documentOpen.text = "1"
          stateFolderVisibility = stateFolder.add_element "visibility"
          stateFolderVisibility.text = "1"
        end

        placemark = stateFolder.add_element "Placemark"
        
      else
        
        placemark = document.add_element "Placemark"
      
      end
      
      name = placemark.add_element "name"
      name.text = idHash[key].name
      description = placemark.add_element "description"
      description.text = idHash[key].to_s
      visibility = placemark.add_element "visibility"
      visibility.text = "1"

      styleUrl = placemark.add_element "styleUrl"
      styleUrl.text = "\#baseStyle"

      style = placemark.add_element "Style"
  
      hexColor = dataLogColor(idHash[key].data, maxData, availablePalette)
      polyStyle = style.add_element "PolyStyle"
      polyColor = polyStyle.add_element "color"
      polyColor.text = alpha + hexColor

      polygon = placemark.add_element "Polygon"	
      extrude = polygon.add_element "extrude"
      extrude.text = "1"
      tessellate = polygon.add_element "tessellate"
      tessellate.text = "1"
      altitudeMode = polygon.add_element "altitudeMode"
      #clampToGround relativeToGround absolute
      altitudeMode.text = altitudeModeValue
      outerBoundaryIs = polygon.add_element "outerBoundaryIs"
      linearRing = outerBoundaryIs.add_element "LinearRing"
      coordinates = linearRing.add_element "coordinates"
    
      coordList = String.new
      #value.reverse!
      value.reverse.each {|b| coordList += b.join(", ") + ", #{idHash[key].data}\n"}
      coordinates.text = coordList
      
      # Add a label
      if (polygonCenters != nil)
        
        if (idHash[key].class == County)
          centerPlacemark = stateFolder.add_element "Placemark"
        else
          centerPlacemark = document.add_element "Placemark"
        end
      
        centerPosition = polygonCenters[key].join(",")
      
        centerName = centerPlacemark.add_element "name"
        centerName.text = idHash[key].name
        centerDescription = centerPlacemark.add_element "description"
        centerDescription.text = idHash[key].to_s
        centerVisibility = centerPlacemark.add_element "visibility"
        centerVisibility.text = "1"

        centerBaseStyleUrl = centerPlacemark.add_element "styleUrl"
        centerBaseStyleUrl.text = "\#baseStyle"
        
        centerPoint = centerPlacemark.add_element "Point"
        centerAltitudeMode = centerPoint.add_element "altitudeMode"
        #clampToGround relativeToGround absolute
        centerAltitudeMode.text = altitudeModeValue
        centerCoordinates = centerPoint.add_element "coordinates"
        centerCoordinates.text = "#{centerPosition},#{idHash[key].data}"      
      
      end
      
      polygonsDrawn = polygonsDrawn + 1
      
      #if polygonsDrawn == 2
      #  break
      #end
            
    end
    
    }


  #xmlString = StringIO.open("", "w")
  #zippedOutputFile = GzipWriter.new( File.new(outputFilename,"w+") )
  #zippedOutputFile = GzipWriter.new( outputFilename )

  #xml.write( zippedOutputFile )
  #zippedOutputFile.write( xmlString )
  
  #zippedOutputFile.close
  #outputFilename
  
  #xml.write( File.new("doc.kml","w+"), 0 )
  
  #system("gzip", outputFilename + ".kmz")
  
  #GzipWriter.open("doc.kmz") do |gz|
  #  gz.orig_name = "doc.kml" 
  #  gz.write(File.read("doc.kml"))
  #  gz.close
  #end
  
  ZipFile.open( outputFilename + ".kmz", ZipFile::CREATE) {|zipfile|
    zipfile.get_output_stream("doc.kml") {|file| xml.write(file, 0)}
    }
  
  #xmlString = StringIO.open("", "w+")
  #xml.write( xmlString, 0 )
  #zipWriter = GzipWriter.new(outputFile)
  #xmlString.rewind
  #zipWriter.write( xmlString.read )
  #xmlString.close
  #zipWriter.close
  
  #outputFile = File.new(outputFilename,"w+") 
  #zipWriter = GzipWriter.new(outputFile)
  #xml.write( zipWriter )
  #zipWriter.close
  
end

def genIdHash(dataHash)
  idHash = Hash.new()
  dataHash.each_value {|value| 
    for i in 0...value.id.length
      idHash[value.id[i]] = value
    end }
    return idHash
end

def genOutput(polygonShapeFilename, polygonDataFilename, dataFilename, outputFilename, name, dataFactor, alpha, availablePalette, altitudeModeValue, polyColorModeValue)

  polygons = loadPolygons(polygonShapeFilename)
  dataHash = LoadCountySubDivs(polygonDataFilename)
  idHash = genIdHash(dataHash)
  maxData = LoadCountySubDivData(dataFilename, dataHash, dataFactor)
  puts " maxData: #{maxData}"
  generateKml(outputFilename, name, alpha, altitudeModeValue, polygons, idHash, maxData, availablePalette, polyColorModeValue)

end

def buildMetaKml(kmlFilenames, outputFilename)
  
  xml = Document.new()
  
  xml.add XMLDecl.new()
  kml = xml.add_element "kml"
  kml.add_namespace "http://earth.google.com/kml/2.0"
  
  document = kml.add_element "Document"
  
  kmlFilenames.each do |path|
  
    networkLink = document.add_element "NetworkLink"
  
    networkLinkName = networkLink.add_element "name"
    networkLinkName.text = File.basename(path)
  
    flyToView = networkLink.add_element "flyToView"
    flyToView.text = 0
  
    link = networkLink.add_element "Link"
    href = link.add_element "href"
    href.text = path
  
  end
  
  xml.write( File.new(outputFilename,"w+"), 0 )
  
end

def runCSDs
  
  #availablePalette = buildHexColorTable(Colors::BaseColors)
  #availablePalette = buildRedHexColorTable(Colors::BaseColors, "ff")
  #availablePalette = buildGreenHexColorTable(Colors::BaseColors, "ff")
  #availablePalette = buildBlueHexColorTable(Colors::BaseColors, "ff")

  #genOutput( "ma/cs25_d00.dat", "ma/cs25_d00a.dat", "ma/csd_pop_ma.csv", "csd_pop_ma.kml", "Population by County Subdivision", 0.1, "cc", 
  #  buildHexColorTable(Colors::BaseColors), "absolute", "normal")

  #genOutput( "wa/cs53_d00.dat", "wa/cs53_d00a.dat", "wa/csd_pop_wa.csv", "csd_pop_wa.kml", "Population by County Subdivision", 0.1, "cc", 
  #  buildHexColorTable(Colors::BaseColors), "absolute", "normal")

  #genOutput( "ca/cs06_d00.dat", "ca/cs06_d00a.dat", "ca/csd_pop_ca.csv", "csd_pop_ca.kml", "Population by County Subdivision", 0.1, "cc", 
  #  buildHexColorTable(Colors::BaseColors), "absolute", "normal")

  #genOutput( "tx/cs48_d00.dat", "tx/cs48_d00a.dat", "tx/csd_pop_tx.csv", "csd_pop_tx.kml", "Population by County Subdivision", 0.1, "cc", 
  #  buildHexColorTable(Colors::BaseColors), "absolute", "normal")

  kmlFilenames = Array.new()

  Find.find("/Users/aidan/Desktop/Census 2000 CSDs") do |path|
    if path.match("a.dat") 
      filename = File.basename(path, "a.dat")
      path = File.dirname(path)
      polyShapeFilename = path + "/" + filename + ".dat"
      polyDataFilename = path + "/" + filename + "a.dat"
      outputFilename = Dir.getwd + "/batch_outputs/" + filename
      puts "Starting #{filename}"
      genOutput( polyShapeFilename, polyDataFilename, "/Users/aidan/Desktop/us_pop_csd.csv", outputFilename, "Population by County Subdivision", 0.2, "ff", 
        buildRedHexColorTable(Colors::BaseColors, "ff").reverse, "absolute", "normal")
      kmlFilenames.push outputFilename + ".kmz"
      puts "Done #{filename}"
    end
  end

  buildMetaKml(kmlFilenames, "master.kml")

  puts "Done!"
  
end

def genCountyOutput()
  
  directory = "/Users/aidan/Desktop/Census 2000 Cs/"
  polygonMetaDataFilename = "co99_d00a.dat"
  polygonShapeFilename = "co99_d00.dat"
  #dataFilename = "dc_dec_2000_sf3_u_data1.txt"
  dataFilename = "movement.csv"

  dataHash = loadCountyMeta(directory + polygonMetaDataFilename)
  polygons = loadPolygons(directory + polygonShapeFilename)
  idHash = genIdHash(dataHash)

  #File.open(directory + "polygons.yaml", "w") {|file| YAML.dump(polygons, file)}
  #File.open(directory + "idHash.yaml", "w") {|file| YAML.dump(idHash, file)}

  colors = ["0000ff","0011ee","0022dd","0033cc","0044bb","0055aa","006699","007788","008877","009966","00aa55","00bb44","00cc33","00dd22","00ee11","00ff00"]
  #colors = ["ff0000","ee1100","dd2200","cc3300","bb4400","aa5500","996600","887700","778800","669900","55aa00","44bb00","33cc00","22dd00","11ee00","00ff00"]

  maxData = LoadCountyData(directory + dataFilename, dataHash, 10, 13 )
  generateKml( directory + "2000_moved_from_NE", "2000 Census Migration from New England", "ff", "absolute", polygons, 
    idHash, maxData, colors.reverse, "normal" )
  
  maxData = LoadCountyData(directory + dataFilename, dataHash, 10, 14 )
  generateKml( directory + "2000_moved_from_MW", "2000 Census Migration from Midwest", "ff", "absolute", polygons, 
    idHash, maxData, colors.reverse, "normal" )
  
  maxData = LoadCountyData(directory + dataFilename, dataHash, 10, 15 )
  generateKml( directory + "2000_moved_from_South", "2000 Census Migration from South", "ff", "absolute", polygons, 
    idHash, maxData, colors.reverse, "normal" )
  
  maxData = LoadCountyData(directory + dataFilename, dataHash, 10, 16 )
  generateKml( directory + "2000_moved_from_West", "2000 Census Migration from West", "ff", "absolute", polygons, 
    idHash, maxData, colors.reverse, "normal" )
  
end

def genColorOutput
  file = File.open("colors.html", "w")
  file.write("<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\">
  <html lang=\"en\">
  <head>
  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">
  <title>Colors</title>
  </head>
  <body>")
  colors = buildGreenHexColorTable(Colors::BaseColors, "cc")
  colors.each {|color| file.write("<div style=\"background-color:\##{color.reverse};height:10px;width:40px;\"></div>")}
  file.write("</body>
  </html>")
end

def genHIOutput()
  
  baseDir = "/Users/aidan/Desktop/"
  projectDir = "Census 2000 Hawaii Population/"
  polygonShapeFile = baseDir + projectDir + "cs15_d00.dat"
  polygonMetaDataFile = baseDir + projectDir + "cs15_d00a.dat"
  dataFile = baseDir + projectDir + "aidan.s.marcuss@gmail.com-4-gis.csv"
     
  polygons = loadPolygons(polygonShapeFile)
  polygonCenters = loadPolygonCenters(polygonShapeFile)
  pp polygonCenters
  
  dataHash = LoadCountySubDivs(polygonMetaDataFile)

  idHash = genIdHash(dataHash)
  
  maxData = LoadCountySubDivData(dataFile, dataHash, 0.1)

  generateKml( baseDir + projectDir + "HI 2000 Pop by County Subdivision", "HI 2000 Pop by County Subdivision", "ff", "absolute", polygons, polygonCenters,
    idHash, maxData, Colors::RedtoGreen16Colors.reverse, "normal")
  
end


