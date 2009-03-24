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

require 'pp'
require "FIPS"

class CandidateFinancialSummary
  attr_reader :chamber, :candidateId, :candidateName, :status, :party, :partyDesig, :totalReceipts, :authorizedTransfers, :totalDisbursements, :transfersToAuthorized, :beginningCash, :endingCash, :contribFromCandidate, :loansFromCandidate, :otherLoans, :candidateLoanRepayments, :otherLoanRepayments, :debtsOwedBy, :totalIndividualContributions, :stateCode, :district, :specialElectionStatus, :primaryElectionStatus, :runoffElectionStatus, :generalElectionStatus, :generalElectionPercentage, :contribFromOtherPoliticalCommittees, :contribFromPartyCommittees, :endingDate, :refundsToIndividuals, :refundsToCommittees
    
  def initialize()
    #do nothing for the moment
  end

  def initialize(line)
    parseLine(line)
  end
  
  def to_s
    puts "CandidateID: #{candidateId}\n Name: #{candidateName}\n Status: #{status}\n Party #{party}\n Party Desig: #{partyDesig}\n Total Receipts: #{totalReceipts}\n"  
  end
  
  def stateDistrict
    "#{@stateCode}#{@district}"
  end
  
  def gisStateDistrict
    "#{FIPS::StateAbbrFIPS[@stateCode][0]}#{@district}"
  end
  
  def parseLine(line)
    
    if line.strip != ""

      @chamber = line[0,1]
      @candidateId = line[0..8]
      @candidateName = line[9..46]
      
      # I = incumbent, C = challenger, O = open seat
      @status = line[47,1]
      
      # 1 = Dem, 2 = Rep, 3 = Other
      @party = line[48,1]
      
      #AIP=American Independent Party, AMP=American Party, CIT=Citizens Party, COM=Communist Party, CRV=Conservative Party, CST=Constitutional Party
      #DEM=Democratic Party, DFL=Democratic Farm Labor Party, IND=Independent, LBL=Liberal Party, LBU=Liberty Union Party, LIB=Libertarian Party
      #NAP=Prohibition Party, NLP=Natural Law Party, PAF=Peace and Freedom Party, REF=Reform Party, RTL=Right to Life, SLP=Socialist Labor Party
      #SUS=Socialist Party U.S.A., SWP=Socialist Workers Party, UNK=Unknown
      @partyDesig = line[49..51]
  
      @totalReceipts = line[52..61].to_i
      @authorizedTransfers = line[62..71].to_i
      @totalDisbursements = line[72..81].to_i
      @transfersToAuthorized = line[82..91].to_i
      @beginningCash = line[92..101].to_i
      @endingCash = line[102..111].to_i
      @contribFromCandidate = line[112..121].to_i
      @loansFromCandidate = line[122..131].to_i
      @otherLoans = line[132..141].to_i
      @candidateLoanRepayments = line[142..151].to_i
      @otherLoanRepayments = line[152..161].to_i
      @debtsOwedBy = line[162..171].to_i
      @totalIndividualContributions = line[172..181].to_i
      
      @stateCode = line[182..183]
      @district  = line[184..185].to_i.to_s.rjust(2,"0")
      
      #Blank = not special, W = won, L = lost, R = runoff
      @specialElectionStatus = line[186,1]
      #Blank = not special, W = won, L = lost, R = runoff
      @primaryElectionStatus = line[187,1]
      #Blank = not special, W = won, L = lost
      @runoffElectionStatus = line[188,1]
      #Blank = , W = won, L = lost
      @generalElectionStatus = line[189,1]
      @generalElectionPercentage = line[190..192].to_i
      
      @contribFromOtherPoliticalCommittees = line[193..202].to_i
      @contribFromPartyCommittees = line[203..212].to_i
      
      if (line[213..220].strip != "")
        begin
          @endingDate = Time.gm( line[217..220].to_i, line[213..214].to_i, line[215..216].to_i )
        rescue
          @endingDate = nil
          puts "Year: #{line[217..220].to_i}, Month: #{line[213..214].to_i}, Day: #{line[215..216].to_i} is not valid."
        end
      end
      
      @refundsToIndividuals = line[221..230].to_i
      @refundsToCommittees = line[231..240].to_i
      
    end
      
  end
  
