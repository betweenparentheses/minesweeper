require 'minesweeper'
require 'pry'

describe Game do 
  it 'should have a Player' do
    expect(subject.player).to be_a Player
  end

  it 'should have a Board' do
    expect(subject.board).to be_a Board
  end

  describe '#play' do
    it 'should call player#take_turn' do
      #necessary to avoid infinite loop
      allow(subject.board).to receive(:victory?).and_return(true)
      allow(subject.player).to receive(:take_turn)

      expect(subject.player).to receive(:take_turn)
      subject.play
    end
    it 'should call board#render' do
      #avoid infinite loop
      allow(subject.board).to receive(:victory?).and_return(true)
      allow(subject.player).to receive(:take_turn)

      expect(subject.board).to receive(:render).at_least(1).times
      subject.play
    end
  end
end

describe Player do

  #left as an exercise for the student

end

describe Board do

  describe "#initialize" do

    context 'with default options' do
      it "should create a 10x10 array by default" do
        expect(subject.size).to eq(10)
      end

      it "should have 9 mines by default" do
        expect(subject.mine_count).to eq(9)
      end

      it 'should count adjacent mines up-front' do
        expect( subject.grid.flatten.all? { |space| space.nearby_mines. is_a? Integer } ).to eq true
      end

    end


    it 'should be an array' do
      expect(subject.grid).to be_a Array
    end

    it 'should be an array of arrays' do
      expect(subject.grid[0]).to be_a Array
    end

    # careful, this test has false positive if size is 0 
    it 'should be composed of spaces' do
      expect(subject.grid.flatten.all? { |space| space.is_a? Space }).to eq true
    end

    it 'should have all Spaces be invisible at first' do
      expect(subject.grid.flatten.all? {|s| !s.visible } ).to eq true
    end

    it 'should always be square' do
      expect(subject.grid.size).to eq subject.grid[0].size
    end

    it 'can take a size up to 25' do
      expect{Board.new(25)}.not_to raise_error
    end

    it 'creates 9 mines for a 10x10' do
      expect(subject.mine_count).to eq 9
    end

    it 'creates 100 mines for a 25 x 25' do
      expect( Board.new(25).mine_count ).to eq 100
    end

    it 'raises an error if inputs are not positive integers' do
      expect{Board.new(-4)}.to raise_error
    end

    it 'raises an error if size are greater than 25' do
      expect{Board.new(26)}.to raise_error
    end

    it 'should start with as many flags remaining as mines' do
      expect(subject.flags_remaining).to eq(subject.mine_count)
    end

  end

  describe '#render' do

  end

  describe '#place_flag' do
    it 'should only be allowed if flags remain' do
      allow(subject).to receive(:flags_remaining).and_return(0)
      expect(subject.place_flag(0,0)).to eq(false)
    end
    it 'should only be valid on uncleared spaces' do
      subject[0][0].mine = false
      subject[0][0].visible = true

      expect(subject.place_flag(0,0)).to eq(false)
    end
    it 'should decrement the flag counter by 1 if successful' do
      flag_count = subject.flags_remaining
      subject.place_flag(0,0)
      expect(subject.flags_remaining).to eq (flag_count - 1)
    end
    it 'should change a space to appear flagged' do
      subject.place_flag(0,0)
      expect(subject[0][0].flagged).to eq true
    end
  end

  describe '#mark_clear' do

    it 'should change the space to visible' do
      subject.mark_clear(0,0)
      expect(subject[0][0].visible).to equal true
    end

    context 'if the space chosen is clear' do

      #set up safe and unsafe spots
      before(:each) do
        subject[0][0].mine = false
        subject[0][1].mine = false
        subject[1][0].mine = false
        subject[1][1].mine = true
      end

      it 'should not trigger a loss' do
        expect(subject.game_lost?).to equal(false)
      end
    end

    context 'if the space chosen has a mine' do
      before(:each) do
        subject[0][0].mine = true
      end

      it 'should trigger a loss' do
        subject.mark_clear(0,0)
        expect(subject.game_lost?).to equal true
      end
    end

    context 'if the space has zero mines nearby' do

      before(:each) do
        subject.grid.flatten.each {|s| s.mine = false }
        subject[3][3].nearby_mines = 0
      end


      # in a perfect world, we also want a test that checks
      # if it keeps going forever. since that's a lot to mock out
      # this test will stay around
      it 'should uncover all adjacent mines' do

        subject.mark_clear(3,3)

        # whoa! you can iterate expectations!
        # this way, the test fails if any one of these 
        # *NINE* expect clauses fail
        2.upto(4) do |x|
          2.upto(4) do |y|
            expect(subject[x][y].visible).to equal true
          end
        end

      end

    end
  end

  describe '#victory?' do
    it 'should be true when all non-mine spaces are visible' do
      subject.grid.flatten.map! {|s| s.visible = true unless s.mine }
      expect(subject.victory?).to equal true
    end

    it 'should be false otherwise' do
      expect(subject.victory?).to equal false
    end
  end

  describe '#game_lost?' do
    it 'should be true as soon as a mine is marked as clear' do
      subject[0][0].mine = true
      subject.mark_clear(0,0)
      expect(subject.game_lost?).to equal true
    end

    it 'should be false otherwise' do
      expect(subject.game_lost?).to equal false
    end
  end

  describe '#num_adjacent_mines' do
    let(:single_mine){ Board.new }

    before(:each) do
      # this test board has a single mine only at 0, 0
      single_mine.grid.flatten.each {|cell| cell.mine = false }
      single_mine.grid[0][0].mine = true
    end

    it 'returns 0 when there are no mines next to a square' do
      expect(single_mine.num_adjacent_mines(9,9)).to eq 0
    end

    it 'returns the number of mines next to a square' do
      expect(single_mine.num_adjacent_mines(1,1)).to eq 1
    end

  end

end

describe Space do

  describe '#initialize' do
    it 'should start invisible' do
      expect(subject.visible).to eq(false)
    end

    it 'should default to no mine' do
      expect(subject.mine).to eq(false)
    end

    it 'should default to not flagged' do
      expect(subject.flagged).to eq(false)
    end
  end
end