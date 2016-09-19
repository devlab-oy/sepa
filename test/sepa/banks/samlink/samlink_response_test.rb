require "test_helper"

class SamlinkResponseTest < ActiveSupport::TestCase
  setup do
    @gc_error_30 = Sepa::SamlinkResponse.new(
      response: File.read("#{SAMLINK_TEST_RESPONSE_PATH}/gc_error_30.xml"),
      command: :get_certificate,
    )
  end

  test '#response_code' do
    assert_equal "30", @gc_error_30.response_code
  end

  test '#response_text' do
    assert_equal "Asiakkaan palvelusopimuksen tarkistuksessa virhe:A00", @gc_error_30.response_text
  end

  test '#hashes_match' do
    assert @gc_error_30.hashes_match?
  end

  test '#signature_is_valid?' do
    assert @gc_error_30.signature_is_valid?
  end
end
