# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: ruby_robot.proto for package 'RubyRobot'
# Original file comments:
#
# gRPC service definition for the RubyRobot.
#

require 'grpc'
require 'ruby_robot_pb'

module RubyRobot
  module RubyRobot
    #
    # Service definitions
    #
    class Service

      include GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'RubyRobot.RubyRobot'

      rpc :Left, Google::Protobuf::Empty, RubyRobotResponse
      rpc :Move, Google::Protobuf::Empty, RubyRobotResponse
      rpc :Place, RubyRobotRequest, RubyRobotResponse
      rpc :Remove, Google::Protobuf::Empty, RubyRobotResponse
      rpc :Report, Google::Protobuf::Empty, RubyRobotResponse
      rpc :Right, Google::Protobuf::Empty, RubyRobotResponse
    end

    Stub = Service.rpc_stub_class
  end
end