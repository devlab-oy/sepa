module Sepa
  class DanskeResponse < Response
    attr_reader :encryption_cert, :bank_signing_cert, :bank_root_cert, :own_encryption_cert,
                :own_signing_cert

    def initialize(response, command:)
      super
      @encryption_cert = extract_cert(document, 'BankEncryptionCert', 'http://danskebank.dk/PKI/PKIFactoryService/elements')
      @signing_cert = extract_cert(document, 'BankSigningCert', 'http://danskebank.dk/PKI/PKIFactoryService/elements')
      @bank_root_cert = extract_cert(document, 'BankRootCert', 'http://danskebank.dk/PKI/PKIFactoryService/elements')
      @own_encryption_cert = extract_cert(document, 'EncryptionCert', 'http://danskebank.dk/PKI/PKIFactoryService/elements')
      @own_signing_cert = extract_cert(document, 'SigningCert', 'http://danskebank.dk/PKI/PKIFactoryService/elements')
    end
  end
end
