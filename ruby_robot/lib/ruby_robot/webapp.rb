require 'sinatra/base'
require 'sinatra/swagger-exposer/swagger-exposer'
require 'ruby_robot'
require 'json'

module RubyRobot

#
# SwaggerExposer turns out to have a few drawbacks; it doesn't support
# specifying enumerated string types.
#
USE_SWAGGER_EXPOSER=false

#
# Simple Sinatra webapp that supports:
#
# Run HTTP GET on /swagger.json to fetch a static JSON OpenAPI description 
# for this webapp (suitable for use with swagger.io's GUI).
#
class Webapp < Sinatra::Base
  set :public_folder, File.expand_path(File.join(File.dirname(__FILE__), '..', 'public'))
  enable :static


  REPORT_EXAMPLE_OBJ = {x:1,y:1,direction: :NORTH}
  REPORT_EXAMPLE = REPORT_EXAMPLE_OBJ.to_json

  ERR_PLACEMENT_MSG = 'Robot is not currently placed'

if USE_SWAGGER_EXPOSER
  register Sinatra::SwaggerExposer 
  #
  # Swagger general info
  #
  general_info(
    {
      version: RubyRobot::VERSION,
      title: 'RubyRobot',
      description: 'Web interface to RubyRobot API',
    }
  )

  #
  # Swagger types
  #
  type 'Error', {
    :required => [:code, :message],
    :properties => {
      :code => {
        :type => Integer,
        :example => 400,
        :description => 'The error code',
      },
      :message => {
        :type => String,
        :example => ERR_PLACEMENT_MSG,
        :description => 'The error message',
      }
    }
  }

  type 'Report', {
    required: [:x, :y, :direction],
    properties: {
      x: {
        type: Integer,
        example: 0
      },
      y: {
        type: Integer,
        example: 0
      },
      direction: {
        type: String,
        example: "NORTH"
      }
    }
  }
end # if USE_SWAGGER_EXPOSER

  #
  # "Normal" sinatra/ruby code.
  #
  def robot
    @@robot ||= proc { 
      rr = RubyRobot::Shell.new
      # In the webapp, don't log the REPORT messages to stdout
      rr.logger.formatter = proc { |severity, datetime, progname, msg| "" }
      rr
    }.call
  end

  def not_placed_error
    [400, {code: 400, message: ERR_PLACEMENT_MSG}.to_json]
  end

  def position_report 
    [200, robot.REPORT(false).to_json]
  end

if USE_SWAGGER_EXPOSER
  endpoint_description 'Place the robot'
  endpoint_parameter :body, "Robot placement specification object", :body, true, 'Report', {
    example: REPORT_EXAMPLE_OBJ
  } 
  endpoint_response 200, 'Report', 'Successful placement'
  endpoint_response 400, 'Error', ERR_PLACEMENT_MSG
  endpoint_tags 'Robot'
end # if USE_SWAGGER_EXPOSER
  post '/place' do 
    content_type :json
    request_params = nil
    result = nil
    begin
      request.body.rewind
      request_params = JSON.parse(request.body.read)
      # try to place; if false, it wasn't (re)placed, but 
      # it may still have a valid position.
      status_code = robot.PLACE(request_params['x'], request_params['y'], (request_params['direction'] || "north")) ? 200 : 400
      # If nil, then send an error
      result = robot.REPORT
      if result.nil? 
        [400, {code: 400, message: 'Invalid coordinates'}.to_json] 
      else
        [status_code, result.to_json]
      end
    rescue
     [400, {code: 400, message: 'Bad request'}.to_json]
    end
  end

if USE_SWAGGER_EXPOSER
  endpoint_description 'Move the robot'
  endpoint_response 200, 'Report', REPORT_EXAMPLE
  endpoint_response 400, 'Error', ERR_PLACEMENT_MSG
  endpoint_tags 'Robot'
end # if USE_SWAGGER_EXPOSER
  post '/move' do 
    content_type :json
    if robot.REPORT.nil?
      not_placed_error
    else
      robot.MOVE
      position_report
    end
  end

if USE_SWAGGER_EXPOSER
  endpoint_description 'Turn the robot left'
  endpoint_response 200, 'Report', REPORT_EXAMPLE
  endpoint_response 400, 'Error', ERR_PLACEMENT_MSG
  endpoint_tags 'Robot'
end # if USE_SWAGGER_EXPOSER
  post '/left' do
    content_type :json
    if robot.REPORT.nil?
      not_placed_error
    else
      robot.LEFT
      position_report
    end
  end

if USE_SWAGGER_EXPOSER
  endpoint_description 'Turn the robot right'
  endpoint_response 200, 'Report', REPORT_EXAMPLE
  endpoint_response 400, 'Error', ERR_PLACEMENT_MSG
  endpoint_tags 'Robot'
end # if USE_SWAGGER_EXPOSER
  post '/right' do
    content_type :json
    if robot.REPORT.nil?
      not_placed_error
    else
      robot.RIGHT
      position_report
    end
  end

if USE_SWAGGER_EXPOSER
  endpoint_description "Report the robot's position and orientation"
  endpoint_response 200, 'Report', REPORT_EXAMPLE
  endpoint_response 400, 'Error', ERR_PLACEMENT_MSG
  endpoint_tags 'Robot'
end # if USE_SWAGGER_EXPOSER
  get '/report' do
    content_type :json
    if robot.REPORT.nil?
      not_placed_error
    else
      position_report
    end
  end

if !USE_SWAGGER_EXPOSER
  get '/' do
    redirect '/index.html'
  end
end
end
end