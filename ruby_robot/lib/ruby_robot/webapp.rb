require 'sinatra/base'
require 'sinatra/swagger-exposer/swagger-exposer'
require 'ruby_robot'
require 'json-schema'
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

  # Tell sinatra to listen on all interfaces if it detects 
  # it is running on a docker container...otherwise it
  # will just bind to the loopback interface which can't be
  # exposed from the container.
  set :bind, '0.0.0.0' if File.exist?('/.dockerenv')

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

  def formatted_report
    r = robot.REPORT(false)
    if !r.nil?
      r[:direction] = r[:direction].upcase unless r[:direction].nil?
    end
    r
  end

  def position_report
    # Pass along the report, but the direction needs to be upcased to
    # comply w/ the JSON schema for the web API 
    [200, formatted_report.to_json]
  end

  def load_schema(name)
    schema_path = File.join(File.dirname(__FILE__), '..', '..', 'json_schema', "#{name}.schema.json")
    schema = JSON.load(File.new(schema_path))
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
      # Parse JSON args
      request.body.rewind
      request_params = JSON.parse(request.body.read)
      # Validate input against JSON schema
      schema = load_schema('request.place')
      json_schema_errors = JSON::Validator.fully_validate(schema, request_params)
      return [400, {code: 400, message: "Bad request: #{json_schema_errors.join('; ')}" }.to_json] unless json_schema_errors.empty?
      # Call robot#PLACE: inputs have already been validated by the JSON schema
      robot.PLACE(request_params['x'], request_params['y'], (request_params['direction']))
      [200, formatted_report.to_json]
    rescue
      # TODO: log failing request details to enterprise logging...
      # STDERR.puts $!
      [400, {code: 400, message: "Bad request (#{$!}): #{$!.backtrace.join("\n")}"}.to_json]
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