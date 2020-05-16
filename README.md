# Description
extract sequences based on the results of OrthoFinder (orthogroup)

# Usage
rubygenerateAlnFromOrthoFinder.rb 


# Arguments:

--force	remove outdir if it exists, and create a new one

--suffix	extention of input sequences

--count_min_max_total	min and max no. of genes total (example: 90,100)

--count_min_max_per_taxon	min and max no. of genes per taxon (example: 0,1)

--include_list only consider the taxa on the list

--print_taxon	delete gene locus name


# Examples
ruby generateAlnFromOrthoFinder.rb --seq_indir pep --orthogroup Orthogroups.tsv --outdir out-pep --cpu 2 --force --suffix fas --count_min_max_total 10,10 --count_min_max_per_taxon 1,1 --include_list include.list --print_taxon 


Assuming that you have 10 genomes, --count_min_max_total 10,10 --count_min_max_per_taxon 1,1 will help you retrieve all strict single copy genes. "--count_min_max_total 9,10 --count_min_max_per_taxon 0,1" will retrieve all single copy genes absent in at most one genomes.
