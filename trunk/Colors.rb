#!/usr/bin/env ruby
#
#  Created by Aidan Marcuss on 2007-03-06.
#  Copyright (c) 2007. All rights reserved.

module Colors

  BaseColors = [ "00", "33", "66", "99", "cc", "ff"]
  RedtoGreen16Colors = ["0000ff","0011ee","0022dd","0033cc","0044bb","0055aa","006699","007788","008877","009966","00aa55","00bb44","00cc33","00dd22","00ee11","00ff00"]
  
  def buildHexColorTable (baseColors)
    numBaseColors = baseColors.length 
    numOutputColors =  numBaseColors**3 
    num2ndTierRepeats = numBaseColors**2
    
    outputColors = Array.new(numOutputColors)

    #green
    outputColors.each_index{|x| outputColors[x] = baseColors[x.div(num2ndTierRepeats)] }

    #blue
    outputColors.each_index{|x| outputColors[x] += baseColors[(x-x.div(num2ndTierRepeats)*num2ndTierRepeats).div(numBaseColors)] }
          
    #red
    outputColors.each_index{|x| outputColors[x] += baseColors[x.modulo(numBaseColors)] }
    


    
    return outputColors
  end

  def buildRedHexColorTable (baseColors, red)
    numBaseColors = baseColors.length 
    numOutputColors = numBaseColors**2 
    num2ndTierRepeats = numBaseColors**2
    
    outputColors = Array.new(numOutputColors)

    #html -> red, green, blue
    #ge -> blue, green, red
    
    outputColors.each_index{|x| outputColors[x] = baseColors[x.modulo(numBaseColors)] }
    outputColors.each_index{|x| outputColors[x] += baseColors[x.div(numBaseColors)] }
    outputColors.each_index{|x| outputColors[x] += red }
    
    return outputColors
  end
  
  def buildGreenHexColorTable (baseColors, green)
    numBaseColors = baseColors.length 
    numOutputColors = numBaseColors**2 
    num2ndTierRepeats = numBaseColors**2
    
    outputColors = Array.new(numOutputColors)
    
    outputColors.each_index{|x| outputColors[x] = baseColors[x.div(numBaseColors)] }  
    outputColors.each_index{|x| outputColors[x] += green }
    outputColors.each_index{|x| outputColors[x] += baseColors[x.modulo(numBaseColors)] }
        
    return outputColors
  end
  
  def buildBlueHexColorTable (baseColors, blue)
    numBaseColors = baseColors.length 
    numOutputColors = numBaseColors**2 
    num2ndTierRepeats = numBaseColors**2
    
    outputColors = Array.new(numOutputColors)
  
    outputColors.each_index{|x| outputColors[x] = blue }
    outputColors.each_index{|x| outputColors[x] += baseColors[x.modulo(numBaseColors)] }
    outputColors.each_index{|x| outputColors[x] += baseColors[x.div(numBaseColors)] }
        
    return outputColors
  end

  def simpleIncrColor (hexColor)
    
    blue = hexColor[0,2].hex
    green = hexColor[2,2].hex
    red = hexColor[4,2].hex
  
    #puts "B #{blue}, G #{green}, R #{red}"
  
    if (blue < 255)
      blue += 51    
    elsif (green < 255)
      green += 51
    elsif (red < 255)
      red += 51
    else
      blue = 0
      green = 0
      red = 0
    end
  
    if blue.to_s(base=16).length == 1
      result = "0" + blue.to_s(base=16)
    else
      result = blue.to_s(base=16)
    end

    if green.to_s(base=16).length == 1
      result += "0" + green.to_s(base=16)
    else
      result += green.to_s(base=16)
    end
  
    if red.to_s(base=16).length == 1
      result += "0" + red.to_s(base=16)
    else
      result += red.to_s(base=16)
    end

    return result
  
  end

  def betterIncrColor (hexColor)
    
    decColor = hexColor.hex

    if decColor < 16777215
      decColor += "33".hex
    else
      decColor = 0
      puts "rounded color scheme"
    end
  
    result = decColor.to_s(base=16)
    result = result.rjust(6,"0")

    return result
  
  end

  def dataColor (data, dataMax, availableColors)

    if dataMax == 0
      return "ffffff"
    else
      dataPercent = data / dataMax
      paletteLength = availableColors.length - 1

      #puts "dataPercent : #{dataPercent}, PaletteColor #{(paletteLength * dataPercent).floor.to_i}"
  
      return availableColors[(paletteLength * dataPercent).floor.to_i]
    end
    
  end

  def dataLogColor (data, dataMax, availableColors)

    if dataMax == 0
      return "ffffff"
    elsif data == 0
      return "ffffff"
    elsif Math::log(data) <= 0
      return availableColors[0]
    else
      dataPercent = Math::log(data) / Math::log(dataMax)
      paletteLength = availableColors.length - 1

      #puts " data: #{data}; Math::log(data): #{Math::log(data)}; Math::log(dataMax): #{Math::log(dataMax)}"
      #puts "dataPercent : #{dataPercent}, PaletteColor #{(paletteLength * dataPercent).floor.to_i}"

      return availableColors[(paletteLength * dataPercent).floor.to_i]
    end
    
  end

end