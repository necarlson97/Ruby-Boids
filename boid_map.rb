
class BoidMap
  # A grid of 'boid buckets' that can be used
  # to optimize which boids are nearby
  def initialize(game)
    @game = game
    @window = game.window
    @boids = game.flock.boids

    @grid_size = Boid.sight

    # Hash of tuples to list of boids, where the tuple is the
    # x and y of the bucket
    @buckets = {}
  end

  def update
    # Place boids in the proper buckets
    for b in @boids
      # Get reference from boid to remove from bucket
      old_b = b.bucket
      if @buckets[old_b]
        @buckets[old_b].delete(b)
      end

      # Add new refernce to boid, and add boid from bucket 
      new_b = get_center_bucket(b)
      b.bucket = new_b
      if not @buckets[new_b]
        @buckets[new_b] = []
      end
      @buckets[new_b] += [b]

      self.handle_debug
    end
  end

  def handle_debug
    # Blue squares that show how many are in each center bucket
    if @tmp_squares
      for t in @tmp_squares
        t.remove
      end
    end
    @tmp_squares = []
    if @game.debug
      @buckets.each do |b_coord, bucket|
        bx, by = b_coord
        x, y = bx * Boid.sight, by * Boid.sight
        @tmp_squares += [Square.new(
          x: x, y: y,
          size: Boid.sight,
          color: [0, 0, 1, bucket.length / 10.0],
          z: -2
        )]
      end
    end
  end

  def get_nearby_buckets(boid)
    # Given a boid, get their central bucket,
    # then find all 8 (max) buckets around it.
    # A boid in the center bucket could never see outside these
    # buckets, so they are all we need to search
    cb = get_center_bucket(boid)

    # An array that finds us all buckets around with their relative position
    # the 'delta bucket points' 
    db = [
      [-1, -1], [0, -1], [1, -1],
      [-1, 0], [0, 0], [1, 0],
      [-1, 1], [0, -1], [1, 1],
    ]
    return db.map { |tup| [tup[0] + cb[0], tup[1] + cb[1]] }
  end

  def get_center_bucket(boid)
    bx = (boid.p.x / @grid_size).to_i.abs
    by = (boid.p.y / @grid_size).to_i.abs
    return [bx, by]
  end

  def get_nearby_boids(boid)
    b_coords = get_nearby_buckets(boid)
    nearby = []
    for b_coord in b_coords
      # If we have a bucket for that coordinates
      if @buckets[b_coord]
        # For each boid in the nearby buckets
        for b in @buckets[b_coord]
          # If the boid is not myself, and is actually in my sight
          if b != boid and (b.bucket == boid.bucket or boid.p.dist(b.p) < b.sc.sight)
            nearby += [b]
          end
          # If we are full on nearby boids, return
          if nearby.length >= b.sc.max_focus
            return nearby
          end
        end 
      end
    end
    return nearby
  end

end
