require 'minitest/assertions'

module Minitest::Assertions
  def assert_same_items(expected, actual)
    assert same_items(expected, actual),
           "Expected #{expected.inspect} and #{actual.inspect} to have the same items"
  end

  def refute_same_items(expected, actual)
    refute same_items(expected, actual),
           "Expected #{expected.inspect} and #{actual.inspect} would not have the same items"
  end

  def assert_valid_against_schema(schema, document)
    errors = []

    Dir.chdir(SCHEMA_PATH) do
      xsd = Nokogiri::XML::Schema(IO.read(schema))
      xsd.validate(document).each do |error|
        errors << error
      end
    end

    assert errors.empty?, "The following schema validations failed:\n#{errors.join("\n")}"
  end

  def refute_valid_against_schema(schema, document)
    Dir.chdir(SCHEMA_PATH) do
      xsd = Nokogiri::XML::Schema(IO.read(schema))

      refute xsd.valid?(document)
    end
  end

  private

    def same_items(expected, actual)
      actual.is_a?(Enumerable) && expected.is_a?(Enumerable) &&
        expected.count == actual.count && actual.all? { |e| expected.include?(e) }
    end
end
