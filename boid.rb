require './point'

class Boid
  # boid instance vars
  attr_reader :dp
  attr_reader :p
  attr_accessor :bucket

  class << self
    # Boid class vars
    attr_reader :size
    attr_reader :sight
    attr_reader :max_focus

    attr_reader :sep_power
    attr_reader :ali_power
    attr_reader :coh_power
  end

  @size = 3 # For now, dist of line
  @sight = @size * 40 # How far can this boid see
  @max_focus = 8 # How many boids can be focused on at once (optimization step)

  # How powerfully they want to seperate, align, and cohease
  @sep_power = 0.12 / @sight
  @ali_power = 0.1 / @sight
  @coh_power = 0.1 / @sight

  def sc
    # Gross, but using 'self.class' every time I want a class
    # variable is also gross
    return self.class
  end

  def initialize(game)
    @game = game
    @window = game.window
    # Maybe want something prettier, but for now do a line
    
    @shape = Line.new(
      width: sc.size / 2,
      color: 'white'
    )
    # Coordinate point, x, y of 'root'
    @p = Point.new(rand(@window.width), rand(@window.height))
    # dx and dy, the position change per update loop
    @dp = Point.new(rand(sc.size), rand(sc.size))
  end

  def update
      # Main game update loop
      handle_boidness
      handle_movement
      handle_boundries

      cleanup_debug
      if @game.debug
        handle_debug
      end
    end

    def handle_boidness
      # Update the desired angle based on our boids ruleset
      handle_seperation
      handle_alignment
      handle_cohesion

      # TODO leave for now as it makes things easier
      # Set the boid to always be moving at the same speed
      @dp.set_mag(sc.size)
    end

    def get_nearby_boids
      return @game.boid_map.get_nearby_boids(self)
    end

    def handle_seperation
      # Check how close we are to our neighbors, and move our angle away
      # by a proportional ammount to how close we are
      sep_vec = Point.new
      for n in get_nearby_boids
        dist = @p.dist(n.p)
        relative_vec = n.p - @p
        relative_vec.set_mag(sc.sight)

        relative_dist = (sc.sight - dist) / sc.sight
        sep_vec += relative_vec * relative_dist
      end

      @dp -= sep_vec * sc.sep_power
    end

    def handle_alignment
      # Find the prevailing vector of our neighbors, and
      # add it to our own
      ali_vec = Point.new
      nearby = get_nearby_boids
      for n in nearby
        ali_vec += n.dp
      end

      # Set the alignment magnitude so we dont end up with
      # alignment strength bein 10x if there 10 nearby boids
      ali_vec.set_mag(sc.size)
      @dp += ali_vec * sc.ali_power
    end

    def handle_cohesion
      # Find the average point of all surrounding boids
      # and steer twoards that
      coh_pos = Point.new
      nearby = get_nearby_boids
      for n in nearby
        coh_pos += @p - n.p
      end
      @dp -= coh_pos * sc.coh_power
    end

    def handle_movement
      # Add speed to position, and update position of renderd shape
      # Add speed
      end_p = @p + (@dp * sc.size)
      @p += @dp

      # Assign point to shape
      @shape.x1 = @p.x
      @shape.y1 = @p.y
      @shape.x2 = end_p.x
      @shape.y2 = end_p.y
    end

    def handle_boundries
      # For now, wrap around
      if @p.x < -sc.size
        @p.x = @window.width + sc.size
      elsif @p.x > @window.width  + sc.size
        @p.x = -sc.size
      end

      if @p.y < -sc.size
        @p.y = @window.height  + sc.size
      elsif @p.y > @window.height  + sc.size
        @p.y = -sc.size
      end
    end

    def cleanup_debug
      # Cleanup from the last update loop of debug
      # (esp needed if debug was turned off)
      if not @debug_shapes.nil?
        for d in @debug_shapes
          d.remove
        end
      end
    end

    def handle_debug
      @debug_shapes = [
        Circle.new(
          color: [0.1, 0.1, 0.1, 1], radius: sc.sight / 2,
          x: @p.x, y: @p.y, width:5, z:-2)
      ]
      # Show lines connecting nearby boids
      for n in get_nearby_boids
        test_line = Line.new(
          x1: @p.x, y1: @p.y,
          x2: n.p.x, y2: n.p.y,
          color: 'orange', z:-1
        )
        @debug_shapes += [test_line]
      end
    end

  end