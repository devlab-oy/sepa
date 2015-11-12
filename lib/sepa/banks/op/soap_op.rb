module Sepa

  # Contains OP specific soap building functionality
  module OpSoapRequest

    private

    # Determines which soap request to build based on command. Certificate requests are built
    # differently than generic requests.
    #
    # @return [Nokogiri::XML] the soap as a nokogiri document
    def find_correct_build
      case @command
      when :get_certificate, :get_service_certificates
        build_certificate_request
      when :get_user_info, :download_file_list, :download_file, :upload_file
        build_common_request
      end
    end

    # Sets contents for certificate request
    #
    # @return [Nokogiri::XML] the template with contents added to it
    def build_certificate_request
      set_body_contents
    end

    # Sets soap body contents. Application request is base64 encoded here.
    #
    # @return [Nokogiri::XML] the soap with contents added to it
    # @todo rename, because apparently only sets certificate contents
    def set_body_contents
      set_node(@template, 'opc|ApplicationRequest', @application_request.to_base64)
      set_node(@template, 'opc|SenderId', @customer_id)
      set_node(@template, 'opc|RequestId', request_id)
      set_node(@template, 'opc|Timestamp', iso_time)

      @template
    end

    # Builds generic request which is a request made with commands:
    # * Get User Info
    # * Download File
    # * Download File List
    # * Upload File
    #
    # @return [Nokogiri::XML] the generic request soap
    def build_common_request
      common_set_body_contents
      process_header
      add_body_to_header
    end

    # Sets nodes for generic requests, application request is base64 encoded here.
    def common_set_body_contents
      set_node(@template, 'bxd|ApplicationRequest', @application_request.to_base64)
      set_node(@template, 'bxd|SenderId', @customer_id)
      set_node(@template, 'bxd|RequestId', request_id)
      set_node(@template, 'bxd|Timestamp', iso_time)
      set_node(@template, 'bxd|Language', @language)
      set_node(@template, 'bxd|UserAgent', "Sepa Transfer Library version #{VERSION}")
      set_node(@template, 'bxd|ReceiverId', 'OKOYFIHH')
    end

    # Generates a random request id for Nordea request
    #
    # @return [String] hexnumeric request id
    # @todo move to utilities
    def request_id
      SecureRandom.hex(17)
    end

  end
end
