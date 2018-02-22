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
  end

end
