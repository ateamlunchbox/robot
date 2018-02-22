#
# Behold: I stand on the shoulders of giants...rossmeissl@github.com 
# is the _(wo?)man_
#
require 'bombshell'

module RubyRobot
class Shell < ::Bombshell::Environment
  include ::Bombshell::Shell

  prompt_with 'ILoveNetflixStudio'

  #
  # Place a robot
  #
  def place(x, y, direction)
    # Save state in case place is called w/ invalid coords
    orig_robot = @robot
    orig_tabletop = @tabletop
    # TODO: What happens when place is called > 1x per session?
    # Answer under time crunch: just replace the Robot and Tabletop
    @robot = Robot.new(direction)
    @tabletop = NetflixTabletop.new
    begin
      @tabletop.place(@robot, x: x, y: y)
    rescue
      @robot = orig_robot
      @tabletop = orig_tabletop
      STDERR.puts $!
    end
  end
  # alias :PLACE :place

  def move
    return if @robot.nil?
    @robot.move
  end
  # alias :MOVE :move 

  def left
    return if @robot.nil?
    @robot.left
  end
  # alias :LEFT :left 

  def right
    return if @robot.nil?
    @robot.right
  end
  # alias :RIGHT :right

  def report
    return if @robot.nil?
    STDOUT.puts @robot.report
  end
  # alias :REPORT :report

  #
  # Exit the REPL
  #
  def exit
    quit
  end
  # alias :EXIT :exit
end
end
