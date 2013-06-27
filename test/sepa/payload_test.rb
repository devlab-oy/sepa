require File.expand_path('../../test_helper.rb', __FILE__)

class TestPayload < MiniTest::Test
  def setup
    @params = {}
    @payload = Sepa::Payload.new(@params)
  end

  def test_should_initialize_with_hash
    assert Sepa::Payload.new(@params)
  end
end
