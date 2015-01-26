Minesweeper TDD Solution
========================

If you got even most of this project done, you can consider yourself *far* beyond a beginner in Ruby. You're TDDing like the pros, and learning to decompose your methods. Most of all, what you should have learned from this is that smaller and more isolated methods are easier to test, and it's much easier to set up an example than to try to test by absolute logical necessity.

##Points of Interest

- the game loop itself is hard to test beyond expecting messages to be sent to certain objects
    + make sure to stub out victory conditions so your test doesn't get caught in an infinite loop
- the board is where the meat of the logic is, and that's where unit testing is most effective
- to test methods like counting adjacent mines, cheat
    + use a `before` clause to set mines exactly where you want them
    + then run your `#num_adjacent_mines` method
- testing automated mine clearing is hard. don't look for the perfect algorithm here
    + instead, see if a mine with zero others around it also clears off the 8 mines surrounding it
- remember that the `equal` method and the `eq` method in Rspec are not the same
    + if something `equal`s `true`, then it literally IS that object
    + if it `eq`s `true`, that's normal Ruby Boolean truthiness
    + `equal` is VERY useful to make sure boolean methods actually work!
-_Bonus:_ when working with 2D arrays, remember you can always use the `#flatten` method to get at the elements inside.
    - this comes in really handy when you want to compare two 2D arrays for equality or set all their elements equal
    - `@board.grid.flatten.each {|s| s.mine = false }` is a one-liner to remove every mine from the board, as another example


## A bonus

You can iteratively generate expectations, even stack them. It's not often the right way to go, but every once in a while it's perfect.

 See here:

```code-rspec

context 'if the space has zero mines nearby' do
# ...other stuff

    it 'should uncover all adjacent mines' do

      subject.mark_clear(3,3)

      # whoa! you can iterate expectations!
      # this way, the test fails if any one of these 
      # *NINE* expect clauses fail
      # which is to say, if any adjacent square remains hidden

      2.upto(4) do |x|
        2.upto(4) do |y|
          expect(subject[x][y].visible).to equal true
        end
      end

    end
end
```

*NOTE: This solution repo is copyrighted material for your private use only and not to be shared outside of Viking Code School.*