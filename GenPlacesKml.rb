#!/usr/bin/env ruby
#
#  Created by Aidan Marcuss on 2007-03-06.
#  Copyright (c) 2007. All rights reserved.

require "rexml/document"

require "find"
require "stringio"
require "yaml"
require "pp"
require "rubygems"
require "currency"

require "zip/zip"

require "Polygon"
require "CountySubDiv"
require "County"
require "Colors"
require "BlockGroups"
require "Data"
require "CongressionalDistrict"
require "FEC"
require "FIPS"
require "State"
require "PresPoll"

include REXML
include Zip

include Colors

def genKmlDec(xml)
  
  xml.add XMLDecl.new()
  kml = xml.add_element "kml"
  kml.add_namespace "http://earth.google.com/kml/2.1"
  
  return kml
  
end

def genDoc(kml, name)
  
  document = kml.add_element "Document"
  documentName = document.add_element "name"
  documentName.text = name
  documentDescription = document.add_element "description"
  documentDescription.add CData.new( "This map represents the total amount received by House of Representative candidates in each Congressional District for a given election cycle. For each $1,000 received, the district gets one meter in height. The districts with higher amounts are more green, those with lower amounts are more red. Generated by Aidan Marcuss on #{Time.now.getgm}.<br>Published at <a href=\"http://censuskml.blogspot.com/\">CensusKML</a>.<br>Campaign data provided by the<a href=\"http://www.fec.gov/\">FEC</a> and was downloaded from <a href=\"http://www.fec.gov/finance/disclosure/ftpsum.shtml\">Summary Campaign Finance Data Files</a> page. Geographic boundary files provided by US Census <a href=\"http://www.census.gov/geo/www/cob/bdy_files.html\">here</a>.")
  documentVisibility = document.add_element "visibility"
  documentVisibility.text = "1"
  documentOpen = document.add_element "open"
  documentOpen.text = "1"
  
  return document
  
end

def genLookAt(document)
  
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
  
  return lookAt
  
end

def genStyle(parent, id)
  
  style = parent.add_element "Style"
  
  if (id != nil)
    style.attributes["id"] = id
  end

  return style 
  
end

def genStyleMap(parent, id)
  
  styleMap = parent.add_element "StyleMap"
  
  if (id != nil)
    styleMap.attributes["id"] = id
  end

  return styleMap 
  
end

def genLineStyle(style, id, colorValue, widthValue)
  
  lineStyle = style.add_element "LineStyle"
  
  if (id != nil)
    lineStyle.attributes["id"] = id
  end
  
  lineColor = lineStyle.add_element "color"
  lineColor.text = colorValue
  
  lineWidth = lineStyle.add_element "width"
  lineWidth.text = widthValue.to_s
  
  return lineStyle
  
end

def genLabelStyle(style, id, colorValue, colorModeValue, scaleValue)

  labelStyle = style.add_element "LabelStyle"
  
  if (id != nil)
    labelStyle.attributes["id"] = id
  end
  
  labelColor = labelStyle.add_element "color"
  labelColor.text = colorValue

  #random, normal
  labelColorMode = labelStyle.add_element "colorMode"
  labelColorMode.text = colorModeValue

  labelScale = labelStyle.add_element "scale"
  labelScale.text = scaleValue.to_s

  return labelStyle
  
end

def genNoIconStyle(style)
  
  noIconStyle = style.add_element "IconStyle"
  noIconStyle.attributes["id"] = "noicon"
  
  noIcon = noIconStyle.add_element "Icon"
  
  return noIconStyle
  
end

def genIconStyle(style, id, scaleValue, hrefValue)
  
  iconStyle = style.add_element "IconStyle"
  
  if (id != nil)
    iconStyle.attributes["id"] = id
  end
  
  scale = iconStyle.add_element "scale"
  scale.text = scaleValue.to_s
  
  icon = iconStyle.add_element "Icon"
  
  href = icon.add_element "href"
  href.text = hrefValue
  
  return iconStyle
  
end

def genPolyStyle(style, id, colorValue, outlineValue, colorModeValue)

  polyStyle = style.add_element "PolyStyle"
  
  if (id != nil)
    polyStyle.attributes["id"] = id
  end
  
  if (colorValue != nil)
    polyColor = polyStyle.add_element "color"
    polyColor.text = colorValue
  end
  
  if (outlineValue != nil)
    polyOutline = polyStyle.add_element "outline"
    polyOutline.text = outlineValue.to_s
  end
  
  if (colorModeValue != nil)
    polyColorMode = polyStyle.add_element "colorMode"
    polyColorMode.text = colorModeValue
  end
  
  return polyStyle
  
