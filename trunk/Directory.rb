#!/usr/bin/env ruby
#
#  Created by Aidan Marcuss on 2007-03-08.
#  Copyright (c) 2007. All rights reserved.

require "find"

Find.find("/Users/aidan/Desktop/Census 2000 CSDs") do |path|
  if path.match("a.dat") 
    filename = File.basename(path, "a.dat")
    puts filename
  end
end

mainDirectory = File.new("/Users/aidan/Desktop/Census 2000 CSDs")
mainDirectory