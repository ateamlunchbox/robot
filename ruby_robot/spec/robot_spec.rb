require 'spec_helper'
require 'ruby_robot'

describe RubyRobot::Robot do 
  context "When constructing a Robot" do 
    it "should raise a RuntimeError when constructed w/ an invalid symbol" do
      expect {
        RubyRobot::Robot.new(:bad_direction)
      }.to raise_error(RubyRobot::ConstructionError)
    end

    it "should raise a RuntimeError when constructed w/ an unsupported object type" do
      expect {
        RubyRobot::Robot.new({x:1,y:2})
      }.to raise_error(RubyRobot::ConstructionError)
    end

    it "should successfully construct w/ a valid String argument" do
      expect(RubyRobot::Robot.new("east").direction).to eql :east
    end

    it "should successfully construct w/ a valid String argument and coerce to lower case" do
      expect(RubyRobot::Robot.new("NorTH").direction).to eql :north
    end

    it "should successfully construct w/ a valid Symbol argument" do
      expect(RubyRobot::Robot.new(:west).direction).to eql :west
    end
  end

  context "When 'navigating' a Robot" do
    #
    # Not sure if this is OK, but I like to collapse 
    # common tests into a block that creates the tests 
    # when testing a set of inputs that should map to 
    # a set of outputs.
    #
    right_tests = { west: :north, north: :east, east: :south, south: :west}
    right_tests.each { |from_state,to_state|
      it "should go from #{from_state} to #{to_state} on #right" do
        robot = RubyRobot::Robot.new(from_state)
        robot.right
        expect(robot.direction).to eql to_state
      end
    }
    # I suppose I could get (more) clever here and have a function that
    # generates the tests and takes the hash of froms/tos and a method
    # name...
    left_tests = { west: :south, south: :east, east: :north, north: :west}
    left_tests.each { |from_state,to_state|
      it "should go from #{from_state} to #{to_state} on #left" do
        robot = RubyRobot::Robot.new(from_state)
        robot.left
        expect(robot.direction).to eql to_state
      end
    }
    # it "should go from west to north on #right" do
    #   robot = RubyRobot::Robot.new(:west)
    #   robot.right
    #   expect(robot.direction).to eql :north
    # end
    # it "should go from north to east on #right" do
    #   robot = RubyRobot::Robot.new(:north)
    #   robot.right
    #   expect(robot.direction).to eql :east
    # end
    # it "should go from east to south on #right" do
    #   robot = RubyRobot::Robot.new(:east)
    #   robot.right
    #   expect(robot.direction).to eql :south
    # end
    # it "should go from south to west on #right" do
    #   robot = RubyRobot::Robot.new(:south)
    #   robot.right
    #   expect(robot.direction).to eql :west
    # end
  end

  context "When 'inspect'ing a Robot" do
    it "should print a carat (^) when pointing north" do
      expect(RubyRobot::Robot.new(:north).inspect).to eql '^'
    end
    it "should print a less-than (<) when pointing west" do
      expect(RubyRobot::Robot.new(:west).inspect).to eql '<'
    end
    it "should print a greater-than (>) when pointing east" do
      expect(RubyRobot::Robot.new(:east).inspect).to eql '>'
    end
    it "should print a pipe (|) when pointing south" do
      expect(RubyRobot::Robot.new(:south).inspect).to eql '|'
    end
  end
end