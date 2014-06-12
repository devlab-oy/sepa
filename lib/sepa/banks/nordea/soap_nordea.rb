module Sepa
  module NordeaSoapRequest

    private

      def find_correct_build
        case @command
        when :get_certificate
          build_certificate_request
        when :get_user_info, :download_file_list, :download_file, :upload_file
          build_common_request
        end
      end

      # Builds : Get Certificate
      def build_certificate_request
        set_body_contents
      end

      def set_body_contents
        set_node(@template, 'cer|ApplicationRequest', @ar.to_base64)
        set_node(@template, 'cer|SenderId', @customer_id)
        set_node(@template, 'cer|RequestId', request_id)
        set_node(@template, 'cer|Timestamp', iso_time)

        @template
      end

      # Builds : Get User Info, Download File, Download File List, Upload File
      def build_common_request
        common_set_body_contents
        process_header
        add_body_to_header
      end

      def common_set_body_contents
        set_node(@template, 'bxd|ApplicationRequest', @ar.to_base64)
        set_node(@template, 'bxd|SenderId', @customer_id)
        set_node(@template, 'bxd|RequestId', request_id)
        set_node(@template, 'bxd|Timestamp', iso_time)
        set_node(@template, 'bxd|Language', @language)
        set_node(@template, 'bxd|UserAgent', "Sepa Transfer Library version #{VERSION}")
        set_node(@template, 'bxd|ReceiverId', @target_id)
      end

      def request_id
        SecureRandom.hex(17)
      end

  end
end
