module Sepa
   class CertRequest
    def initialize(params)
      @command = params.fetch(:command)
      @customer_id = params.fetch(:customer_id)
      @ar = ApplicationRequest.new(params)
    end

    def to_xml
      process
    end

    private

      def load_body
        # Selecting which soap request template to load
        case @command
        when :get_certificate
          path = File.expand_path('../xml_templates/soap/get_certificate.xml', __FILE__)
        else
          puts 'Could not load soap request template because command was unrecognised.'
          return nil
        end

        f = File.open(path)
        soap = Nokogiri::XML(f)
        f.close

        soap
      end

      def process
        soap = load_body

        #Add the base64 coded application request to the soap envelope
        ar_node = soap.xpath("//cer:ApplicationRequest", 'cer' => 'http://bxd.fi/CertificateService').first
        ar_node.content = @ar.get_as_base64

        # Set the customer id
        sender_id_node = soap.xpath("//cer:SenderId", 'cer' => 'http://bxd.fi/CertificateService').first
        sender_id_node.content = @customer_id

        # Set the request id, a random 35 digit hex number
        request_id_node = soap.xpath("//cer:RequestId", 'cer' => 'http://bxd.fi/CertificateService').first
        request_id_node.content = SecureRandom.hex(35)

        # Add timestamp
        timestamp_node = soap.xpath("//cer:Timestamp", 'cer' => 'http://bxd.fi/CertificateService').first
        timestamp_node.content = Time.now.iso8601

        soap.to_xml
      end

  end
end