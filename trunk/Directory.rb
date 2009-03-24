#!/usr/bin/env ruby
#
#  Created by Aidan Marcuss on 2007-03-08.
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

require "find"

Find.find("/Users/aidan/Desktop/Census 2000 CSDs") do |path|
  if path.match("a.dat") 
    filename = File.basename(path, "a.dat")
    puts filename
  end
end

mainDirectory = File.new("/Users/aidan/Desktop/Census 2000 CSDs")
mainDirectory