end

class FECSummaryData
  attr_reader :cfss, :by_state, :by_stateDistrict, :by_gisStateDistrict

  def initialize()
    @cfss = Hash.new()
    @by_state = Hash.new()
    @by_stateDistrict = Hash.new()
    @by_gisStateDistrict = Hash.new()
  end

  def addCFS(cfs)
    
    @cfss[cfs.candidateId] = cfs
    
    if (@by_state[cfs.stateCode] == nil)
      @by_state[cfs.stateCode] = Hash.new()
    end
    @by_state[cfs.stateCode][cfs.candidateId] = cfs
    
    if (@by_stateDistrict[cfs.stateDistrict] == nil)
      @by_stateDistrict[cfs.stateDistrict] = Hash.new()
    end
    @by_stateDistrict[cfs.stateDistrict][cfs.candidateId] = cfs

    if (@by_gisStateDistrict[cfs.gisStateDistrict] == nil)
      @by_gisStateDistrict[cfs.gisStateDistrict] = Hash.new()
    end
    @by_gisStateDistrict[cfs.gisStateDistrict][cfs.candidateId] = cfs

  end
  
  def getTotalByHouseDistrict(variableName)
    
    totals = Hash.new()
    
    @by_gisStateDistrict.each {|stateDistrictKey, stateDistrictObject| 
      
      total = nil
      
      stateDistrictObject.each {|cfsKey, cfsObject|
        
        if (cfsObject.chamber == "H")
          if (total == nil)
            total = eval("cfsObject.#{variableName}")
          else
            total = total + eval("cfsObject.#{variableName}")
          end
        end
        
        }
      
      if (total != nil)
        totals[stateDistrictKey] = total
      end
      
      }
      
    return totals
    
  end
  
end

def loadFECData(filename)
  
  puts "Loading CandidateFinancialSummary objects"
  
  fecs = FECSummaryData.new()
  lineCounter = 1;
  
  File.open(filename, "r") do |file|
 
    while line = file.gets
      
      #puts "Line: #{lineCounter}"
      
      tempCFS = CandidateFinancialSummary.new(line)
      fecs.addCFS(tempCFS)
      
      lineCounter = lineCounter + 1
      
    end
    
  end
  
  puts "Done loading CandidateFinancialSummary objects. #{fecs.cfss.length} CandidateFinancialSummary added."
  
  return fecs
  
end

def fillCongressionalDistrictsWithData(cds, data)
  
  puts "Loading FEC data into CongressionalDistricts"
    
  loadedCDs = 0
  missingCDs = 0
  maxData = 0
  
  cds.each {|key, object|
    
    #Base case
    tempData = data[object.complete_id]    
    
    #Special case of one district states, FEC file is a bit confusing on the matter
    if (object.lsad == "C1")
      if (tempData == nil)
        tempData = data[object.state + "01"]
      elsif (data[object.state + "01"] != nil)
        tempData = tempData + data[object.state + "01"]
      end
    end
    
    if ( tempData != nil )
      object.data = tempData
      loadedCDs = loadedCDs + 1
      if tempData > maxData
        maxData = tempData
      end
    else
      missingCDs = missingCDs + 1
      puts " *** Missing data for #{object.complete_id}"
    end
    }
    
  puts "Done Loading FEC data into CongressionalDistricts. #{loadedCDs} CongressionalDistricts loaded. #{missingCDs} CongressionalDistricts missing."
  
  return maxData
    
end

def loadFECDataTest()
  baseDir = "/Users/aidan/Desktop/"
  projectDir = "Congressional Districts/"
  mapDataDir = "Map Data/"
  dataFile = "WEBL04.DAT"

  fecs = loadFECData( baseDir + projectDir + mapDataDir + dataFile )
  pp fecs.getTotalByHouseDistrict( "totalReceipts" ).sort
end


