require 'spec_helper'
require 'ruby_robot'

describe RubyRobot::Tabletop do

  context "before a Robot has been placed " do
    it "should know that a Robot has not been placed" do
      nt = RubyRobot::NetflixTabletop.new
      r = RubyRobot::Robot.new(:north)
      expect(nt.placed?(r)).to eql false
    end
    it "calling #position for the Robot should raise an error" do
      nt = RubyRobot::NetflixTabletop.new
      r = RubyRobot::Robot.new(:north)
      expect {
        nt.position(r)
      }.to raise_error(RubyRobot::PlacementError)
    end
    # TODO: Add tests for calling #move?, #position, #move, etc.
    # before a Robot has been placed.
  end

  context "after a Robot has been placed w/o specifying position" do
    it "should by default put the Robot at (0,0)" do
      nt = RubyRobot::NetflixTabletop.new
      r = RubyRobot::Robot.new(:south)
      nt.place(r)
      expect(nt.position(r)).to eq({x: 0, y: 0})
    end
    it "should know that a Robot has been placed" do
      nt = RubyRobot::NetflixTabletop.new
      r = RubyRobot::Robot.new(:south)
      nt.place(r)
      expect(nt.placed?(r)).to eql true
    end
  end

  context "when placing a Robot on the table" do
    it "should not allow x or y coords that are negative" do
      nt = RubyRobot::NetflixTabletop.new
      r = RubyRobot::Robot.new(:south)
      expect {
        nt.place(r, x: -3)
      }.to raise_error(RubyRobot::PlacementError)
    end
    it "should not allow x coord that is larger than width" do
      nt = RubyRobot::NetflixTabletop.new
      r = RubyRobot::Robot.new(:south)
      expect {
        nt.place(r, x: 300)
      }.to raise_error(RubyRobot::PlacementError)
    end
    it "should not allow y coord that is larger than height" do
      nt = RubyRobot::NetflixTabletop.new
      r = RubyRobot::Robot.new(:south)
      expect {
        nt.place(r, y: 300)
      }.to raise_error(RubyRobot::PlacementError)
    end
  end

  context "after a Robot has been placed at a specific position" do
    it "should be able to fetch the Robot's coordinates as a hash" do
      nt = RubyRobot::NetflixTabletop.new
      r = RubyRobot::Robot.new(:south)
      nt.place(r, x: 3, y: 1)
      expect(nt.position(r)).to eq({x: 3, y: 1})
    end

    it "placing the Robot again should move it" do
      nt = RubyRobot::NetflixTabletop.new
      r = RubyRobot::Robot.new(:south)
      nt.place(r, x: 3, y: 1)
      nt.place(r, x: 2, y: 4)
      expect(nt.position(r)).to eq({x: 2, y: 4})
    end 

    it "placing the Robot off the board (positively) should NOT move it" do
      nt = RubyRobot::NetflixTabletop.new
      r = RubyRobot::Robot.new(:south)
      nt.place(r, x: 3, y: 1)
      expect {
        nt.place(r, x: 200, y: 4)
      }.to raise_error(RubyRobot::PlacementError)
      expect(nt.position(r)).to eq({x: 3, y: 1})
    end 

    it "should be able to report its position" do
      nt = RubyRobot::NetflixTabletop.new
      r = RubyRobot::Robot.new(:south)
      nt.place(r, x: 3, y: 1)
      expect(r.report).to eq({x: 3, y: 1, direction: :south})
    end

    it "should be able to move successfully" do
      nt = RubyRobot::NetflixTabletop.new
      r = RubyRobot::Robot.new(:south)
      nt.place(r, x: 3, y: 1)
      expect(r.move).to eq({x: 3, y: 0, direction: :south})
    end
  end

  context "when a Robot is at an edge" do
    it "should not move when direction is :west and x is 0 " do
      nt = RubyRobot::NetflixTabletop.new
      r = RubyRobot::Robot.new(:west)
      nt.place(r, x: 0, y: 3)
      expect(r.move).to eq({x: 0, y: 3, direction: :west})
    end
    it "should not move when direction is :east and x is Tabletop width - 1 " do
      nt = RubyRobot::NetflixTabletop.new
      r = RubyRobot::Robot.new(:east)
      initial_x = nt.width - 1
      nt.place(r, x: initial_x, y: 3)
      # After moving, it should be the same
      expect(r.move).to   eq({x: initial_x, y: 3, direction: :east})
      # Just double check that #report agrees
      expect(r.report).to eq({x: initial_x, y: 3, direction: :east})
    end
    it "should not move when direction is :north and y is Tabletop height - 1" do
      nt = RubyRobot::NetflixTabletop.new
      r = RubyRobot::Robot.new(:north)
      initial_y = nt.height - 1
      nt.place(r, x: 1, y: initial_y)
      # After moving, it should be the same
      expect(r.move).to   eq({x: 1, y: initial_y, direction: :north})
      # Just double check that #report agrees
      expect(r.report).to eq({x: 1, y: initial_y, direction: :north})
    end
    it "should not move when direction is :south and y is 0" do
      nt = RubyRobot::NetflixTabletop.new
      r = RubyRobot::Robot.new(:south)
      initial_y = nt.height - 1
      nt.place(r, x: 2, y: 0)
      # After moving, it should be the same
      expect(r.move).to   eq({x: 2, y: 0, direction: :south})
      # Just double check that #report agrees
      expect(r.report).to eq({x: 2, y: 0, direction: :south})
    end
  end
end
