require 'bombshell'
require 'logger'
require 'ruby_robot/shell'
require 'ruby_robot/grpc_helper'
$: << File.dirname(__FILE__) + '/grpc_ruby'
require 'ruby_robot/grpc/ruby_robot_services_pb'

module RubyRobot
#
# Override all methods inherited from Shell
# such that they use gRPC to communicate 
# with a remote Robot.
#
# TODO: RPC error handling (more info at
# https://grpc.io/docs/guides/error.html).
#
class GrpcShell < ::Bombshell::Environment
  include ::Bombshell::Shell

  prompt_with 'ILoveNetflixStudio&gRPC'

  # TODO: Figure out if there's a way to pass args down into
  # ::Bombshell#launch so this isn't a class attr.
  def self.remote_url=(new_url)
    # Convert to URI if String
    @@remote_url = new_url.kind_of?(String) ? URI.parse(new_url) : new_url
  end
  def initialize
    # TODO: Enable SSL/TLS
    # Totally cheating here: if URI is grpc://netflix.avilla.net, 
    # then load up the cert (stored in the gem).
    channel_creds = :this_channel_is_insecure
    if @@remote_url.to_s.start_with?("gprcs://netflix.avilla.net")
      channel_creds = GRPC::Core::ChannelCredentials.new(
        File.read(File.join(File.dirname(__FILE__), "netflix.avilla.net.crt"))
      )
    end
    @stub = ::RubyRobot::RubyRobot::Stub.new("#{@@remote_url.host}:#{@@remote_url.port}", channel_creds)
  end

  def PLACE(x, y, direction)
    @stub.place(::RubyRobot::RubyRobotRequest.new(x: x, y: y, direction: direction.to_s.upcase.to_sym))
  end

  def MOVE
    @stub.move(Google::Protobuf::Empty.new)
  end

  def LEFT
    @stub.left(Google::Protobuf::Empty.new)
  end

  def RIGHT
    @stub.right(Google::Protobuf::Empty.new)
  end

  def REPORT(to_stderr=false)
    resp = @stub.report(Google::Protobuf::Empty.new)
    if resp.error
      puts resp.error.message 
    else
      puts resp.current_state.to_json
    end
  end

  def REMOVE
    @stub.remove(Google::Protobuf::Empty.new)
  end

  alias :QUIT :quit
end
end
module Bombshell
module Shell
  REMOVE=:remove
end
end
