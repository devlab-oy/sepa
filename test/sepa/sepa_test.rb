require_relative '../test_helper'

class TestSepa < MiniTest::Unit::TestCase

  def test_version_must_be_defined
    refute_nil Sepa::VERSION
    assert_equal "0.0.1", Sepa::VERSION
  end

end

class TestSepaClient < MiniTest::Unit::TestCase

  def test_client_raises_an_exp_without_params
    assert_raises ArgumentError do
      Sepa::Client.new
    end
  end

end
