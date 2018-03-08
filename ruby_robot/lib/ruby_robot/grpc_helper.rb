require 'ruby_robot/grpc_ruby/ruby_robot_pb'
#
# Define #to_json on ::RubyRobot::RubyRobotRequest for prettier printing.
#
module RubyRobot
class RubyRobotRequest
  def to_json
    {
      x: self.x,
      y: self.y,
      direction: self.direction.to_s
    }.to_json
  end
end
end