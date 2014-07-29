module Sepa
  class DanskeResponse < Response

    def bank_encryption_certificate
      return unless @command == :get_bank_certificate

      @bank_encryption_certificate ||= extract_cert(doc, 'BankEncryptionCert', DANSKE_PKI)
    end

    def bank_signing_certificate
      return unless @command == :get_bank_certificate

      @bank_signing_certificate ||= extract_cert(doc, 'BankSigningCert', DANSKE_PKI)
    end

    def bank_root_certificate
      return unless @command == :get_bank_certificate

      @bank_root_certificate ||= extract_cert(doc, 'BankRootCert', DANSKE_PKI)
    end

    def own_encryption_certificate
      return unless @command == :create_certificate

      @own_encryption_certificate ||= extract_cert(doc, 'EncryptionCert', DANSKE_PKI)
    end

    def own_signing_certificate
      return unless @command == :create_certificate

      @own_signing_certificate ||= extract_cert(doc, 'SigningCert', DANSKE_PKI)
    end

    def ca_certificate
      return unless @command == :create_certificate

      @ca_certificate ||= extract_cert(doc, 'CACert', DANSKE_PKI)
    end

    def certificate
      if @command == :create_certificate
        @certificate ||= begin
          extract_cert(doc, 'X509Certificate', DSIG)
        end
      end
    end

    private

      def find_node_by_uri(uri)
        node = doc.at("[xml|id='#{uri}']")
        node.at('xmlns|Signature', xmlns: DSIG).remove
        node
      end

  end
end
