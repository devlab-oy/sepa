module Sepa
  module DanskeSoapRequest
    # Holding methods needed only for Danske Services SOAP
    private

      def find_correct_build(params)
        command = params.fetch(:command)

        case command
        when :get_bank_certificate
          build_get_bank_certificate_request(params)
        end
      end

      # Builds : Get Bank Certificate
      # ------------------------------------------------------------------------
      def build_get_bank_certificate_request(params)
        ar = Base64.decode64 @ar
        command = params.fetch(:command)
        sender_id = params.fetch(:customer_id)
        request_id = params.fetch(:request_id)

        body = load_body_template(command)

        set_bank_certificate_body_contents(body, sender_id, request_id)
        add_bank_certificate_body_to_soap(ar, body)
      end

      def set_bank_certificate_body_contents(body, sender_id, request_id)
        set_node(body, 'pkif|SenderId', sender_id)
        set_node(body, 'pkif|CustomerId', sender_id)
        set_node(body, 'pkif|RequestId', request_id)
        set_node(body, 'pkif|Timestamp', Time.now.iso8601)
        set_node(body, 'pkif|InterfaceVersion', 1)
      end

      def add_bank_certificate_body_to_soap(ar, body)
        ar = Nokogiri::XML(ar)

        ar = ar.at_css('elem|GetBankCertificateRequest')
        body.at_css('pkif|GetBankCertificateIn').add_child(ar)

        body
      end
      # ------------------------------------------------------------------------
  end
end