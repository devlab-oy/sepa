module Sepa
  class DanskeResponse < Response

    # Namespace used in danske bank certificate responses and requests
    TNS = 'http://danskebank.dk/PKI/PKIFactoryService/elements'

    def bank_encryption_cert
      extract_cert(soap, 'BankEncryptionCert', TNS)
    end

    def bank_signing_cert
      extract_cert(soap, 'BankSigningCert', TNS)
    end

    def bank_root_cert
      extract_cert(soap, 'BankRootCert', TNS)
    end

    def own_encryption_cert
      extract_cert(soap, 'EncryptionCert', TNS)
    end

    def own_signing_cert
      extract_cert(soap, 'SigningCert', TNS)
    end

    def ca_certificate
      extract_cert(soap, 'CACert', TNS)
    end

  end

end
