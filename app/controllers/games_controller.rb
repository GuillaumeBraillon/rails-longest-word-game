require "open-uri"
require "json"

class GamesController < ApplicationController
  VOWELS = %w[A E I O U]
  CONSONANTS = ("A".."Z").to_a.reject { |letter| VOWELS.include?(letter) }
  def new
    @letters = generate_grid(10)
    session[:total_score] ||= 0
  end

def score
    @grid = params[:grid].split(" ")
    @word = params[:word]
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now

    unless word_in_grid()
      @result = { score: 0, time: 0, status: :not_in_grid }
      return
    end

    word_data = get_word()
    unless word_data["found"]
      @result = { score: 0, time: 0, status: :not_english }
      return
    end

    elapsed_time = (@end_time - @start_time).to_i
    calculated_score = get_score
    session[:total_score] = session[:total_score].to_i + calculated_score

    @result = {
      score: calculated_score,
      time: elapsed_time,
      status: :success
    }
end

  private

  def generate_grid(grid_size)
    num_voyelles = (grid_size / 3.0).round
    num_consonnes = grid_size - num_voyelles
    grid = num_voyelles.times.map { VOWELS.sample }.concat(num_consonnes.times.map { CONSONANTS.sample })
    grid.shuffle
  end

# Récupere le mot passé en parametre dans le dictionnaire du Wagon
def get_word
  url = "https://dictionary.lewagon.com/#{@word}"
  JSON.parse(URI.parse(url).read)
end

# Vérifier que le mot peut être formé à partir de la grille,
# chaque lettre dans le mot ne dépasse pas celle dans la grille
def word_in_grid
  gridCopy = @grid.dup
  @word.chars.all? do |letter|
    index = gridCopy.index(letter.upcase)
    index ? gridCopy.delete_at(index) : false
  end
end


# permet de donner un score en fonction de la longeur du mot
def get_score
  elapsed_time = @end_time - @start_time
  (@word.size * 10 / [ elapsed_time, 0.1 ].max).to_i
end
end