end

def genStyleMapPair(styleMap, keyValue, styleUrlValue)

  pair = styleMap.add_element "Pair"
  
  key = pair.add_element "key"
  key.text = keyValue
  
  styleUrl = pair.add_element "styleUrl"
  styleUrl.text = styleUrlValue
  
  return pair

end

def genBaseNormalStyle(document, styleNameValue, polyColorModeValue)
  
  style = genStyle( document, styleNameValue)
  
  genLineStyle( style, nil, "ffffffff", 1)
  genLabelStyle( style, nil, "00ffffff", "normal", 1)
  genIconStyle( style, nil, 0.4, "http://maps.google.com/mapfiles/kml/shapes/open-diamond.png" )
  genPolyStyle( style, nil, "ffffffff", 0, polyColorModeValue)
  
  return style
  
end 

def genBaseHighlightStyle(document, styleNameValue)
  
  style = genStyle( document, styleNameValue)
  genLabelStyle( style, nil, "ffffffff", "normal", 1)
  genLineStyle( style, nil, "ffffffff", 2)
  genIconStyle( style, nil, 1, "http://maps.google.com/mapfiles/kml/shapes/open-diamond.png" )
  genPolyStyle( style, nil, nil, 1, nil)
  
  return style
  
end

def genBaseStyleMap(document, styleMapNameValue, baseNormalStyleNameValue, baseHighlightStyleNameValue)

  styleMap = genStyleMap(document, styleMapNameValue)
  genStyleMapPair( styleMap, "normal", baseNormalStyleNameValue)
  genStyleMapPair( styleMap, "highlight", baseHighlightStyleNameValue)

  return styleMap
  
end

def genFolder(parent, nameValue, descriptionValue, visibilityValue, openValue)
  
  folder = parent.add_element "Folder"
  folderName = folder.add_element "name"
  folderName.text = nameValue
  folderDescription = folder.add_element "description"
  folderDescription.text = descriptionValue
  folderVisibility = folder.add_element "visibility"
  folderVisibility.text = visibilityValue
  folderOpen = folder.add_element "open"
  folderOpen.text = openValue
  
  return folder
  
end

def genPlacemark(parent, nameValue, descriptionValue, visibilityValue, styleUrlValue, colorValue, colorModeValue)
  
    placemark = parent.add_element "Placemark"

    name = placemark.add_element "name"
    name.text = nameValue

    description = placemark.add_element "description"
    description.text = descriptionValue

    visibility = placemark.add_element "visibility"
    visibility.text = visibilityValue

    styleUrl = placemark.add_element "styleUrl"
    styleUrl.text = styleUrlValue

    style = genStyle( placemark, nil )
    polyStyle = genPolyStyle( style, nil, colorValue, nil, colorModeValue )

    return placemark
    
end

def genTimeSpan(placemark, beginValue, endValue = nil)

    timeSpan = placemark.add_element "TimeSpan"
    beginElement = timeSpan.add_element "begin"
    beginElement.text = beginValue
    if (endValue != nil)
      endElement = timeSpan.add_element "end"
      endElement.text = endValue
    end
    return timeSpan

end

def genMultiGeometry(placemark)

    multiGeometry = placemark.add_element "MultiGeometry"
    return multiGeometry

end

def genCenterPoint(parent, altitudeModeValue, coords)

  centerPoint = parent.add_element "Point"
  centerAltitudeMode = centerPoint.add_element "altitudeMode"
  #clampToGround relativeToGround absolute
  centerAltitudeMode.text = altitudeModeValue
  centerCoordinates = centerPoint.add_element "coordinates"
  centerCoordinates.text = coords

  return centerPoint
  
end

