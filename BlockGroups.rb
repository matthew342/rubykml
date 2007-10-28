#!/usr/bin/env ruby
#
#  Created by Aidan Marcuss on 2007-03-06.
#  Copyright (c) 2007. All rights reserved.

class BlockGroup
  attr_reader :state, :county, :tract, :blockGroup, :lsad, :lsadTrans, :misc, :data, :polygons
  attr_writer :data
    
  def initialize(state, county, tract, blockGroup, lsad, lsadTrans, misc, data = 0)
    @state = state
    @county = county
    @tract = tract
    @blockGroup = blockGroup
    @lsad = lsad
    @lsadTrans = lsadTrans
    @misc = misc
    @data = data
    @polygons = Hash.new()
  end

  def to_s
    "State: #{@state}\n - County: #{@county}\n - Tract: #{@tract}\n - Block Group: #{@blockGroup}\n - Data: #{data}"
  end

  def complete_id
    BlockGroup.get_complete_id(@state, @county, @tract, @blockGroup)
  end
  
  def complete_name
    "#{@lsadTrans}: #{complete_id}"
  end
  
  def BlockGroup.get_complete_id(state, county, tract, blockGroup)
    "#{state}#{county}#{tract}#{blockGroup}"
  end

end

def loadBlockGroupMetaData(fileName, polygons)

  puts "Loading BlockGroup objects"

  blockGroups = Hash.new()

  File.open( fileName,"r") do |file|
    while line = file.gets
      #puts "line #{file.lineno}: #{line}"
      if line.strip != "" 
        id = line.to_i
        if (id != 0)
          
          state = file.gets[/\d+/].ljust(2,"0")
          county = file.gets[/\d+/].rjust(3,"0")
          tract =  file.gets[/\d+/].ljust(6,"0")
          blockGroup = file.gets[/\d+/]
          lsad = file.gets[/\d+/]
          lsadTrans = file.gets[/\w+/]
          misc = file.gets
          
          blockGroupId = BlockGroup.get_complete_id(state, county, tract, blockGroup)
          
          if blockGroups[blockGroupId] != nil 
            blockGroups[blockGroupId].polygons[id] = polygons[id]
          else
            blockGroups[blockGroupId] = BlockGroup.new(state, county, tract, blockGroup, lsad, lsadTrans, misc)
            blockGroups[blockGroupId].polygons[id] = polygons[id]
          end
          
        end
      end
    end
  end
  
  puts "Done loading BlockGroup objects. #{blockGroups.length} BlockGroups added."
  
  return blockGroups
  
end

def LoadBlockGroupData(bgHash)

  File.open("Pop_edit.csv", "r") do |file|
    while line = file.gets
      if line.strip != ""
        blockGroupId, blockGroupData = line.split(",")
        blockGroupData = blockGroupData.strip != "" ? Float(blockGroupData.strip) : Float(0)
        if bgHash[blockGroupId.strip] != nil  
          bgHash[blockGroupId.strip].data = blockGroupData
        end
      end
    end
  end
  
end

