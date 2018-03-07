require 'spec_helper'
require 'ruby_robot'
require 'json-schema'

module RubyRobot
class JsonSchema
end
end

describe RubyRobot::JsonSchema do 

  include ::RubyRobot::SchemaLoader

  before :all do
    @metaschema = JSON::Validator.validator_for_name("draft4").metaschema
    @response_schema = load_schema('response')
    @request_schema = load_schema('request')
  end

  context "When using json schemas" do
    it "should pass validation for request.schema.json" do
      errors = JSON::Validator.fully_validate(@metaschema, @request_schema)
      # puts "JSON schema validation errors: #{errors}" unless errors.empty?
      expect(JSON::Validator.validate(@metaschema, @request_schema)).to eql true
    end

    it "should pass validation for response.schema.json" do
      errors = JSON::Validator.fully_validate(@metaschema, @response_schema)
      # puts "JSON schema validation errors: #{errors}" unless errors.empty?
      expect(JSON::Validator.validate(@metaschema, @response_schema)).to eql true
    end
  end

  context "When validating HTTP request JSON docs against request.schema.json" do
    it "should successfully validate a correct /place request" do
      test_doc = { "x" => 1, "y" => 2, "direction" => "NORTH" }
      errors = JSON::Validator.fully_validate(@request_schema, test_doc)
      # puts "JSON schema validation errors: #{errors}" unless errors.empty?
      expect(JSON::Validator.validate(@request_schema, test_doc)).to eql true
    end

    it "should successfully reject an incorrect /place request" do
      test_doc = { "x" => 1, "y" => 2000, "direction" => "NORTH" }
      errors = JSON::Validator.fully_validate(@request_schema, test_doc)
      expect(JSON::Validator.validate(@request_schema, test_doc)).to eql false
      # Check against the combined response schema
      expect(JSON::Validator.validate(@response_schema, test_doc)).to eql false
    end
  end

  context "When validating docs against response.schema.json" do
    it "should successfully validate a correct error response" do
      test_doc = { "code" => 1, "message" => "test message" }
      errors = JSON::Validator.fully_validate(@response_schema, test_doc)
      # puts "JSON schema validation errors: #{errors}" unless errors.empty?
      expect(JSON::Validator.validate(@response_schema, test_doc)).to eql true
    end

    it "should successfully validate an error response that was initially failing in the webapp's #after /place validation" do
      test_doc = { "code" => 400, "message" => "ad request: The property '#/' did not contain a required property of 'x' in schema http://github.com/ateamlunchbox/robot/ruby_robot/doc/request.schema.json#; The property '#/' did not contain a required property of 'y' in schema http://github.com/ateamlunchbox/robot/ruby_robot/doc/request.schema.json#"[0...255] }
      errors = JSON::Validator.fully_validate(@response_schema, test_doc)
      # puts "JSON schema validation errors: #{errors}" unless errors.empty?
      errors = JSON::Validator.fully_validate(@response_schema, test_doc)
      puts "JSON schema validation errors for test_doc(#{test_doc}): #{errors}" unless errors.empty?
      expect(JSON::Validator.validate(@response_schema, test_doc)).to eql true
    end

    it "should successfully validate a second error response that was initially failing in the webapp's #after /place validation" do
      test_doc = { "code" => 400, "message" => "Bad request (A JSON text must at least contain two octets!)" }
      errors = JSON::Validator.fully_validate(@response_schema, test_doc)
      # puts "JSON schema validation errors: #{errors}" unless errors.empty?
      errors = JSON::Validator.fully_validate(@response_schema, test_doc)
      puts "JSON schema validation errors for test_doc(#{test_doc}): #{errors}" unless errors.empty?
      expect(JSON::Validator.validate(@response_schema, test_doc)).to eql true
    end

    it "should successfully reject an incorrect error response" do
      test_doc = {  }
      errors = JSON::Validator.fully_validate(@response_schema, test_doc)
      expect(errors.size).not_to eq(0)
      # puts "JSON schema validation errors: #{errors}" unless errors.empty?
      expect(JSON::Validator.validate(@response_schema, test_doc)).to eql false
    end
  end

  context "When validating docs against response.schema.json" do
    it "should successfully validate a correct response" do
      test_doc = { "x" => 3, "y" => 4, "direction" => "SOUTH" }
      errors = JSON::Validator.fully_validate(@response_schema, test_doc)
      # puts "JSON schema validation errors: #{errors}" unless errors.empty?
      expect(JSON::Validator.validate(@response_schema, test_doc)).to eql true
    end

    it "should reject an incorrect error response" do
      test_doc = {  }
      errors = JSON::Validator.fully_validate(@response_schema, test_doc)
      expect(errors.size).not_to eql 0
      # puts "JSON schema validation errors: #{errors}" unless errors.empty?
      expect(JSON::Validator.validate(@response_schema, test_doc)).to eql false
    end
  end

end
