require 'test_helper'

class TestSepa < ActiveSupport::TestCase

  def test_version_must_be_defined
    refute_nil Sepa::VERSION
    assert_equal "0.1.0", Sepa::VERSION
  end

end
