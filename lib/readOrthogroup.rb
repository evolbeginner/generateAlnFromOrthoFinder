#! /usr/bin/env ruby


##################################################################
def readOrthogroupFile(orthogroupFile)
  allSpeciesHash = Hash.new
  orthogroup_info = Hash.new{|h,k|h[k]={}}

  in_fh = File.open(orthogroupFile, 'r')
  in_fh.each_line do |line|
    line.chomp!
    line_arr = line.split("\t")
    if $. == 1
      line_arr.each_with_index do |ele, index|
        allSpeciesHash[index] = ele if index != 0
      end
    else
      orthogroup = line_arr[0]
      line_arr.each_with_index do |genes_str, index|
        next if index == 0
        species = allSpeciesHash[index]
        orthogroup_info[orthogroup][species] = genes_str.split(', ').map{|i|i.split(' ')[0]}
      end
    end    
  end
  in_fh.close

  return(orthogroup_info)
end


