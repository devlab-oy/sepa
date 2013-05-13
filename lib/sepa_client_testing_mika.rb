# This app can be used to test the functionality of the sepa client

require 'sepa'

# Testing functionality of the parser side
process = Sepa::ApplicationResponse.new
# Comment in 1 animate_response out of 3 to debug reader with different types of responses
# process.animate_response("sepa/nordea_testing/response/download_filelist_response.xml")
# #puts "Status = NEW"
# #puts process.list_new_descriptors
# process.animate_response("sepa/nordea_testing/response/download_file_response.xml")
# process.animate_response("sepa/nordea_testing/response/get_user_info_response.xml")
# Comment out to test content attribute passing
# puts process.get_account_statement_content("sepa/nordea_testing/response/content_053.xml")
puts process.get_debit_credit_notification_content("sepa/nordea_testing/response/content_054.xml")