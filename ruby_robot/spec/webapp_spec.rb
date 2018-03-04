require 'ruby_robot'
require 'rack/test'

describe 'RubyRobot Sinatra App' do 
  include Rack::Test::Methods

  def app
    RubyRobot::Webapp.new
  end

  context "When fetching the Swagger.io API description" do
    it "should successfully return an OpenAPI JSON document" do
      get '/swagger.json'
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
      post '/place', data.to_json, 'Content-Type' => 'application/json'
      expect(JSON.parse(last_response.body)['message']).to include('Invalid coordinates')
      expect(last_response.status).to eql 400
    end

    it "POSTing to /place with negative args should respond with 400 and an error about 'invalid arg values'" do
      data = {
        x: -3,
        y: -1,
        direction: 'NORTH'
      }
      post '/place', data.to_json, 'Content-Type' => 'application/json'
      expect(JSON.parse(last_response.body)['message']).to include('Invalid coordinates')
      expect(last_response.status).to eql 400
    end

    it "POSTing with invalid json should respond with 400 and 'Bad request'" do
      expect  post '/place', "{", 'Content-Type' => 'application/json'
      expect(JSON.parse(last_response.body)['message']).to include('Bad request')
      expect(last_response.status).to eql 400
    end

    it "POSTing to /place with valid args should respond with 200 and the 'report' output." do
      data = {
        x: 3, 
        y: 2,
        direction: 'SOUTH'
      }
      post '/place', data.to_json, 'Content-Type' => 'application/json'
      expect(JSON.parse(last_response.body)).to eql({ 
        'x' => 3,
        'y' => 2,
        'direction' => 'south'
        })
      expect(last_response.status).to eql 200
    end
  end

  context "When talking to the webapp after robot placement" do
    it "should respond to POST /place w/ updated position output and HTTP 200" do
      data = {
        x: 3, 
        y: 2,
        direction: 'SOUTH'
      }
      post '/place', data.to_json, 'Content-Type' => 'application/json'
      expect(last_response.status).to eql 200
      post '/place', data.merge(x:1).to_json, 'Content-Type' => 'application/json'
      expect(JSON.parse(last_response.body)).to eql({ 
        'x' => 1,
        'y' => 2,
        'direction' => 'south'
        })
      expect(last_response.status).to eql 200
    end

    it "should respond to POST /place w/ invalid updated position output with the previous position and HTTP 400" do
      data = {
        x: 3, 
        y: 2,
        direction: 'SOUTH'
      }
      post '/place', data.to_json, 'Content-Type' => 'application/json'
      expect(last_response.status).to eql 200
      post '/place', data.merge(x:100).to_json, 'Content-Type' => 'application/json'
      expect(JSON.parse(last_response.body)).to eql({ 
        'x' => 3,
        'y' => 2,
        'direction' => 'south'
        })
      expect(last_response.status).to eql 400
    end

    it "should respond to POST /place w/ invalid JSON data with 'Bad request' message and HTTP 400" do
      data = {
        x: 3, 
        y: 2,
        direction: 'SOUTH'
      }
      post '/place', data.to_json, 'Content-Type' => 'application/json'
      expect(last_response.status).to eql 200
      post '/place', '{"hello', 'Content-Type' => 'application/json'
      expect(JSON.parse(last_response.body)['message']).to include('Bad request')
      expect(last_response.status).to eql 400
    end

    it "should respond to POST /left w/ HTTP 200 and current position" do
      data = { x: 3, y: 2, direction: 'SOUTH' }
      post '/place', data.to_json, 'Content-Type' => 'application/json'
      expect(last_response.status).to eql 200
      post '/left', '', 'Content-Type' => 'application/json'
      expect(JSON.parse(last_response.body)).to eql({
        'x' => 3, 'y' => 2, 'direction' => 'east'
      })
      expect(last_response.status).to eql 200
    end

    it "should respond to POST /right w/ HTTP 200 and current position" do
      data = { x: 3, y: 2, direction: 'SOUTH' }
      post '/place', data.to_json, 'Content-Type' => 'application/json'
      expect(last_response.status).to eql 200
      post '/right', '', 'Content-Type' => 'application/json'
      expect(JSON.parse(last_response.body)).to eql({
        'x' => 3, 'y' => 2, 'direction' => 'west'
      })
      expect(last_response.status).to eql 200
    end

    it "should respond to POST /move w/ HTTP 200 and current position" do
      data = { x: 3, y: 1, direction: 'SOUTH' }
      post '/place', data.to_json, 'Content-Type' => 'application/json'
      expect(last_response.status).to eql 200
      post '/move', '', 'Content-Type' => 'application/json'
      expect(JSON.parse(last_response.body)).to eql({
        'x' => 3, 'y' => 0, 'direction' => 'south'
      })
      expect(last_response.status).to eql 200
      # Attempt to "move off the board" and confirm it doesn't actually do that
      post '/move', '', 'Content-Type' => 'application/json'
      expect(JSON.parse(last_response.body)).to eql({
        'x' => 3, 'y' => 0, 'direction' => 'south'
      })
      expect(last_response.status).to eql 200
    end

    it "should respond to GET /report w/ HTTP 200 and current position" do
      data = { x: 3, y: 2, direction: 'SOUTH' }
      post '/place', data.to_json, 'Content-Type' => 'application/json'
      expect(last_response.status).to eql 200
      get '/report', '', 'Content-Type' => 'application/json'
      expect(JSON.parse(last_response.body)).to eql({
        'x' => 3, 'y' => 2, 'direction' => 'south'
      })
      expect(last_response.status).to eql 200
    end
  end
end
