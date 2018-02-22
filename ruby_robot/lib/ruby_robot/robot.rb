module RubyRobot
class Robot

  # Directions are clockwise from north
  VALID_DIRECTIONS = [:north, :east, :south, :west]

  attr_reader :direction 
  attr_reader :tabletop
  
  def initialize(direction)
    orig_direction = direction
    err_msg = "New Robots must have direction value of one of the following symbols: #{VALID_DIRECTIONS.join(', ')}; invalid value '#{orig_direction}'"
    direction = direction.kind_of?(String) ? direction.downcase.to_sym : direction
    raise ConstructionError.new(err_msg) unless VALID_DIRECTIONS.include?(direction)
    @direction = direction
    @tabletop = nil
  end

  def inspect
    case @direction
    when :north then "^"
    when :south then "|"
    when :east  then ">"
    # :west
    else "<"
    end
  end

  def left
    # A little cheating here...index -1 will effectively wrap around and
    # return the last element
    @direction = VALID_DIRECTIONS[dir_idx - 1]
  end

  def right
    @direction = VALID_DIRECTIONS[(dir_idx + 1) % VALID_DIRECTIONS.size]
  end

  #
  # Called by a Tabletop where this has been placed
  #
  def place(tabletop)
    @tabletop = tabletop
  end

  def report
    @tabletop.position(self).merge(direction: direction)
  end

  #
  # TODO: Error checking for if @tabletop.nil?
  # Also, @tabletop.move and @tabletop.move? together
  # should be synchronized if multithreaded where > 1
  # Robot are on a Tabletop.
  # 
  # Return #report after call, whether it was successful
  # or not (assuming it _is_ in fact placed on a board).
  #
  def move
    @tabletop.move(self, direction) if @tabletop.move?(self, direction)
    report
  end

private

  def dir_idx
    VALID_DIRECTIONS.index(@direction)
  end

end
end