def genPolygon( parent, extrudeValue, altitudeModeValue, mainCoords, exCoords, data, mapObjectId )

  polygon = parent.add_element "Polygon"	
  extrude = polygon.add_element "extrude"
  extrude.text = extrudeValue
  # No good reason to make this variable
  tessellate = polygon.add_element "tessellate"
  tessellate.text = "1"
  altitudeMode = polygon.add_element "altitudeMode"
  #clampToGround relativeToGround absolute
  altitudeMode.text = altitudeModeValue
  
  outerBoundaryIs = polygon.add_element "outerBoundaryIs"
  outerBoundaryLinearRing = outerBoundaryIs.add_element "LinearRing"
  outerBoundaryCoordinates = outerBoundaryLinearRing.add_element "coordinates"

  outerBoundaryCoordList = String.new
  mainCoords.reverse.each {|b| outerBoundaryCoordList += b.join(", ") + ", #{data}\n"}
  outerBoundaryCoordinates.text = outerBoundaryCoordList

  if (exCoords.length != 0)
    
    puts " #{mapObjectId} has a cut out"
    
    innerBoundaryIs = polygon.add_element "innerBoundaryIs"
    innerBoundaryLinearRing = innerBoundaryIs.add_element "LinearRing"
    innerBoundaryCoordinates = innerBoundaryLinearRing.add_element "coordinates"

    innerBoundaryCoordList = String.new
    exCoords.reverse.each {|b| innerBoundaryCoordList += b.join(", ") + ", #{data}\n"}
    innerBoundaryCoordinates.text = innerBoundaryCoordList
  end
  
  return polygon

end

def generateOutput(outputFilename, name, alpha, altitudeModeValue, mapObjects, maxData, colorDataFactor, heightDataFactor, availablePalette, polyColorModeValue)

  puts "Generating KMZ Output"

  mapObjectsDrawn = 0

  startTime = Time.gm(2007,1,1)
  endTime = Time.gm(2008,12,31)
  
  xml = Document.new()
  
  kml = genKmlDec( xml )
  doc = genDoc( kml, name )
  lookAt = genLookAt( doc )
  
  baseNormalStyleName = "baseNormalStyle"
  baseHighlightStyleName = "baseHighlightStyle"
  baseStyleMapName = "baseStyleMap"
  
  genNormalBaseStyle = genBaseNormalStyle( doc, baseNormalStyleName, polyColorModeValue )
  genBaseHighlightStyle = genBaseHighlightStyle( doc, baseHighlightStyleName )
  getBaseStyleMap = genBaseStyleMap( doc, baseStyleMapName, baseNormalStyleName, baseHighlightStyleName )
  
  #labelsFolder = genFolder( doc, "Labels", "A folder to hold all of the geography labels", "1", "0")
  #geosFolder = genFolder( doc, "Congressional Districts", "", "1", "0")

  mapObjects.each do |mapObjectkey, mapObject| 
    
    name = mapObject.complete_name
    data = mapObject.data
    
    name = name + " " + Currency::Money(data, :USD).to_s(:cents => false, :code => false)
    
    factoredData = data * heightDataFactor
    
    puts "#{data}, #{colorDataFactor}, #{maxData}"

    #hexColor = dataLogColor(data * colorDataFactor, maxData * colorDataFactor, availablePalette)
    hexColor = dataColor(data * colorDataFactor, maxData * colorDataFactor, availablePalette)

    #labelPlacemark = genPlacemark( labelsFolder, name, "", "1", "\##{baseNormalStyleName}", "ffffffff" )
    
    geoPlacemark = genPlacemark( doc, name, "", "1", "\##{baseStyleMapName}", alpha + hexColor, polyColorModeValue )
    
    timeSpan = genTimeSpan( geoPlacemark, startTime.strftime("%Y-%m-%d"), endTime.strftime("%Y-%m-%d"))
    #startTime = startTime + (60 * 60 * 24)
    
    multiGeometry = genMultiGeometry( geoPlacemark )
  
    mapObject.polygons.each do |polygonKey, polygon|

      genCenterPoint( multiGeometry, altitudeModeValue, "#{polygon.centerLon},#{polygon.centerLat},#{factoredData}" )
      genPolygon( multiGeometry, "1", altitudeModeValue, polygon.mainCoords, polygon.exCoords, factoredData, mapObject.complete_id )
  
    end
  
    mapObjectsDrawn = mapObjectsDrawn + 1
      
  end
  
  ZipFile.open( outputFilename + ".kmz", ZipFile::CREATE) {|zipfile|
    zipfile.get_output_stream("doc.kml") {|file| xml.write(file, 0)}
    }
  
  puts "Done generating KMZ Output. #{mapObjectsDrawn} objects drawn."
  
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

