module Sepa
  class ApplicationRequest
    include ActiveModel::Validations

    attr_accessor :command, :customer_id, :target_id, :status, :file_type, :content,
                  :file_reference, :command, :private_key, :cert, :environment, :csr,
                  :hmac, :bank_root_cert_serial, :request_id, :pin, :key_generator_type,
                  :encryption_cert_pkcs10, :signing_cert_pkcs10, :request_id, :ar, :bank,
                  :csr_plain, :service, :private_key_plain, :cert_plain, :language,
                  :private_key_path, :enc_cert_path, :cert_path, :enc_cert,
                  :encryption_cert_pkcs10_plain, :signing_cert_pkcs10_plain

    validates :command, inclusion: { in: [ :get_certificate, :download_file_list, :download_file,
                                           :get_user_info, :upload_file, :download_file,
                                           :get_bank_certificate, :create_certificate ] }
    validates :environment, presence: true, :if => lambda { command != :get_bank_certificate }

    validates :private_key, :cert, presence: true, :if => lambda { command != :get_certificate ||
                                                                  command != :create_certificate ||
                                                                  command != :get_bank_certificate }

    validates :pin, :key_generator_type, :encryption_cert_pkcs10, :signing_cert_pkcs10,
              :request_id, :bank_root_serial, :service,
              presence: true, :if => lambda { command == :get_certificate ||
                                             command == :create_certificate ||
                                             command == :get_bank_certificate }

    validates :csr, presence: true, :if => lambda { command == :get_certificate }

    def initialize(hash = {})
      self.attributes hash

      self.hmac = create_hmac_seal(pin,csr)
    end

    def attributes(hash)
      hash.each do |name, value|
        send("#{name}=", value)
      end
    end

    def get_as_base64
      load_template
      set_nodes_contents
      # No signature for Certificate Requests
      if command != :get_certificate && command != :get_bank_certificate &&
          command != :create_certificate
        process_signature
      end

      if command == :create_certificate
        ar
      else
        Base64.encode64(ar.to_xml)
      end
    end

    private

      # Loads the application request template according to the command
      def load_template
        case command

        when :get_certificate
          path = "#{AR_TEMPLATE_PATH}/get_certificate.xml"
        when :download_file_list
          path = "#{AR_TEMPLATE_PATH}/download_file_list.xml"
        when :get_user_info
          path = "#{AR_TEMPLATE_PATH}/get_user_info.xml"
        when :upload_file
          path = "#{AR_TEMPLATE_PATH}/upload_file.xml"
        when :download_file
          path = "#{AR_TEMPLATE_PATH}/download_file.xml"
        when :get_bank_certificate
          path = "#{AR_TEMPLATE_PATH}/danske_get_bank_certificate.xml"
        when :create_certificate
          path = "#{AR_TEMPLATE_PATH}/create_certificate.xml"
        else
          fail ArgumentError
        end

        self.ar = Nokogiri::XML(File.open(path))
      end


      def set_node(node, value)
        ar.at_css(node).content = value
      end

      # Set the nodes' contents according to the command
      def set_nodes_contents
        if command != :get_bank_certificate && command != :create_certificate
          set_node("CustomerId", customer_id)
          set_node("Timestamp", Time.now.utc.iso8601)
          set_node("Environment", environment)
          set_node("SoftwareId", "Sepa Transfer Library version #{VERSION}")
          set_node("Command",
                   command.to_s.split(/[\W_]/).map {|c| c.capitalize}.join)
        end

        case command
        when :create_certificate
          set_node("tns|CustomerId", customer_id)
          set_node("tns|KeyGeneratorType", key_generator_type)
          set_node("tns|EncryptionCertPKCS10", Base64.encode64(
                   encryption_cert_pkcs10.to_der)
                   )
          set_node("tns|SigningCertPKCS10", Base64.encode64(
                   signing_cert_pkcs10.to_der)
                   )
          set_node("tns|Timestamp", Time.now.utc.iso8601)
          set_node("tns|RequestId", request_id)
          set_node("tns|Environment", environment)
          set_node("tns|PIN", pin)
        when :get_certificate
          set_node("Service", service)
          set_node("Content", Base64.encode64(csr.to_der))
          set_node("HMAC", Base64.encode64(hmac).chop)
        when :download_file_list
          set_node("Status", status)
          set_node("TargetId", target_id)
          set_node("FileType", file_type)
        when :download_file
          set_node("Status", status)
          set_node("TargetId", target_id)
          set_node("FileType", file_type)
          set_node("FileReference", file_reference)
        when :upload_file
          set_node("Content", Base64.encode64(content))
          set_node("FileType", file_type)
          set_node("TargetId", target_id)
        when :get_bank_certificate
          set_node("elem|BankRootCertificateSerialNo", bank_root_cert_serial)
          set_node("elem|Timestamp", Time.now.utc.iso8601)
          set_node("elem|RequestId", request_id)
        end
      end

      def create_hmac_seal(pin, csr)
        return "" if pin.nil? || csr.nil?
        OpenSSL::HMAC.digest('sha1',pin,csr.to_der)
      end

      def remove_node(doc, node, xmlns)
        doc.at_css("xmlns|#{node}", 'xmlns' => xmlns).remove
      end

      def add_node_to_root(doc, node)
        doc.root.add_child(node)
      end

      def calculate_digest(doc)
        sha1 = OpenSSL::Digest::SHA1.new
        Base64.encode64(sha1.digest(doc.canonicalize))
      end

      def add_value_to_signature(node, value)
        node = ar.at_css("dsig|#{node}",
                          'dsig' => 'http://www.w3.org/2000/09/xmldsig#')
        node.content = value
      end

      def calculate_signature(private_key)
        sha1 = OpenSSL::Digest::SHA1.new
        node = ar.at_css("dsig|SignedInfo",
                          'dsig' => 'http://www.w3.org/2000/09/xmldsig#')
        signature = private_key.sign(sha1, node.canonicalize)
        Base64.encode64(signature)
      end

      def format_cert(cert)
        cert = cert.to_s
        cert = cert.split('-----BEGIN CERTIFICATE-----')[1]
        cert = cert.split('-----END CERTIFICATE-----')[0]
        cert.gsub!(/\s+/, "")
      end

      def process_signature
        signature_node = remove_node(ar,
                                     'Signature',
                                     'http://www.w3.org/2000/09/xmldsig#')
        digest = calculate_digest(ar)
        add_node_to_root(ar, signature_node)
        add_value_to_signature('DigestValue', digest)
        signature = calculate_signature(private_key)
        add_value_to_signature('SignatureValue', signature)
        add_value_to_signature('X509Certificate',format_cert(cert))
      end
    end
end
