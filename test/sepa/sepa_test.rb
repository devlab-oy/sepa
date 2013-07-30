require_relative '../test_helper'

class TestSepa < MiniTest::Test

  def test_version_must_be_defined
    refute_nil Sepa::VERSION
    assert_equal "0.0.2", Sepa::VERSION
  end

end

class TestSepaClient < MiniTest::Test

  def test_client_raises_an_exp_without_params
    assert_raises ArgumentError do
      Sepa::Client.new
    end
  end

end
