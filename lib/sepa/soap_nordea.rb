module Sepa
  module NordeaSoapRequest
  # Holding methods needed only for Danske Services SOAP
    private

      def find_correct_build(params)
        command = params.fetch(:command)

        case command
        when :get_certificate
          build_certificate_request(params)
        when :get_user_info,:download_file_list,:download_file,:upload_file
          build_common_request(params)
        end
      end

      # Builds : Get Certificate
      # ------------------------------------------------------------------------
      def build_certificate_request(params)
        command = params.fetch(:command)
        ar = @ar
        sender_id = params.fetch(:customer_id)

        body = load_body_template(command)
        set_body_contents(body, ar, sender_id)
      end

      def set_body_contents(body, ar, sender_id)
        set_node(body, 'cer|ApplicationRequest', ar)
        set_node(body, 'cer|SenderId', sender_id)
        set_node(body, 'cer|RequestId', SecureRandom.hex(17))
        set_node(body, 'cer|Timestamp', Time.now.iso8601)

        body
      end
      # ------------------------------------------------------------------------

      # Builds : Get User Info, Download File, Download File List, Upload File
      # ------------------------------------------------------------------------
      def build_common_request(params)
        command = params.fetch(:command)
        ar = @ar
        sender_id = params.fetch(:customer_id)
        lang = params.fetch(:language)
        receiver_id = params.fetch(:target_id)
        private_key = params.fetch(:private_key)
        cert = params.fetch(:cert)

        header = load_header_template(@template_path)
        body = load_body_template(command)

        common_set_body_contents(body, ar, sender_id, lang, receiver_id)
        process_header(header,body, private_key, cert)
        add_body_to_header(header, body)
      end

      def common_set_body_contents(body, ar, sender_id, lang, receiver_id)
        set_node(body, 'bxd|ApplicationRequest', ar)
        set_node(body, 'bxd|SenderId', sender_id)
        set_node(body, 'bxd|RequestId', SecureRandom.hex(17))
        set_node(body, 'bxd|Timestamp', Time.now.iso8601)
        set_node(body, 'bxd|Language', lang)
        set_node(body, 'bxd|UserAgent',
                 "Sepa Transfer Library version " + VERSION)
        set_node(body, 'bxd|ReceiverId', receiver_id)
      end
  end
end