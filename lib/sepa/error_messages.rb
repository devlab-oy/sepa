module Sepa
  module ErrorMessages
    CUSTOMER_ID_ERROR_MESSAGE = 'Customer Id needs to be present and needs to have a length of less than 17 characters'
    ENVIRONMENT_ERROR_MESSAGE = 'Environment needs to be either production or test'
    TARGET_ID_ERROR_MESSAGE = 'Target Id needs to be present and under 80 characters'
    FILE_TYPE_ERROR_MESSAGE = 'File type needs to be present and under 35 characters'
    CONTENT_ERROR_MESSAGE = 'Content needs to be present for this command'
    SIGNING_CERT_REQUEST_ERROR_MESSAGE = 'Invalid signing certificate request'
    ENCRYPTION_CERT_REQUEST_ERROR_MESSAGE = 'Invalid encryption certificate request'
    PIN_ERROR_MESSAGE = 'Pin needs to be present for this command and cannot be more than 10 characters'
    ENCRYPTION_CERT_ERROR_MESSAGE = 'Invalid encryption certificate'
    STATUS_ERROR_MESSAGE = 'Status is required for this command and must be either NEW, DOWNLOADED or ALL'
    FILE_REFERENCE_ERROR_MESSAGE = 'File reference is required for this command and must be under 33 characters'
    ENCRYPTION_PRIVATE_KEY_ERROR_MESSAGE = 'Encryption private key is needed for this bank and this command'
    NOT_OK_RESPONSE_CODE_ERROR_MESSAGE = 'The response from the bank suggested there was ' \
    'something wrong with your request, check your parameters and try again'

    DECRYPTION_ERROR_MESSAGE = 'The response could not be decrypted with the private key ' \
    'that you gave. Check that the key is the private key of your own encryption certificate'

    HASH_ERROR_MESSAGE = 'The hashes in the response did not match which means that the data in ' \
    'the response is not intact'
  end
end
