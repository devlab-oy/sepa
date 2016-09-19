require "test_helper"

class SamlinkResponseTest < ActiveSupport::TestCase
  setup do
    @gc_error_30 = Sepa::SamlinkResponse.new(
      response: File.read("#{SAMLINK_TEST_RESPONSE_PATH}/gc_error_30.xml"),
      command: :get_certificate,
    )
  end

  test 'response code can be retrieved' do
    assert_equal "30", @gc_error_30.response_code
  end
end