def genWABlockGroups()
  
  baseDir = "/Users/aidan/Desktop/"
  projectDir = "Census 2000 WA BGs/"
  polygonShapeFile = baseDir + projectDir + "bg53_d00.dat"
  polygonMetaDataFile = baseDir + projectDir + "bg53_d00a.dat"
  dataFile = baseDir + projectDir + "Median HH Value.txt"
  outputFile = baseDir + projectDir + "output"
  
  polygons = loadPolygonObjs( polygonShapeFile )
  blockGroups = loadBlockGroupMetaData( polygonMetaDataFile, polygons )
  maxData = loadData(dataFile, ",", 0, 5, 7, blockGroups)
  
  #clampToGround relativeToGround absolute
  generateOutput(outputFile, "WA Block Groups", "ff", "absolute", blockGroups.sort {|x,y| x[1].data <=> y[1].data} , 
    maxData, 0.0001, 0.1, Colors::RedtoGreen16Colors.reverse, "normal") 
  
end

def genWACSDs()
  
  baseDir = "/Users/aidan/Desktop/"
  projectDir = "WA CSDs/"
  polygonShapeFile = baseDir + projectDir + "cs53_d00.dat"
  polygonMetaDataFile = baseDir + projectDir + "cs53_d00a.dat"
  dataFile = baseDir + projectDir + "dc_dec_2000_sf3_u_data1.txt"
  outputFile = baseDir + projectDir + "WA CSD Median HH Value"
  
  polygons = loadPolygonObjs( polygonShapeFile )
  countySubDivs = loadCountySubDivMetaData( polygonMetaDataFile, polygons )
  maxData = loadData(dataFile, "|", 2, 1, 5, countySubDivs)
  
  #clampToGround relativeToGround absolute
  generateOutput(outputFile, "WA Median HH Value", "ff", "absolute", countySubDivs.sort {|x,y| x[1].data <=> y[1].data} , 
    maxData, 0.00001, 0.1, Colors::RedtoGreen16Colors.reverse, "normal")
end

def runCDs
  
  congress = "110"
  baseDir = "/Users/aidan/Desktop/"
  projectDir = "Congressional Districts/"
  shapeDataDir = "#{congress} Shape Data/"
  mapDataDir = "Map Data/"
  dataFile = "WEBL06.DAT"

  outputDir = "#{congress} outputs/"
  kmlFilenames = Array.new()

  fecs = loadFECData( baseDir + projectDir + mapDataDir + dataFile )
  totalsByHouseDistrict = fecs.getTotalByHouseDistrict( "totalReceipts" )

  Find.find(baseDir + projectDir + shapeDataDir) do |path|
    if path.match("a.dat") 
      
      filename = File.basename(path, "a.dat")
      path = File.dirname(path)
      
      polyShapeFilename = path + "/" + filename + ".dat"
      polyMetaDataFilename = path + "/" + filename + "a.dat"
      
      stateName = FIPS::StateCodeFIPS[filename[2..3]][1]
          
      outputFilename = baseDir + projectDir + outputDir + stateName + " #{congress}th Congress"
  
      puts "Starting #{filename} ---------------------------------------------------"
      
      polygons = loadPolygonObjs( polyShapeFilename )
      cds = loadCongressionalDistrictMetaData( polyMetaDataFilename, polygons )
      maxData = fillCongressionalDistrictsWithData( cds, totalsByHouseDistrict )
      
      generateOutput(outputFilename, "#{stateName} #{congress}th Congressional Districts", "ff", "absolute", cds.sort, 
        maxData, 0.000001, 0.1, Colors::RedtoGreen16Colors, "normal")
        
      kmlFilenames.push outputFilename + ".kmz"
      
      puts "Done #{filename} -------------------------------------------------------"
      
    end
  end

  buildMetaKml(kmlFilenames, baseDir + projectDir + "109 master.kml")

  puts "Done!"
  
end

def genStates()
  
  baseDir = "/Users/aidan/Desktop/"
  projectDir = "st99_d00_ascii/"
  polygonShapeFile = baseDir + projectDir + "st99_d00.dat"
  polygonMetaDataFile = baseDir + projectDir + "st99_d00a.dat"
  dataFile = baseDir + projectDir + "pres_polls.csv"
  outputFile = baseDir + projectDir + "State Polls"
  
  presPolls = loadPresData(dataFile)
  
  #polygons = loadPolygonObjs( polygonShapeFile )
  #states = loadStateMetaData( polygonMetaDataFile, polygons )
  #maxData = loadRandomData(states, 100)
  
  #clampToGround relativeToGround absolute
  #generateOutput(outputFile, "States Random", "ff", "absolute", states.sort {|x,y| x[1].data <=> y[1].data} , 
  #  maxData, 1000, 100, buildBlueHexColorTable(Colors::BaseColors, "ff"), "normal")
end

genStates()