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
        when :get_certificate,
             :get_service_certificates
          build_certificate_request
        when :download_file,
             :download_file_list,
             :upload_file
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
      def set_body_contents
        set_node @template, 'opc|ApplicationRequest', @application_request.to_base64
        set_node @template, 'opc|SenderId', @customer_id
        set_node @template, 'opc|RequestId', request_id
        set_node @template, 'opc|Timestamp', iso_time

        @template
      end

      # Builds generic request which is a request made with commands:
      # * Download File
      # * Download File List
      # * Upload File
      #
      # @return [Nokogiri::XML] the generic request soap
      def build_common_request
        common_set_body_contents
        set_receiver_id
        process_header
        add_body_to_header
      end

      def set_receiver_id
        set_node @template, 'bxd|ReceiverId', 'OKOYFIHH'
      end

  end
end
