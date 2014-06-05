module Sepa
  module NordeaSoapRequest
  # Holding methods needed only for Danske Services SOAP
    private

      def find_correct_build
        case @command
        when :get_certificate
          build_certificate_request
        when :get_user_info,:download_file_list,:download_file,:upload_file
          build_common_request
        end
      end

      # Builds : Get Certificate
      # ------------------------------------------------------------------------
      def build_certificate_request
        set_body_contents
      end

      def set_body_contents
        set_node(@template, 'cer|ApplicationRequest', @ar)
        set_node(@template, 'cer|SenderId', @customer_id)
        set_node(@template, 'cer|RequestId', SecureRandom.hex(17))
        set_node(@template, 'cer|Timestamp', Time.now.iso8601)

        @template
      end
      # ------------------------------------------------------------------------

      # Builds : Get User Info, Download File, Download File List, Upload File
      # ------------------------------------------------------------------------
      def build_common_request
        header = @header_template

        common_set_body_contents
        process_header(header)
        add_body_to_header(header)
      end

      def common_set_body_contents
        set_node(@template, 'bxd|ApplicationRequest', @ar)
        set_node(@template, 'bxd|SenderId', @customer_id)
        set_node(@template, 'bxd|RequestId', SecureRandom.hex(17))
        set_node(@template, 'bxd|Timestamp', Time.now.iso8601)
        set_node(@template, 'bxd|Language', @language)
        set_node(@template, 'bxd|UserAgent',
                 "Sepa Transfer Library version " + VERSION)
        set_node(@template, 'bxd|ReceiverId', @target_id)
      end
  end
end
