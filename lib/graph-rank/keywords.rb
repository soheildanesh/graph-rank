# Implement the PageRank algorithm
# for unsupervised keyword extraction.

#HOW TO RUN
#if you wanna update and reload the files inside graph-rank folder you can go to graph-rank folder then do 
#load '../graph-rank.rb' #load from the parent dir
#for some reason have to do a load './keywords.rb' for my changes in the file to take effect
#now you can do
#tr = GraphRank::Keywords.new
#tr.run(someInputText).inspect e.g. :
# text = String.new(tr.hulth1939)
#tr.run(text).inspect
# and if you make changes the load './whateverfileInGraph-rankFoler.rb'

require 'engtagger'

class GraphRank::Keywords < GraphRank::TextRank
    
  attr_accessor :hulth1939, :stop_words, :text

  
  def initialize()
      #text of abstract 1939 in test set of hulth dataset used as example in textrank paper
      @hulth1939 = "Compatibility of systems of linear constraints over the set of natural numbers Criteria of compatibility of a system of linear Diophantine equations, strict inequations, and nonstrict inequations are considered. Upper bounds for components of a minimal set of solutions and algorithms of construction of minimal generating sets of solutions for all types of systems are given. These criteria and the corresponding algorithms for constructing a minimal supporting set of solutions can be used in solving all the considered types of systems and systems of mixed types"
      
      super()
      
  end
  
    # combines adjacent high ranking words into multi words
    #input: takes the output of the textrank.run function
    def combineAdjacent wordRankings
        
        #TAKE TOP 1/T words
        wordRankings = wordRankings.slice(0..wordRankings.size/2)
        #TAKE TOP 1/T words
        
        wordRankings = wordRankings.to_h
        
        puts("top words = #{wordRankings}")
        combinedCandidates = Hash.new
        candidate = ""
        weight = 0
        
        text = @text.gsub(/[^a-z ]/, ' * ')
        for word in text.split " "
            if wordRankings.has_key? word
                candidate = candidate + " " + word
                weight = weight + wordRankings[word]
            else
                if weight != 0 and candidate != ""
                    candidate = candidate.strip
                    combinedCandidates[candidate] = weight
                end
                candidate = ""
                weight = 0
            end
        end
        
        comCandsPuncsElimed = Hash.new
        ## ELIMINATE CANDIDATES WITH PUNCS IN MIDDLE ##
        combinedCandidates.each do |cand, weight|
            if @text.include? cand
                comCandsPuncsElimed[cand] = weight
            else
                puts "eliminating #{cand} as it has non char in middle"
            end
        end
         
        ## ELIMINATE CANDIDATES WITH PUNCS IN MIDDLE ##
        
        
        ## ELIMINATE  PUNCTUATIONS FROM CANDIDATES ##
        if false
            combinedCandidates.each do |cand, weight|
                #replace all non letter chars with start
                cand = cand.gsub(/[^a-z ]/, '*')
            
                #cands = cand.split('*')
                #for cand in cands 
                #    comCandsPuncsElimed[cand] = weight
                #end


                if false and cand.include? '*'
                
                    # TAKE CARE OF PUNCS NOT IN MIDDLE #
                    if(cand[0] == '*')
                        cand[0] = ''
                    end
                    if(cand[cand.size-1] == '*')
                        cand[cand.size-1] = ''
                    end
                    # TAKE CARE OF PUNCS NOT IN MIDDLE #
                
                    if cand.include? '*'
                        #skip inclusion in final candidate list
                    else
                        #this is case where puncs were not in middle
                        comCandsPuncsElimed[cand] = weight
                    end
                else
                   comCandsPuncsElimed[cand] = weight 
                end
            end
        end
        
        ## ELIMINATE  PUNCTUATIONS FROM CANDIDATES ##

        return comCandsPuncsElimed.sort_by {|k,v|v}.reverse
    end
    
    def post_process ranking
        combineAdjacent ranking
    end
      

  # Split the text on words.
  def get_features
    puts("before clean text = #{@text}")  
    text = clean_text @text
    puts("after clean text = #{@text}")  
    @features = text.split(' ')
    puts "unfiltered @features = #{@features} "
  end

  # Remove short and stop words.
  def filter_features
    
    ### POS TAG FILTER ###
    @tgr = EngTagger.new
    tagged = @tgr.add_tags(@text)
    nouns = @tgr.get_nouns(tagged)
    adjs = @tgr.get_adjectives(tagged)      
    nounsnadjs = nouns.merge(adjs)
    puts("nounsnadjs = #{nounsnadjs}")
    @features.delete_if { |word| not nounsnadjs.has_key?(word) }
    ### POS TAG FILTER ###    
    
    #remove_short_words
    #remove_stop_words
  end

  # Clean text leaving just letters from a-z.
  def clean_text text
    text = String.new(text)
    text = text.downcase
    text.gsub!(/[^a-z ]/, ' ')
    text.gsub!(/\s+/, " ")
  end

  # Remove all stop words.
  def remove_stop_words
    @features.delete_if { |word| @stop_words.include?(word) }
  end

  # Remove 1 and 2 char words.
  def remove_short_words
    @features.delete_if { |word| word.length < 3 }
  end

  # Build the co-occurence graph for an n-gram.
  def build_graph
    puts("features = #{@features}")  
    @features.each_with_index do |f,i|
      min, max = i - @ngram_size, i + @ngram_size
      puts("min = #{min}, max = #{max}")
      while min <= max
        puts "@features[min] = #{@features[min]} and min = #{min} and i = #{i}"  
        if @features[min] and min != i and min > 0
          @ranking.add(@features[i], @features[min])
          puts("min = #{min} - i = #{i}")
          puts("connecting #{@features[i]} - #{@features[min]}")
        end
        min += 1
      end
    end
  end

end