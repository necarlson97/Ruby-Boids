require 'ruby2d'
require './boid'
require './boid_map'
require './howk'

class Flock
  attr_reader :boids
  @@n = 100

  def initialize(game)
    # Create n boids
    @boids = []
    (1..@@n).each { |x| @boids += [Boid.new(game)] }
    @boids += [Howk.new(game)]
  end
end

class Game
  attr_reader :window
  attr_reader :flock
  attr_reader :debug
  attr_reader :boid_map

  def initialize
    @window = Window

    # Setup window attributes
    if ARGV.first
      @window.set fullscreen: true
      @window.set width: 1600
      @window.set height: 900
    else
      @window.set width: 1200
      @window.set height: 675
      @window.set resizable: true
    end
    

    @debug = false

    # TODO figure out how to best control boids
    # are the children of boid_map? As part of flock?
    @flock = Flock.new(self)
    @boid_map = BoidMap.new(self)
    
    # Define keypresses, print if we have nothing for that keypress
    @window.on :key_down do |event|
      if ['q', 'escape'].include? event.key  # Quit
        exit
      elsif event.key == 's'
        @flock.boids[0].dp.x = 0
        @flock.boids[0].dp.y = 0
      elsif event.key == 'f' # Toggle fullscreen
        # TOOD can't find a way to do it, doesn't auto-refresh,
        # can't do it manually, can't multithread, can't even kill and restart
      elsif event.key == '1' # Toggle debug mode
        @debug = (not @debug)
      else
          puts event
      end
    end

    @fps_text = Text.new(
      'text',
      x: 0, y: 880,
      size: 20,
      color: 'orange',
      z: 1
    )

    @window.update do
      handle_boids
      handle_debug
    end

    @window.show
  end

  def handle_boids
    boid_map.update
    for b in @flock.boids
      b.update
    end
  end

  def handle_debug
    # TODO framerate debug
    if @debug
      @fps_text.text = "#{@window.fps.to_i}"
      mx, my = @window.mouse_x, @window.mouse_y
      @flock.boids[0].p.set(mx, my)
    else
      @fps_text.text = ""
    end
  end
end


def main
    Game.new
end

main
