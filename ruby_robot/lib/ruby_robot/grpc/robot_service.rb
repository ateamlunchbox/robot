#!/usr/bin/env ruby
require 'grpc'
# Tweak the load path so ruby_robot_services_pb can 
# load ruby_robot_pb
$: << File.dirname(__FILE__) + '/../grpc_ruby'
require 'ruby_robot/grpc/ruby_robot_services_pb'

module RubyRobot
module Grpc
class RobotService < ::RubyRobot::RubyRobot::Service
  def left(empty, _unused_call)
    STDERR.puts "#{__method__} called"
    ::RubyRobot::RubyRobotResponse.new(
      error: ::RubyRobot::RubyRobotError.new(error: 400, message: "##{__method__} NYI")
    )
  end

  def move(empty, _unused_call)
    STDERR.puts "#{__method__} called"
    ::RubyRobot::RubyRobotResponse.new(
      error: ::RubyRobot::RubyRobotError.new(error: 400, message: "##{__method__} NYI")
    )
  end

  def place(robot_request, _unused_call)
    STDERR.puts "#{__method__} called"
    STDERR.puts robot_request
    STDERR.puts robot_request.x
    STDERR.puts robot_request.y
    STDERR.puts robot_request.direction

    ::RubyRobot::RubyRobotResponse.new(
      current_state: ::RubyRobot::RubyRobotRequest.new(
        x:         robot_request.x,
        y:         robot_request.y,
        direction: robot_request.direction
      )
    )
  end

  def remove(empty, _unused_call)
    STDERR.puts "#{__method__} called"
    ::RubyRobot::RubyRobotResponse.new(
      error: ::RubyRobot::RubyRobotError.new(error: 400, message: "##{__method__} NYI")
    )
  end

  def report(empty, _unused_call)
    STDERR.puts "#{__method__} called"
    ::RubyRobot::RubyRobotResponse.new(
      error: ::RubyRobot::RubyRobotError.new(error: 400, message: "##{__method__} NYI")
    )
  end

  def right(empty, _unused_call)
    STDERR.puts "#{__method__} called"
    ::RubyRobot::RubyRobotResponse.new(
      error: ::RubyRobot::RubyRobotError.new(error: 400, message: "##{__method__} NYI")
    )
  end
end
end
end
