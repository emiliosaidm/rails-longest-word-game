require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @sample = letters_array
  end

  def score
    @score = score_validator(params[:answer], params[:sample])
  end

  def letters_array
    alphabet = ('A'..'Z').to_a * 3
    alphabet.sample(10)
  end

  def score_validator(result, sample)
    score_validator = { overused: false, includes: false, valid: false }
    grid_sample = sample.downcase
    result = result.downcase
    grid_chars = Hash.new(0)
    sample_chars = Hash.new(0)
    grid_sample.each_char { |char| grid_chars[char] += 1 }
    result.each_char { |char| sample_chars[char] += 1 }
    grid_chars.each do |key, value|
      if sample_chars[key] > value
        score_validator[:overused] = true
      elsif sample_chars[key] <= value && sample_chars[key] > 0
        score_validator[:includes] = true
      end
    end
    score_validator[:valid] = true if valid?(result)
    message(score_validator)
  end

  def valid?(word)
    dictionary = "https://wagon-dictionary.herokuapp.com/#{word}"
    validation = JSON.parse(URI.open(dictionary).read)
    return validation["found"]
  end

  def message(hash)
    if hash[:overused] && hash[:includes] && hash[:valid]
      return "The word is valid but overused!"
    elsif (hash[:overused] == false) && hash[:includes] && (hash[:valid] == false)
      return "The word is not valid in the english language"
    elsif hash[:includes] && hash[:valid] && (hash[:overused] == false)
      return 'Great!'
    elsif hash[:valid] == false
      return "Not a valid word!"
    else
      return "Not a word within the grid"
    end
  end
end
