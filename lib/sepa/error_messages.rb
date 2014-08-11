module Sepa

  # Contains error messages used in this gem
  module ErrorMessages

    # Error message which is shown when {Client#customer_id} validation fails
    CUSTOMER_ID_ERROR_MESSAGE =
      'Customer Id needs to be present and needs to have a length of less than 17 characters'

    # Error message which is shown when {Client#environment} validation fails
    ENVIRONMENT_ERROR_MESSAGE = 'Environment needs to be either production or test'

    # Error message which is shown when {Client#target_id} validation fails
    TARGET_ID_ERROR_MESSAGE = 'Target Id needs to be present and under 80 characters'

    # Error message which is shown when {Client#file_type} validation fails
    FILE_TYPE_ERROR_MESSAGE = 'File type needs to be present and under 35 characters'

    # Error message which is shown when {Client#content} validation fails
    CONTENT_ERROR_MESSAGE = 'Content needs to be present for this command'

    # Error message which is shown when {Client#signing_csr} validation fails
    SIGNING_CERT_REQUEST_ERROR_MESSAGE = 'Invalid signing certificate request'

    # Error message which is shown when {Client#encryption_csr} validation fails
    ENCRYPTION_CERT_REQUEST_ERROR_MESSAGE = 'Invalid encryption certificate request'

    # Error message which is shown when {Client#pin} validation fails
    PIN_ERROR_MESSAGE =
      'Pin needs to be present for this command and cannot be more than 10 characters'

    # Error message which is shown when {Client#bank_encryption_certificate} validation fails
    ENCRYPTION_CERT_ERROR_MESSAGE = 'Invalid encryption certificate'

    # Error message which is shown when {Client#status} validation fails
    STATUS_ERROR_MESSAGE =
      'Status is required for this command and must be either NEW, DOWNLOADED or ALL'

    # Error message which is shown when {Client#file_reference} validation fails
    FILE_REFERENCE_ERROR_MESSAGE =
      'File reference is required for this command and must be under 33 characters'

    # Error message which is shown when {Client#encryption_private_key} validation fails
    ENCRYPTION_PRIVATE_KEY_ERROR_MESSAGE =
      'Encryption private key is needed for this bank and this command'

    # Error message which is shown when {Response#response_code} validation fails
    NOT_OK_RESPONSE_CODE_ERROR_MESSAGE =
      'The response from the bank suggested there was something wrong with your request, check ' \
      'your parameters and try again'

    # Error message which is shown when the response got from the bank cannot be decrypted with the
    # private key that is given to the client
    DECRYPTION_ERROR_MESSAGE =
      'The response could not be decrypted with the private key that you gave. Check that the ' \
      'key is the private key of your own encryption certificate'

    # Error message which is shown when the hash embedded in the {Response} soap doesn't match the
    # locally calculated one.
    HASH_ERROR_MESSAGE =
      'The hashes in the response did not match which means that the data in the response is not ' \
      'intact'

    # Error message which is shown when the signature in {Response} cannot be verified.
    SIGNATURE_ERROR_MESSAGE =
      'The signature in the response did not verify and the response cannot be trusted'
  end
end
