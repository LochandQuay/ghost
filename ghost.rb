class Game
  attr_accessor :current_player, :previous_player, :losses

  def initialize(player_one, player_two, dictionary)
    @player_one = player_one
    @player_two = player_two
    @dictionary = dictionary_setup(dictionary)
    @losses = {player_one.name => 0, player_two.name => 0}
  end

  def dictionary_setup(dictionary)
    hash = Hash.new
    File.readlines(dictionary).map(&:chomp).each do |word|
      hash[word] = word
    end
    hash
  end

  def play_round
    game_setup
    until game_lost?
      take_turn(@current_player)
      break if game_lost?
      next_player!
    end

    @losses[@current_player.name] += 1
    puts "#{@current_player.name} loses with #{@fragment}!"
  end

  def game_setup
    @current_player = @player_one
    @previous_player = @player_two
    @fragment = ""
  end

  def next_player!
    @current_player, @previous_player = @previous_player, @current_player
  end

  def take_turn(player)
    guess = player.guess
    until valid_play?(guess)
      player.alert_invalid_guess
      guess = player.guess
    end
    @fragment << guess
  end

  def valid_play?(string)
    @dictionary.any? { |key, value| key.start_with?(@fragment + string) }
  end

  def game_lost?
    @dictionary.key?(@fragment)
  end

  def record(player)
    "GHOST"[0, losses[player.name]]
  end

  def run
    until losses.values.any? { |value| value == 5 }
      display_standings
      play_round
    end

    puts "#{declare_loser} spelled GHOST"
  end

  def display_standings
    @losses.each do |name, losses|
      puts "#{name}: " + "GHOST"[0, losses]
    end
  end

  def declare_loser
    @losses.select { |name, losses| losses == 5 }.keys.first
  end

end



class Player
  ALPHABET = ("a".."z").to_a
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def guess
    print "#{@name}, guess a letter: "
    guess = gets.chomp
    until valid_guess?(guess)
      puts "Invalid guess! Please guess again."
      guess = gets.chomp
    end
    guess
  end

  def valid_guess?(string)
    ALPHABET.include?(string)
  end

  def alert_invalid_guess
    puts "That won't create a valid word, silly!"
  end


end

if __FILE__ == $PROGRAM_NAME
  Game.new(Player.new("Hope"), Player.new("John"), 'dictionary.txt').run
end
