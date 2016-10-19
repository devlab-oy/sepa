require 'test_helper'

class OpResponseTest < ActiveSupport::TestCase
  test "fails with invalid params" do
    a = Sepa::OpResponse.new(response: "Jees", command: "not")
    refute a.valid?
  end

  test "complains if application response is not valid against schema" do
    a = Sepa::OpResponse.new(response: "<ar>text</ar>", command: "notvalid")
    refute a.valid?
  end
end
