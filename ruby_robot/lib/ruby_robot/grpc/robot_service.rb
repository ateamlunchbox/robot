#!/usr/bin/env ruby
require 'grpc'
# Tweak the load path so ruby_robot_services_pb can 
# load ruby_robot_pb
$: << File.dirname(__FILE__) + '/../grpc_ruby'
require 'ruby_robot/grpc/ruby_robot_services_pb'
require 'logger'
$:.unshift(File.dirname(__FILE__) + '/../lib') unless $:.include?(File.dirname(__FILE__) + '/../lib')
require 'ruby_robot'

module RubyRobot
module Grpc
class RobotService < ::RubyRobot::RubyRobot::Service
  def logger
    @logger ||= proc {
      Logger.new(STDOUT)
    }.call
  end

  def robot
    @@robot ||= proc {
      rr = ::RubyRobot::Shell.new
      def rr.placed?
        !@robot.nil?
      end
      rr
    }.call
  end

  def not_placed_error
    ::RubyRobot::RubyRobotResponse.new(
      error: ::RubyRobot::RubyRobotError.new(error: 400, message: "Robot is not currently placed")
    )
  end

  def position_report
    rr = robot.REPORT(false)

    ::RubyRobot::RubyRobotResponse.new(
      current_state: ::RubyRobot::RubyRobotRequest.new(
        x:         rr[:x],
        y:         rr[:y],
        direction: rr[:direction].to_s.upcase.to_sym
      )
    )
  end

  def left(empty, _unused_call)
    logger.info "#{__method__} called (robot.placed?==#{robot.placed?})"
    if robot.placed?
      robot.LEFT
      position_report
    else
      not_placed_error
    end
  end

  def move(empty, _unused_call)
    logger.info "#{__method__} called (robot.placed?==#{robot.placed?})"
    if robot.placed?
      robot.MOVE
      position_report
    else
      not_placed_error
    end
  end

  def place(robot_request, _unused_call)
    input = { x: robot_request.x, y: robot_request.y, direction: robot_request.direction }
    logger.info "#{__method__} called with #{input.to_json}"

    robot.PLACE(robot_request.x, robot_request.y, robot_request.direction.to_s.downcase)
    position_report
  end

  def remove(empty, _unused_call)
    logger.info "#{__method__} called"
    @@robot = nil
    ::Google::Protobuf::Empty.new
  end

  def report(empty, _unused_call)
    logger.info "#{__method__} called (robot.placed?==#{robot.placed?})"
    if robot.placed?
      position_report
    else
      not_placed_error
    end
  end

  def right(empty, _unused_call)
    logger.info "#{__method__} called (robot.placed?==#{robot.placed?})"
    if robot.placed?
      robot.RIGHT
      position_report
    else
      not_placed_error
    end
  end
end
end
end
