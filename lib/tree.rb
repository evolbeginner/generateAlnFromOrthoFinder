require 'bio'


class Bio::Tree
  DELIMITER = ';'
  attr_accessor :tip2index, :index2tip

  def tips(node)
    rv = Array.new
    if node.isTip?(self)
      rv = [node]
    else
      rv = descendents(node).select{|n|children(n).empty?}
    end
    return(rv)
  end

  def cleanName!
    allTips.each do |tip|
      tip.name.gsub!(' ', '_')
    end
  end

  def twoTaxaNode(node)
    if node.isTip?(self)
      return(node)
    else
      return children(node).map{|child|tips(child).sort_by{|i|i.name}.shift}.sort_by{|i|i.name}
    end
  end
  
  def twoTaxaNodeName(node)
    if node.isTip?(self)
      return(node.name)
    else
      return children(node).map{|child|tips(child).sort_by{|i|i.name}.shift}.sort_by{|i|i.name}.map{|i|i.name}
    end
  end

  def sisters(node)
    if node == root
      return([])
    else
      return(children(parent(node)).select{|i|i!=node})
    end
  end

  def sister(node)
    return(sisters(node)[0])
  end

  def internal_nodes
    a = Array.new
    nodes.each do |node|
      if not node.isTip?(self)
        a << node
      end
    end
    return(a)
  end

  def allSubtreeRepresentatives
    arr = Array.new
    nodes.each do |node|
      arr << tips(node)
    end
    return(arr)
  end

  def allTips
    a = Array.new
    nodes.each do |node|
      a << node if node.isTip?(self)
    end
    return(a)
  end

  def outputNexus(isTranslate=false, isTip2Index=false)
    puts "#NEXUS"
    puts
    puts "BEGIN TREES;"
    translate if isTranslate
    tipToIndex and newickTipToIndex if isTip2Index
    puts ["\t"+'TREE TREE1', cleanNewick()].join('= ')
    puts ['ENDBLOCK', DELIMITER].join('')
    newickIndexToTip if isTip2Index
  end

  def cleanNewick
    output = output_newick
    output.gsub!(/[\n\s]/, '')
    output.gsub!(/[']/, '')
    return(output)
  end

  def tipToIndex
    @tip2index = Hash.new
    @index2tip = Hash.new
    allTips.each_with_index do |tip, index|
      @tip2index[tip.name.gsub(' ','_')] = (index+1).to_s
      @index2tip[(index+1).to_s] = tip.name
    end
  end

  def newickTipToIndex()
    tipToIndex
    allTips.each do |tip|
      index = @tip2index[tip.name.gsub(' ', '_')]
      tip.name = (index).to_s
    end
  end

  def newickIndexToTip()
    tipToIndex if @index2tip.empty?
    allTips.each do |tip|
      index = tip.name
      tip.name = @index2tip[index]
    end
  end

  def getAlldistances()
    distances = Array.new
    each_edge do |node0, node1, edge|
      next if node0 == root or node1 == root
      distances << edge.distance
    end
    return(distances)
  end

  def normalizeBranchLength!()
    min, max = getAlldistances().minmax
    each_edge do |node0, node1, edge|
      edge.distance = (edge.distance-min+1e-10).to_f/(max-min)
    end
  end

  def normalizeBranchLengthGainAndLoss!()
    min, max = getAlldistances().select{|i|i>=0}.minmax
    each_edge do |node0, node1, edge|
      edge.distance = (edge.distance-min+1e-10).to_f/(max-min) + 1 if edge.distance >= 0
    end

    min, max = getAlldistances().select{|i|i<0}.minmax
    each_edge do |node0, node1, edge|
      edge.distance = (edge.distance-min+1e-10).to_f/(max-min) if edge.distance < 0
    end
  end

  private
  def translate
    #  TRANSLATE
    #    1	Hamster,
    puts "\tTRANSLATE"
    allTips.each_with_index do |tip, index|
      puts ["\t\t"+(index+1).to_s, tip.name.gsub(' ','_')+','].join("\t")
    end
    puts ["\t\t"+DELIMITER].join("\t")
  end
end


############################################################################
class Bio::Tree::Node
  def isTip?(tree)
    rv = tree.children(self).empty? ? true : false     
    return(rv)
  end
end


############################################################################
def getTreeObjs(tree_file, num=1000000)
  trees = Array.new
  treeio = Bio::FlatFile.open(Bio::Newick, tree_file=='-' ? $stdin : tree_file)
  while newick = treeio.next_entry
    tree = newick.tree
    tree.options[:bootstrap_style] = :traditional
    next if tree.nodes.empty?
    trees << tree
    break if trees.size >= num
  end
  return(trees)
end


def getTreeObjFromNwkString(nwk_str)
  nwk = Bio::Newick.new(nwk_str)
  tree = nwk.tree
  return(tree)
end


