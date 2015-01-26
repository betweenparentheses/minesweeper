require 'minesweeper/version.rb'

class Board
  attr_reader :grid, :size
  attr_accessor :flags_remaining

  def initialize(size = 10)
    raise "size out of range!" unless size.between?(8, 25)
    @size = size
    @grid = Array.new(size){ Array.new(size){ Space.new } }

    place_mines
    count_nearby_mines

    #must be after mine placement
    @flags_remaining = mine_count
  end

  # this took lots of refactoring!!!
  def mine_count
    grid.flatten.count { |space| space.mine }
  end

  def render
    (self.size-1).downto(0) do |y|
      print "#{y}|"
      (0).upto(self.size-1) do |x|
        render_cell(x, y)
        print " "
      end
      puts "|\n"
    end

    print "  "
    print "--" * size
    puts "\n"
    print " "
    0.upto(self.size-1) {|x| print " #{x}"}
    puts "\n"
    puts "Flags remaining: #{flags_remaining}\n"
    nil
  end

  #show everything if you lose
  def endgame_render
    self.grid.flatten.each {|space| space.visible = true }
    render
  end

  # rather than just calling board.grid[row][col]
  # this passes the grid directly through
  # so you can call board[row][col]

  def [](index)
    self.grid[index]
  end



  def place_flag( x, y )
    return false if flags_remaining <= 0
    return false if self[x][y].visible

    self[x][y].flagged = true
    self.flags_remaining -= 1
    true
  end

  def mark_clear( x, y )
    return false if self[x][y].visible
    self[x][y].visible = true

    if self[x][y].zero_nearby?

      #mark all of them as well
      adjacent_spaces(x, y).each do |coords|
        adj_x, adj_y = coords[0], coords[1]
        mark_clear(adj_x, adj_y)
      end

    end

    true
  end

  # all non-mine spaces are visible
  def victory?
    self.grid.flatten.select {|space| !space.mine }.
                      all? {|space| space.visible }
  end


  def game_lost?
    touched_a_mine? 
  end

  def num_adjacent_mines(x, y)
    mine_count = 0

    adjacent_spaces(x, y).each do |coords|
      adj_x, adj_y = coords[0], coords[1]
      mine_count += 1 if self.grid[adj_x][adj_y].mine
    end

    mine_count
  end


  private

  def render_cell(x, y)
    cell = self.grid[x][y]

    if !cell.visible && cell.flagged
      print "F"
    elsif !cell.visible
      print "_"
    elsif cell.mine
      print "M"
    else
      print cell.nearby_mines
    end
  end


  # oops. you found a mine
  def touched_a_mine?
    self.grid.flatten.any?{ |cell| cell.visible && cell.mine }
  end
  

  # used to decide whether recursive clearing
  # is possible on a space (No mine, not visible yet)
  # AND has 0 nearby mines
  def can_clear? ( x, y )
    !self[x][y].visible && 
    !self[x][y].mine && 
    self[x][y].nearby_mines == 0
  end

  def count_nearby_mines
    0.upto(self.grid.size - 1) do |x|
      0.upto(self.grid.size - 1) do |y|
        self.grid[x][y].nearby_mines = num_adjacent_mines(x, y)
      end
    end
  end

  def adjacent_spaces(x,y)

    coords = []

    (x - 1).upto(x + 1) do |adj_x|
      (y - 1).upto(y + 1) do |adj_y|

        # don't count yourself
        next if ((x == adj_x) && (y == adj_y))

        #if coords are within the bounds of the grid
        if (adj_x >= 0 && adj_y >= 0) && (adj_x < self.size && adj_y < self.size)

          #add them to the list of adjacent coordinates
          coords.push([adj_x, adj_y])
        end
      end
    end

    coords
  end


  def place_mines

    mines_to_place = [ (self.size - 7)**2, 100].min

    while mines_to_place > 0
      x, y = rand(self.size), rand(self.size)

      unless self.grid[x][y].mine
        self.grid[x][y].mine = true
        mines_to_place -= 1
      end

    end

  end

  
end

class Space
  attr_accessor :visible, :flagged, :mine, :nearby_mines

  def initialize
    @visible = false
    @flagged = false
    @mine = false
    @nearby_mines = nil
  end

  def clear?
    visible && !mine
  end

  def zero_nearby?
    clear? && self.nearby_mines == 0
  end
end



class Player
  def initialize(board)
    @board = board
  end

  def take_turn

    until make_move do
      puts "That didn't work. Try again."
    end
  end

  private

  def make_move
    puts "Mark a square as (C)lear\n or (F)lag it as a mine?"
    print "> "
    choice = gets.chomp.upcase

    print "Choose coordinates in the form of x, y: "
    x, y = gets.chomp.split(',').map{|c| c.to_i }

    if choice == "F"
      @board.place_flag(x, y)
    else
      @board.mark_clear(x, y)
    end
  end

end


class Game

  attr_reader :player, :board

  def initialize
    @board = Board.new
    @player = Player.new(@board)
  end

  def play

    loop do
      board.render
      player.take_turn
      break if game_over?
    end

    endgame
  end

  private

  def game_over?
    board.victory? || board.game_lost?
  end

  def endgame
    board.endgame_render
    puts "Oh no! You touched a mine!" if board.game_lost?
    puts "Congratulations! You won!" if board.victory?
    puts "Thanks for playing!"
  end
end


