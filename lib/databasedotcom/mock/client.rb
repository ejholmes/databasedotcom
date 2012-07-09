require "securerandom"

module Databasedotcom
  class Client

    def authenticate(options = nil)
      self.version = "22.0"
      self.oauth_token = "foobar"
    end

    def list_sobjects
      describe_sobjects.collect { |sobject| sobject["name"] }
    end

    def describe_sobjects
      body = File.read(File.join(Databasedotcom.fixtures, "sobjects.json"))
      JSON.parse(body)["sobjects"]
    end

    def describe_sobject(class_name)
      body = File.read(File.join(Databasedotcom.fixtures, "describe", "#{class_name}.json"))
      JSON.parse(body)
    end

    def find(class_or_classname, record_id)
      class_or_classname = find_or_materialize(class_or_classname)
      mock_db.get(record_id)
    end

    def query(soql_expr)
      sobject_name = soql_expr.match(/FROM (\w*)/i)[1]
      mock_db[sobject_name]
    end

    def create(class_or_classname, object_attrs)
      class_or_classname = find_or_materialize(class_or_classname)
      json_for_assignment = coerced_json(object_attrs, class_or_classname)
      new_object = class_or_classname.new
      JSON.parse(json_for_assignment).each do |property, value|
        set_value(new_object, property, value, class_or_classname.type_map[property][:type])
      end
      id = fake_id
      set_value(new_object, "Id", id, "id")
      mock_db << new_object
      new_object
    end

    def update(class_or_classname, record_id, new_attrs)
      true
    end

    def upsert(class_or_classname, record_id, new_attrs)
      true
    end

    def delete(class_or_classname, record_id)
      mock_db.delete(record_id)
    end

  private

    def fake_id
      SecureRandom.hex
    end

    # A fake database to store the records in. Stores the records as a hash:
    #
    #   {
    #     "Account" => [],
    #     "Contact" => [],
    #   }
    def mock_db
      Databasedotcom.mock_db
    end
  end
end
