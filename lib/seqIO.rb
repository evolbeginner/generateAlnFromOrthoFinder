#! /usr/bin/env ruby


#######################################################################
DIR = File.dirname($0)


#######################################################################
$: << DIR


#######################################################################
def read_seq_from_dir(infiles, suffix, species_included, cpu, in2out={}, prot2taxon={})
  require 'bio'
  require 'util'

  infiles_good = getFilesGood(infiles, species_included, suffix)

  results = Parallel.map(infiles_good, in_processes: cpu) do |infile|
    h = Hash.new
    outName = nil
    in_fh = Bio::FlatFile.open(infile, 'r')
    if File.size(infile) == 0
      h = nil
      #STDERR.puts "#{infile} file size is ZERO! Exiting ......" or exit 1      
    else
      in_fh.each_entry do |f|
        seq_title = f.definition.split(' ')[0]
        if prot2taxon.empty?
          inName = seq_title.split('|')[0]
          outName = in2out.include?(inName) ? in2out[inName] : inName
        else
          inName = seq_title
          outName = getCorename(infile)
          #outName = prot2taxon.include?(inName) ? prot2taxon[inName] : inName
        end
        h[seq_title] = f
      end
    end
    [outName, h]
  end

  seq_objs = Hash.new
  results.each do |a|
    taxon, h = a
    next if taxon.nil?
    seq_objs[taxon] = h
  end
  return(seq_objs)
end


def getFilesGood(infiles, species_included, suffix)
  infiles_good = Array.new
  infile_basenames_included = species_included.keys.map{|i| [i,suffix].join('.')}
  infiles.each do |infile|
    if not suffix.nil?
      File.basename(infile) =~ /\.([^.]+)$/
      suffix0 = $1
      next if suffix != suffix0
    end
    b = File.basename(infile)
    if infile_basenames_included.empty?
      ;
    else
      next if not infile_basenames_included.include?(b)
    end
    infiles_good << infile
  end
  return(infiles_good)
end


def getProt2Taxon(infiles, cpu)
  require 'bio'
  require 'util'
  require 'SSW_bio'

  prot2taxon = Hash.new
  results = Parallel.map(infiles, in_processes: cpu) do |infile|
    h = Hash.new
    c = getCorename(infile)
    seqObjs = read_seq_file(infile)
    seqObjs.each_pair do |title0, seqObj|
      title = title0.split(' ')[0]
      h[title] = c
    end
    h
  end

  results.each do |h|
    prot2taxon.merge!(h)
  end

  return(prot2taxon)
end


