# Simple data class
class Point
  attr_accessor :x, :y

  def initialize(x=0, y=0)
    if x.class == Point
      other = x
      x = other.x
      y = other.y
    end
    @x, @y = x, y
  end

  def dist(other=Point.new(0, 0))
    # Distance to other point (with default giving magnitude)
    dx = other.x - @x
    dy = other.y - @y
    return Math.sqrt(dx*dx + dy*dy)
  end

  def set(x, y)
    @x = x
    @y = y
  end

  def set_mag(m)
    # Set magnitude
    d = dist
    # TODO HACK
    if d == 0
      d = 0.0001
    end
    @x = @x * m / d
    @y = @y * m / d
  end

  def +(other)
    return Point.new(@x + other.x, @y + other.y)
  end

  def *(n)
    return Point.new(@x * n, @y * n)
  end

  def -(other)
    return Point.new(@x - other.x, @y - other.y)
  end

  def /(n)
    return Point.new(@x / n, @y / n)
  end

  # TODO rewrite if needed
  # def polar_to_cart(angle, root_point=nil, dist=nil)
  #   # Cartesian to polar using hte current angle
  #   if root_point.nil?  # If no root is given, use current postion
  #     root_point = @p
  #   end
  #   if dist.nil? # If no distance is given, use size
  #     dist = @@size
  #   end
  #   dx = Math.cos(angle) * dist
  #   dy = Math.sin(angle) * dist
  #   return Point.new(root_point.x + dx, root_point.y + dy)
  # end
end