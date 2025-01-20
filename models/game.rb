class Game < ActiveRecord::Base
  belongs_to :word
  serialize :guesses

  def check_guess(guess)
    target = word.text
    result = Array.new(5)

    # Mark exact matches
    guess.chars.each_with_index do |char, i|
      if char == target[i]
        result[i] = :correct
      end
    end

    # Mark partial matches
    guess.chars.each_with_index do |char, i|
      next if result[i] == :correct

      if target.include?(char)
        result[i] = :partial
      else
        result[i] = :incorrect
      end
    end

    result
  end
end
