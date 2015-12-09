module Sepa
  # Handles OP specific response logic. Mainly certificate specific stuff.
  class OpResponse < Response
    include Utilities

    BYPASS_COMMANDS = %i(
      get_certificate
      get_service_certificates
    )

    # Extracts own signing certificate from the response.
    #
    # @return [String] own signing certificate as string it it is found
    # @return [nil] if the certificate cannot be found
    def own_signing_certificate
      application_response = extract_application_response(OP_PKI)
      at                   = 'xmlns|Certificate > xmlns|Certificate'
      node                 = Nokogiri::XML(application_response).at(at, xmlns: OP_XML_DATA)

      return unless node

      cert_value = process_cert_value node.content
      cert       = x509_certificate cert_value
      cert.to_s
    end

    # Returns the response code in the response. Overrides {Response#response_code} if {#command} is
    # `:get_certificate`, because the namespace is different with that command.
    #
    # @return [String] response code if it is found
    # @return [nil] if response code cannot be found
    # @see Response#response_code
    def response_code
      return super unless %i(
        get_certificate
        get_service_certificates
      ).include? command

      node = doc.at('xmlns|ResponseCode', xmlns: OP_PKI)
      node.content if node
    end

    # Returns the response text in the response. Overrides {Response#response_text} if {#command} is
    # `:get_certificate`, because the namespace is different with that command.
    #
    # @return [String] response text if it is found
    # @return [nil] if response text cannot be found
    # @see Response#response_text
    def response_text
      return super unless %i(
        get_certificate
        get_service_certificates
      ).include? command

      node = doc.at('xmlns|ResponseText', xmlns: OP_PKI)
      node.content if node
    end

    # Checks whether the certificate embedded in the response soap has been signed with OP's
    # root certificate. The check is skipped in test environment, because a different root
    # certificate is used. The check is also skipped for certificate requests because they are not
    # signed
    #
    # @return [true] if certificate is trusted
    # @return [false] if certificate fails to verify
    # @see DanskeResponse#certificate_is_trusted?
    def certificate_is_trusted?
      return true if environment == :test || BYPASS_COMMANDS.include?(command)

      verify_certificate_against_root_certificate(certificate, OP_ROOT_CERTIFICATE)
    end

    # Some OP's certificate responses aren't signed
    def validate_hashes
      super unless BYPASS_COMMANDS.include?(command)
    end

    # Some OP's certificate responses aren't signed
    def verify_signature
      super unless BYPASS_COMMANDS.include?(command)
    end
  end
end
