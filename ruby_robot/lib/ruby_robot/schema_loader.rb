module RubyRobot
  module SchemaLoader

    def load_schema(name)
      schema_path = File.join(File.dirname(__FILE__), '..', '..', 'json_schema', "#{name}.schema.json")
      schema = JSON.load(File.new(schema_path))
    end

  end
end
