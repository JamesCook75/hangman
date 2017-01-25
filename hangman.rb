require 'pstore'

class Game
  attr_accessor :word, :incorrect_guesses_left, :puzzle, :choice, :history
  def initialize (word = "", incorrect_guesses_left = 6, puzzle = [], choice = "", history = [])
    @word = word
    @incorrect_guesses_left = incorrect_guesses_left
    @puzzle = puzzle
    @choice = choice
    @history = history
  end

  def save_game
    store = PStore.new("storagefile")
    store.transaction do
      store[:games] = Array.new
      store[:games] << self
    end
    $game_over = 1
    puts "Game Saved"
  end

  def setup_puzzle
    puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
    i=0
    dictionary = File.readlines("5desk.txt")
    list = dictionary.select {|word| (word.chop.size > 4 && word.chop.size < 13)}
    @word = list[rand(0..list.size)].chop.downcase
    puts @word
    @word.size.times do
      @puzzle[i] = "_"
      i += 1
    end
  end

  def player_turn
    print "Choose a letter >>"
    @choice = gets.chop
    puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
    self.save_game if @choice == "S"
  end

  def get_result
    j = 0
    correct = 0
    @word.size.times do
      if @choice == @word[j]
        @puzzle[j] = @choice
        correct += 1
      end
      j += 1
    end
    if @word == @puzzle.join
      $game_over =1
      puts "\n\n\nYou Win!\n\n"
    end
    if correct == 0
      puts "\n\n\n\n\n\n\n\n\n\nThere are no #{@choice}'s in the puzzle\n\n"
      @incorrect_guesses_left -= 1
      @history.push(@choice)
      if @incorrect_guesses_left == 0
        $game_over = 1
        puts "\n\n\n\nYou Lose, the word was #{@word}\n\n"
      end
    end
  end

  def show_board
    puts "\n\n\n\n\n"
    puts "           #{@puzzle.join(" ")}   "
    puts "\n\n"
    puts "#{@incorrect_guesses_left} incorrect guesses left \n\n"
    puts "Incorrect letters chosen: #{@history.join(", ")} \n\n\n" if @history != nil
  end
end

def load_game
  store = PStore.new("storagefile")
  games = []
  store.transaction do
    games = store[:games]
  end
  puts games.inspect
  @new_game = games.last
  puts
end

$game_over = 0

puts "Start a new game (1) or Load an old game (2) ?"
pick = gets.chomp.to_i

if pick == 1
my_game = Game.new
my_game.setup_puzzle
else
  load_game
  my_game = Game.new(@new_game.word, @new_game.incorrect_guesses_left, @new_game.puzzle, @new_game.choice, @new_game.history)
end

while $game_over == 0
  my_game.show_board
  my_game.player_turn
  my_game.get_result
end
my_game.show_board
