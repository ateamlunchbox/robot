$:.unshift(File.dirname(__FILE__) + '/../spec') unless $:.include?(File.dirname(__FILE__) + '/../spec')

require 'spec_helper'
require 'ruby_robot'

EXE_PATH=File.join(File.dirname(__FILE__), '..', 'exe', 'ruby_robot')
#
# NOTE: The ruby_robot gem must be installed locally to
# provide access to the 'ruby_robot' executable; this spec
# tests the ruby_robot REPL interpreter.
#
describe RubyRobot::Tabletop do
  context "when running the commandline ruby_robot" do
    it "should support the first scenario" do
      cmds = <<-EOI
PLACE 0,0,NORTH
MOVE
REPORT
QUIT
EOI
      results = {x: 0, y: 1, direction: :north}
      output = `echo "#{cmds}" 2>/dev/null | #{EXE_PATH} | grep '^{'`.strip
      expect(eval output).to eql results
    end
    it "should support the second scenario" do
      cmds = <<-EOI
PLACE 0,0,NORTH
LEFT
REPORT
QUIT
EOI
      results = {x: 0, y: 0, direction: :west}
      output = `echo "#{cmds}" 2>/dev/null | #{EXE_PATH} | grep '^{'`.strip
      expect(eval output).to eql results
    end
    it "should support the third scenario" do
      cmds = <<-EOI
PLACE 1,2,EAST
MOVE
MOVE
LEFT
MOVE
REPORT
QUIT
EOI
      results = {x: 3, y: 3, direction: :north}
      output = `echo "#{cmds}" 2>/dev/null | #{EXE_PATH} | grep '^{'`.strip
      expect(eval output).to eql results
    end
    it "should support a modified third scenario" do
      # Placing off the board should NOT update its position/
      # orientation.
      cmds = <<-EOI
PLACE 1,2,EAST
MOVE
MOVE
LEFT
MOVE
PLACE 100,1,SOUTH
REPORT
QUIT
EOI
      results = {x: 3, y: 3, direction: :north}
      # Eat expected stderr output
      output = `echo "#{cmds}" 2>/dev/null | #{EXE_PATH} | grep '^{'`.strip
      expect(eval output).to eql results
    end
  end
end