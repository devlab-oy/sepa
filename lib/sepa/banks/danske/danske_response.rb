module Sepa
  class DanskeResponse < Response
    attr_reader :bank_encryption_cert, :bank_signing_cert, :bank_root_cert, :own_encryption_cert,
                :own_signing_cert, :ca_certificate

    # Namespace used in danske bank certificate responses and requests
    TNS = 'http://danskebank.dk/PKI/PKIFactoryService/elements'

    def initialize(response, command:)
      super
      @bank_encryption_cert = extract_cert(soap, 'BankEncryptionCert', TNS)
      @bank_signing_cert = extract_cert(soap, 'BankSigningCert', TNS)
      @bank_root_cert = extract_cert(soap, 'BankRootCert', TNS)
      @own_encryption_cert = extract_cert(soap, 'EncryptionCert', TNS)
      @own_signing_cert = extract_cert(soap, 'SigningCert', TNS)
      @ca_certificate = extract_cert(soap, 'CACert', TNS)
    end
  end
end
