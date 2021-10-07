require './boid'

class Howk < Boid

  @size = 6
  # Ruby does not have class var inheritance (wtf) so there are all copy-pasted
  @sight = @size * 40
  @max_focus = 8

  @sep_power = 0.12 / @sight
  @ali_power = 0.1 / @sight
  @coh_power = 0.1 / @sight

  def initialize(game)
    super(game)
    @shape.color = 'yellow'
  end
end