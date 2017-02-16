require 'pry'

class GuessingGame
  attr_accessor :secret_number, :game_status
  def initialize
    @guess_count = 0
    @guess_hash = {}
    @secret_number = rand(100)
    @game_status = false
  end

  def determine_verb(verb, guess)
    if verb == "GET"
      gets_guesses
    else
      @guess_count += 1
      @guess_hash[@guess_count.to_s] = [guess, makes_guess(guess.to_i)]
      ["Your guess was #{makes_guess(guess.to_i)}", gets_guesses]
    end
  end

  def gets_guesses
    output_array = @guess_hash.map do |counter, hash_array|
      "Guess ##{counter} was #{hash_array[0]}, and it was #{hash_array[1]}" #too low. too high. correct!
    end
    output_array.empty? ? [statement_counter] : output_array.unshift(statement_counter)
  end

  def statement_counter
    if @guess_count == 0
      statement = "No guesses have been made yet!"
    elsif @guess_count == 1
      statement = "1 guess has been made."
    else
      statement = "#{@guess_count} guesses have been made."
    end
  end

  def makes_guess(guess)
    if guess == secret_number
      value = "correct!"
    elsif guess < secret_number
      value = "too low."
    else
      value = "too high."
    end
  end

end
