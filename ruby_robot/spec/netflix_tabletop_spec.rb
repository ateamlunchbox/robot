require 'spec_helper'
require 'ruby_robot'

describe RubyRobot::NetflixTabletop do 
  context "When constructing a NetflixTabletop" do 
    it "should always have width=5 and height=5" do
      nt = RubyRobot::NetflixTabletop.new
      expect(nt.width).to eql 5
      expect(nt.height).to eql 5
    end
  end
end