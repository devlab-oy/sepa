module Sepa
  class DanskeResponse < Response

    def bank_encryption_cert
      @bank_encryption_cert ||= extract_cert(doc, 'BankEncryptionCert', DANSKE_PKI)
    end

    def bank_signing_cert
      @bank_signing_cert ||= extract_cert(doc, 'BankSigningCert', DANSKE_PKI)
    end

    def bank_root_cert
      @bank_root_cert ||= extract_cert(doc, 'BankRootCert', DANSKE_PKI)
    end

    def own_encryption_cert
      @own_encryption_cert ||= extract_cert(doc, 'EncryptionCert', DANSKE_PKI)
    end

    def own_signing_cert
      @own_signing_cert ||= extract_cert(doc, 'SigningCert', DANSKE_PKI)
    end

    def ca_certificate
      @ca_certificate ||= extract_cert(doc, 'CACert', DANSKE_PKI)
    end

  end
end
