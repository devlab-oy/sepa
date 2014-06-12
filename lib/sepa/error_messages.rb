module Sepa
  module ErrorMessages
    CUSTOMER_ID_ERROR_MESSAGE = 'Customer Id needs to be present and needs to have a length of less than 17 characters'
    ENVIRONMENT_ERROR_MESSAGE = 'Environment needs to be either PRODUCTION, TEST or customertest'
    TARGET_ID_ERROR_MESSAGE = 'Target Id needs to be present and under 80 characters'
    FILE_TYPE_ERROR_MESSAGE = 'File type needs to be present and under 35 characters'
    CONTENT_ERROR_MESSAGE = 'Content needs to be present for this command'
    SIGNING_CERT_REQUEST_ERROR_MESSAGE = 'Invalid signing certificate request'
    ENCRYPTION_CERT_REQUEST_ERROR_MESSAGE = 'Invalid encryption certificate request'
    PIN_ERROR_MESSAGE = 'Pin needs to be present for this command and cannot be more than 10 characters'
    ENCRYPTION_CERT_ERROR_MESSAGE = 'Invalid encryption certificate'
    STATUS_ERROR_MESSAGE = 'Status is required for this command and must be either NEW, DOWNLOADED or ALL'
  end
end
