require 'pry'

class WordGame

  def self.word_game(word_value)
    dictionary = File.open("/usr/share/dict/words", "r").read.split("\n")
    if dictionary.include?(word_value)
      ["#{word_value} is a known word"]
    else
      ["#{word_value} is not a known word"]
    end
  end

end
