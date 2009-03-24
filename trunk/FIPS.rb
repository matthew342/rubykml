#!/usr/bin/env ruby
#
#  Created by Aidan Marcuss on 2007-04-10.
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

#^([A-Za-z ]+)\n(\d+)\n([A-Za-z ]+)$
#$3,$2,$1

#^([A-Z]+),(\d+),([A-Za-z ]+)$
#"$1" => [ "$2", "$3"],

module FIPS 

  StateAbbrFIPS = {
    "AL" => [ "01", "Alabama"],
    "MO" => [ "29", "Missouri"],
    "AK" => [ "02", "Alaska"],
    "MT" => [ "30", "Montana"],
    "AZ" => [ "04", "Arizona"],
    "NE" => [ "31", "Nebraska"],
    "AR" => [ "05", "Arkansas"],
    "NV" => [ "32", "Nevada"],
    "CA" => [ "06", "California"],
    "NH" => [ "33", "New Hampshire"],
    "CO" => [ "08", "Colorado"],
    "NJ" => [ "34", "New Jersey"],
    "CT" => [ "09", "Connecticut"],
    "NM" => [ "35", "New Mexico"],
    "DE" => [ "10", "Delaware"],
    "NY" => [ "36", "New York"],
    "DC" => [ "11", "District of Columbia"],
    "NC" => [ "37", "North Carolina"],
    "FL" => [ "12", "Florida"],
    "ND" => [ "38", "North Dakota"],
    "GA" => [ "13", "Georgia"],
    "OH" => [ "39", "Ohio"],
    "OK" => [ "40", "Oklahoma"],
    "OR" => [ "41", "Oregon"],
    "HI" => [ "15", "Hawaii"],
    "PA" => [ "42", "Pennsylvania"],
    "ID" => [ "16", "Idaho"],
    "RI" => [ "44", "Rhode Island"],
    "IL" => [ "17", "Illinois"],
    "SC" => [ "45", "South Carolina"],
    "IN" => [ "18", "Indiana"],
    "SD" => [ "46", "South Dakota"],
    "IA" => [ "19", "Iowa"],
    "TN" => [ "47", "Tennessee"],
    "KS" => [ "20", "Kansas"],
    "TX" => [ "48", "Texas"],
    "KY" => [ "21", "Kentucky"],
    "UT" => [ "49", "Utah"],
    "LA" => [ "22", "Louisiana"],
    "VT" => [ "50", "Vermont"],
    "ME" => [ "23", "Maine"],
    "VA" => [ "51", "Virginia"],
    "MD" => [ "24", "Maryland"],
    "WA" => [ "53", "Washington"],
    "MA" => [ "25", "Massachusetts"],
    "WV" => [ "54", "West Virginia"],
    "MI" => [ "26", "Michigan"],
    "WI" => [ "55", "Wisconsin"],
    "MN" => [ "27", "Minnesota"],
    "WY" => [ "56", "Wyoming"],
    "MS" => [ "28", "Mississippi"],
    "AS" => [ "60", "American Samoa"],
    "FM" => [ "64", "Federated States of Micronesia"],
    "GU" => [ "66", "Guam"],
    "MH" => [ "68", "Marshall Islands"],
    "MP" => [ "69", "Northern Mariana Islands"],
    "PW" => [ "70", "Palau"],
    "PR" => [ "72", "Puerto Rico"],
    "UM" => [ "74", "U.S. Minor Outlying Islands"],
    "VI" => [ "78", "Virgin Islands of the U.S."]
  }

  StateCodeFIPS = {
    "01" => [ "AL", "Alabama"],
    "29" => [ "MO", "Missouri"],
    "02" => [ "AK", "Alaska"],
    "30" => [ "MT", "Montana"],
    "04" => [ "AZ", "Arizona"],
    "31" => [ "NE", "Nebraska"],
    "05" => [ "AR", "Arkansas"],
    "32" => [ "NV", "Nevada"],
    "06" => [ "CA", "California"],
    "33" => [ "NH", "New Hampshire"],
    "08" => [ "CO", "Colorado"],
    "34" => [ "NJ", "New Jersey"],
    "09" => [ "CT", "Connecticut"],
    "35" => [ "NM", "New Mexico"],
    "10" => [ "DE", "Delaware"],
    "36" => [ "NY", "New York"],
    "11" => [ "DC", "District of Columbia"],
    "37" => [ "NC", "North Carolina"],
    "12" => [ "FL", "Florida"],
    "38" => [ "ND", "North Dakota"],
    "13" => [ "GA", "Georgia"],
    "39" => [ "OH", "Ohio"],
    "40" => [ "OK", "Oklahoma"],
    "41" => [ "OR", "Oregon"],
    "15" => [ "HI", "Hawaii"],
    "42" => [ "PA", "Pennsylvania"],
    "16" => [ "ID", "Idaho"],
    "44" => [ "RI", "Rhode Island"],
    "17" => [ "IL", "Illinois"],
    "45" => [ "SC", "South Carolina"],
    "18" => [ "IN", "Indiana"],
    "46" => [ "SD", "South Dakota"],
    "19" => [ "IA", "Iowa"],
    "47" => [ "TN", "Tennessee"],
    "20" => [ "KS", "Kansas"],
    "48" => [ "TX", "Texas"],
    "21" => [ "KY", "Kentucky"],
    "49" => [ "UT", "Utah"],
    "22" => [ "LA", "Louisiana"],
    "50" => [ "VT", "Vermont"],
    "23" => [ "ME", "Maine"],
    "51" => [ "VA", "Virginia"],
    "24" => [ "MD", "Maryland"],
    "53" => [ "WA", "Washington"],
    "25" => [ "MA", "Massachusetts"],
    "54" => [ "WV", "West Virginia"],
    "26" => [ "MI", "Michigan"],
    "55" => [ "WI", "Wisconsin"],
    "27" => [ "MN", "Minnesota"],
    "56" => [ "WY", "Wyoming"],
    "28" => [ "MS", "Mississippi"],
    "60" => [ "AS", "American Samoa"],
    "64" => [ "FM", "Federated States of Micronesia"],
    "66" => [ "GU", "Guam"],
    "68" => [ "MH", "Marshall Islands"],
    "69" => [ "MP", "Northern Mariana Islands"],
    "70" => [ "PW", "Palau"],
    "72" => [ "PR", "Puerto Rico"],
    "74" => [ "UM", "U.S. Minor Outlying Islands"],
    "78" => [ "VI", "Virgin Islands of the U.S."],
  }

end