require 'spec_helper'
require 'ruby_robot'
require 'json-schema'

module RubyRobot
class JsonSchema
end
end

describe RubyRobot::JsonSchema do 
  context "When using json schemas" do
    it "should pass validation for request.place.schema.json" do
      # TODO: pull all the setup boilerplate out into a common place
      metaschema = JSON::Validator.validator_for_name("draft4").metaschema
      schema_path = File.join(File.dirname(__FILE__), '..', 'doc', 'request.place.schema.json')
      schema = JSON.load(File.new(schema_path))
      errors = JSON::Validator.fully_validate(metaschema, schema)
      # puts "JSON schema validation errors: #{errors}"
      expect(JSON::Validator.validate(metaschema, schema)).to eql true
    end

    it "should pass validation for response.error.schema.json" do
      # TODO: pull all the setup boilerplate out into a common place
      metaschema = JSON::Validator.validator_for_name("draft4").metaschema
      schema_path = File.join(File.dirname(__FILE__), '..', 'doc', 'response.error.schema.json')
      schema = JSON.load(File.new(schema_path))
      errors = JSON::Validator.fully_validate(metaschema, schema)
      puts "JSON schema validation errors: #{errors}" unless errors.empty?
      expect(JSON::Validator.validate(metaschema, schema)).to eql true
    end

    it "should pass validation for response.report.schema.json" do
      # TODO: pull all the setup boilerplate out into a common place
      metaschema = JSON::Validator.validator_for_name("draft4").metaschema
      schema_path = File.join(File.dirname(__FILE__), '..', 'doc', 'response.report.schema.json')
      schema = JSON.load(File.new(schema_path))
      errors = JSON::Validator.fully_validate(metaschema, schema)
      puts "JSON schema validation errors: #{errors}" unless errors.empty?
      expect(JSON::Validator.validate(metaschema, schema)).to eql true
    end
  end

  context "When validating docs against request.place.schema.json" do
    it "should successfully validate a correct /place request" do
      schema_path = File.join(File.dirname(__FILE__), '..', 'doc', 'request.place.schema.json')
      schema = JSON.load(File.new(schema_path))
      test_doc = { "x" => 1, "y" => 2, "direction" => "NORTH" }
      errors = JSON::Validator.fully_validate(schema, test_doc)
      puts "JSON schema validation errors: #{errors}" unless errors.empty?
      expect(JSON::Validator.validate(schema, test_doc)).to eql true
    end

    it "should successfully reject an incorrect /place request" do
      schema_path = File.join(File.dirname(__FILE__), '..', 'doc', 'request.place.schema.json')
      schema = JSON.load(File.new(schema_path))
      test_doc = { "x" => 1, "y" => 2000, "direction" => "NORTH" }
      errors = JSON::Validator.fully_validate(schema, test_doc)
      expect(JSON::Validator.validate(schema, test_doc)).to eql false
    end
  end

  context "When validating docs against response.error.schema.json" do
    it "should successfully validate a correct error response" do
      schema_path = File.join(File.dirname(__FILE__), '..', 'doc', 'response.error.schema.json')
      schema = JSON.load(File.new(schema_path))
      test_doc = { "code" => 1, "message" => "test message" }
      errors = JSON::Validator.fully_validate(schema, test_doc)
      puts "JSON schema validation errors: #{errors}" unless errors.empty?
      expect(JSON::Validator.validate(schema, test_doc)).to eql true
    end

    it "should successfully reject an incorrect error response" do
      schema_path = File.join(File.dirname(__FILE__), '..', 'doc', 'response.error.schema.json')
      schema = JSON.load(File.new(schema_path))
      test_doc = {  }
      errors = JSON::Validator.fully_validate(schema, test_doc)
      expect(errors.size).to eql 2
      # puts "JSON schema validation errors: #{errors}" unless errors.empty?
      expect(JSON::Validator.validate(schema, test_doc)).to eql false
    end
  end

  context "When validating docs against response.report.schema.json" do
    it "should successfully validate a correct response" do
      schema_path = File.join(File.dirname(__FILE__), '..', 'doc', 'response.report.schema.json')
      schema = JSON.load(File.new(schema_path))
      test_doc = { "x" => 3, "y" => 4, "direction" => "SOUTH" }
      errors = JSON::Validator.fully_validate(schema, test_doc)
      puts "JSON schema validation errors: #{errors}" unless errors.empty?
      expect(JSON::Validator.validate(schema, test_doc)).to eql true
    end

    it "should reject an incorrect error response" do
      schema_path = File.join(File.dirname(__FILE__), '..', 'doc', 'response.report.schema.json')
      schema = JSON.load(File.new(schema_path))
      test_doc = {  }
      errors = JSON::Validator.fully_validate(schema, test_doc)
      expect(errors.size).to eql 3
      # puts "JSON schema validation errors: #{errors}" unless errors.empty?
      expect(JSON::Validator.validate(schema, test_doc)).to eql false
    end
  end
end