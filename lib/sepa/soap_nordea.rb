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
        body = load_body_template
        set_body_contents(body, @ar, @customer_id)
      end

      def set_body_contents(body, ar, sender_id)
        set_node(body, 'cer|ApplicationRequest', ar)
        set_node(body, 'cer|SenderId', @customer_id)
        set_node(body, 'cer|RequestId', SecureRandom.hex(17))
        set_node(body, 'cer|Timestamp', Time.now.iso8601)

        body
      end
      # ------------------------------------------------------------------------

      # Builds : Get User Info, Download File, Download File List, Upload File
      # ------------------------------------------------------------------------
      def build_common_request
        header = load_header_template(@template_path)
        body = load_body_template

        common_set_body_contents(body, @ar, @sender_id, @language, @target_id)
        process_header(header,body)
        add_body_to_header(header, body)
      end

      def common_set_body_contents(body, ar, sender_id, lang, receiver_id)
        set_node(body, 'bxd|ApplicationRequest', ar)
        set_node(body, 'bxd|SenderId', @customer_id)
        set_node(body, 'bxd|RequestId', SecureRandom.hex(17))
        set_node(body, 'bxd|Timestamp', Time.now.iso8601)
        set_node(body, 'bxd|Language', lang)
        set_node(body, 'bxd|UserAgent',
                 "Sepa Transfer Library version " + VERSION)
        set_node(body, 'bxd|ReceiverId', receiver_id)
      end
  end
end