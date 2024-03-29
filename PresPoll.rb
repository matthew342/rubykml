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

require "parsedate"

class PresPoll
  attr_reader :midPoint, :length; :stateName; :ev; :dem; :gop; :ind; :endDate; :pollster
    
  def initialize(midPoint, length, stateName, ev, dem, gop, ind, endDate, pollster)
    @midPoint = midPoint
    @length = length
    @stateName = stateName
    @ev = ev
    @dem = dem
    @gop = gop
    @ind = ind
    @endDate = endDate
    @pollster = pollster
  end

  def to_s
    "#{@stateName} - #{@pollster} - #{@endDate}: DEM #{@dem}, GOP #{@gop}"
  end

  def complete_id
    PresPoll.get_complete_id(@stateName, @pollster, @endDate)
  end
  
  def complete_state_name
    "#{@stateName}"
  end
  
  def PresPoll.get_complete_id(stateName, pollster, endDate)
    "#{stateName} - #{pollster} - #{endDate} "
  end

end

def loadPresData(filename)

  puts "Loading polls"
  
  loadedPolls = 0
  headerLines = 1
  separator = ","
  
  presPolls = Hash.new()
    
  File.open(filename, "r") do |file|
    
    #Skip headers
    for i in 0...headerLines
      file.gets
    end
    
    while line = file.gets
      if line.strip != ""
        
        lineFields = line.split( separator )
        
        midPoint = lineFields[0].strip  
        length = Integer(lineFields[1].strip)
        stateName = lineFields[2].strip
        ev = Integer(lineFields[3].strip)
        dem = Integer(lineFields[4].strip)
        gop = Integer(lineFields[5].strip)
        if lineFields[6].strip != ""
          ind = Integer(lineFields[6].strip)
        end
        endDate = ParseDate.parsedate(lineFields[7].strip)
        pollster = lineFields[15].strip
              
        pollID = PresPoll.get_complete_id(stateName, pollster, endDate)
        
        presPolls[pollID] = PresPoll.new(midPoint, length, stateName, ev, dem, gop, ind, endDate, pollster)
        
        puts "\t#{presPolls[pollID]}\n"
        
      end
    end
  end
  
  puts "Done loading #{polls} polls."
  
  return presPolls
  
end
