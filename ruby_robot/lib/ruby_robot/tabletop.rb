#
# This class is a tabletop which is essentially a 2D
# array even though Ruby doesn't support 2D arrays
# like in other languages.
#
# As per the API instructions, (0,0) is considered
# to be the SOUTH WEST most corner.
#
module RubyRobot
class Tabletop
  attr_reader :width, :height

  def initialize(width, height)
    # Store position of each piece
    @width = width
    @height = height
    # Actually, this probably isn't necessary
    # @playing_field = Array.new(@width) { Array.new(@height) }
    # Hash with keys as the robot object and values are x/y coords
    @robots = {}
  end

  def width_range
    # Exclude width since positions are 0-based
    (0...@width)
  end

  def height_range
    # Exclude height since positions are 0-based
    (0...@height)
  end

  def calculate_position(orig_position, direction_sym)
    case direction_sym
    # These are clockwise from north
    when :north then orig_position[:y] += 1
    when :east  then orig_position[:x] += 1
    when :south then orig_position[:y] -= 1
    when :west  then orig_position[:x] -= 1
    end
    orig_position
  end

  #
  # Return hash of x/y coords for a placed
  # Robot, else raise PlacementError.  Position state doesn't
  # mean much to a Robot, by itself: only in 
  # relation to a Tabletop.
  #
  def position(robot)
    raise PlacementError.new "Robot is not on this table" unless placed?(robot)
    @robots[robot]
  end

  #
  # Can the Robot move in the specified direction
  # w/o falling off?  Even though direction is a
  # property of a specific Robot, pass it in here.
  #
  # Later this could be extended to support multiple
  # Robots on a Tabletop.  In that case, this and 
  # #move would need to be synchronized...
  #
  def move?(robot, direction_sym)
    raise PlacementError.new "Robot is not on this table" unless placed?(robot)
    possible_position = calculate_position(@robots[robot].clone, direction_sym)

    # Is current_position on the board?
    # Check in range (0..width).include?(x) and (0..height).include?(y)
    return false if 
      !width_range.include?(possible_position[:x]) or 
      !height_range.include?(possible_position[:y])
    true
  end

  #
  # Move the robot in the specified direction.
  #
  def move(robot, direction_sym)
    raise PlacementError.new "Robot is not on this table" unless placed?(robot)
    new_position = calculate_position(@robots[robot].clone, direction_sym)
    # Move the robot by placing it at its new location
    place(robot, **new_position)
  end

  #
  # Is this robot on this Tabletop?
  #
  def placed?(robot)
    @robots.keys.include?(robot)
  end

  #
  # NYI: Implement for multiple Robots per Tabletop
  #
  def place?(robot, direction_sym)
    true
  end

  #
  # Place a robot on this board
  #
  def place(robot, x:0, y:0)
    raise PlacementError.new "Coordinates (#{x},#{y}) are not on this board" if 
      !width_range.include?(x) || !height_range.include?(y)
    # @playing_field[x][y] = robot
    @robots[robot] = {x: x, y: y}
    robot.place(self)
  end

  #
  # Human-readable dump of Tabletop, with
  # 2D array index {x:0,y:0} in the lower-left
  # corner of the output.
  #
  def inspect
    @playing_field
  end
end
end