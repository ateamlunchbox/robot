require 'ruby_robot'
require 'rack/test'

describe 'RubyRobot Sinatra App' do 
  include Rack::Test::Methods

  def app
    RubyRobot::Webapp.new
  end

  context "When fetching the Swagger.io API description" do
    it "should successfully return an OpenAPI JSON document" do
      get '/swagger_doc.json'
      expect(last_response.status).to eql 200
    end
  end

  context "When talking to the webapp before robot placement" do
    it "should respond with a 400 for /move with an error about 'not currently placed'" do
      post '/move'
      expect(JSON.parse(last_response.body)['message']).to include('not currently placed')
      expect(last_response.status).to eql 400
    end

    it "should respond with a 400 for /left and an error about 'not yet placed'" do
      post '/left'
      expect(JSON.parse(last_response.body)['message']).to include('not currently placed')
      expect(last_response.status).to eql 400
    end

    it "should respond with a 400 for /right and an error about 'not yet placed'" do
      post '/right'
      expect(JSON.parse(last_response.body)['message']).to include('not currently placed')
      expect(last_response.status).to eql 400
    end

    it "should respond with a 400 for /report and an error about 'not yet placed'" do
      get '/report'
      expect(JSON.parse(last_response.body)['message']).to include('not currently placed')
      expect(last_response.status).to eql 400
    end

    it "POSTing to /place with invalid args should respond with 400 and an error about 'invalid arg values'" do
      data = {
        x: 100,
        y: 100,
        direction: 'NORTH'
      }
      post '/place?x=100&y=100&direction=NORTH', data.to_json, 'Content-Type' => 'application/json'
      expect(JSON.parse(last_response.body)['message']).to include('should be <= than')
      expect(last_response.status).to eql 400
    end

    it "POSTing with invalid json should respond with 400 and 'Bad request'" do
      expect  post '/place?x=0&y=0&direction=SOUTH', "{", 'Content-Type' => 'application/json'
      expect(JSON.parse(last_response.body)['message']).to include('Bad request')
      expect(last_response.status).to eql 400
    end

    it "POSTing to /place with valid args should respond with 200 and the 'report' output." do
      data = {
        x: 3, 
        y: 2,
        direction: 'SOUTH'
      }
      post '/place?x=3&y=2&direction=SOUTH', data.to_json, 'Content-Type' => 'application/json'
      expect(JSON.parse(last_response.body)).to eql({ 
        'x' => 3,
        'y' => 2,
        'direction' => 'south'
        })
      expect(last_response.status).to eql 200
    end
  end
end
