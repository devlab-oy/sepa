module Sepa
  class SoapBuilder
    # SoapBuilder checks and validates incoming params and creates the
    # SOAP structure.
    def initialize(params)
      @params = params

      # Generate a request ID for the request
      params[:request_id] = generate_request_id

      # Check if the bank & command need keys/certificates/csr's
      #@params = initialize_certificates_and_csr(params)

      @ar = ApplicationRequest.new(params).get_as_base64

      @bank = params.fetch(:bank)
      find_correct_bank_extension(@bank)

      @template_path = File.expand_path('../xml_templates/soap/', __FILE__)
    end

    def to_xml
      # Returns a complete SOAP message in xml format
      find_correct_build(@params).to_xml
    end

    def get_ar_as_base64
      @ar
    end

    private

    def generate_request_id
      SecureRandom.hex(5)
    end

    def find_correct_bank_extension(bank)
      case bank
      when :danske
        self.extend(DanskeSoapRequest)
      when :nordea
        self.extend(NordeaSoapRequest)
      end
    end

    def calculate_digest(doc, node)
      sha1 = OpenSSL::Digest::SHA1.new

      node = doc.at_css(node)

      canon_node = node.canonicalize(
        mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,
        inclusive_namespaces=nil,with_comments=false
      )

      Base64.encode64(sha1.digest(canon_node)).gsub(/\s+/, "")
    end

    def calculate_signature(doc, node, private_key)
      sha1 = OpenSSL::Digest::SHA1.new

      node = doc.at_css(node)

      canon_signed_info_node = node.canonicalize(
        mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,
        with_comments=false
      )

      signature = private_key.sign(sha1, canon_signed_info_node)

      Base64.encode64(signature).gsub(/\s+/, "")
    end

    def load_body_template(command)
      case command
      when :download_file_list
        path = "#{@template_path}/download_file_list.xml"
      when :get_user_info
        path = "#{@template_path}/get_user_info.xml"
      when :upload_file
        path = "#{@template_path}/upload_file.xml"
      when :download_file
        path = "#{@template_path}/download_file.xml"
      when :get_certificate
        path = "#{@template_path}/get_certificate.xml"
      when :get_bank_certificate
        path = "#{@template_path}/danske_get_bank_certificate.xml"
      when :create_certificate
        path = "#{@template_path}/create_certificate.xml"
      end

      body_template = File.open(path)
      body = Nokogiri::XML(body_template)
      body_template.close

      body
    end

    def set_node(doc, node, value)
      doc.at_css(node).content = value
    end

    def add_body_to_header(header, body)
      body = body.at_css('env|Body')
      header.root.add_child(body)
      header
    end

    # def extract_public_key(cert)
    #   pkey = cert.public_key
    #   pkey = OpenSSL::PKey::RSA.new(pkey)

    #   pkey
    # end

    def format_cert(cert)
      cert = cert.to_s
      cert = cert.split('-----BEGIN CERTIFICATE-----')[1]
      cert = cert.split('-----END CERTIFICATE-----')[0]
      cert.gsub!(/\s+/, "")
    end

    def load_header_template(template_path)
      header_template = File.open("#{template_path}/header.xml")
      header = Nokogiri::XML(header_template)
      header_template.close
      header
    end

    def process_header(header, body, private_key, cert)
      set_node(header, 'wsu|Created', Time.now.utc.iso8601)

      set_node(header, 'wsu|Expires', (Time.now.utc + 300).iso8601)

      timestamp_digest = calculate_digest(header,'wsu|Timestamp')
      set_node(header,'dsig|Reference[URI="#dsfg8sdg87dsf678g6dsg6ds7fg"]' \
               ' dsig|DigestValue', timestamp_digest)

      body_digest = calculate_digest(body, 'env|Body')
      set_node(header,'dsig|Reference[URI="#sdf6sa7d86f87s6df786sd87f6s8fsd'\
               'a"] dsig|DigestValue', body_digest)

      signature = calculate_signature(header, 'dsig|SignedInfo', private_key)
      set_node(header, 'dsig|SignatureValue', signature)

      formatted_cert = format_cert(cert)
      set_node(header, 'wsse|BinarySecurityToken', formatted_cert)
    end

    def initialize_certificates_and_csr(params)
      command = params[:command]
      require_private_and_cert = [:get_user_info,:download_file_list,
                                  :download_file,:upload_file]
      require_nothing = [:get_bank_certificate]
      require_pkcs = [:get_certificate]
      require_dual_pkcs_and_cert = [:create_certificate]

      case command
      when *require_private_and_cert
        if params[:cert_path] != nil
          begin
            params[:cert] = OpenSSL::X509::Certificate.new(
              File.read(params.fetch(:cert_path))
            )
          rescue
            fail ArgumentError, 'There is something wrong with the path to ' \
              'the certificate or the certificate itself.'
          end
        elsif params[:cert_plain] != nil
          begin
            params[:cert] = OpenSSL::X509::Certificate.new(
              params.fetch(:cert_plain)
            )
          rescue
            fail ArgumentError, 'There is something wrong with the ' \
              "certificate. Make sure its a proper X509 certificate."
          end
        end
        if params[:enc_cert_path] != nil
          begin
            params[:enc_cert] = OpenSSL::X509::Certificate.new(
              File.read(params.fetch(:enc_cert_path))
            )
          rescue
            fail ArgumentError, 'There is something wrong with the path to ' \
              'the certificate or the certificate itself.'
          end
        elsif params[:enc_cert_plain] != nil
          begin
            params[:enc_cert] = OpenSSL::X509::Certificate.new(
              params.fetch(:enc_cert_plain)
            )
          rescue
            fail ArgumentError, 'There is something wrong with the ' \
              "certificate. Make sure its a proper X509 certificate."
          end
        end
        if params[:private_key_path] != nil
          begin
            params[:private_key] = OpenSSL::PKey::RSA.new(
              File.read(params.fetch(:private_key_path))
            )
          rescue
            fail ArgumentError, 'There is something wrong with the path to ' \
              'the private key or the key itself.'
          end
        elsif params[:private_key_plain] != nil
          begin
            params[:private_key] = OpenSSL::PKey::RSA.new(
              params.fetch(:private_key_plain)
            )
          rescue
            fail ArgumentError, 'There is something wrong with the private ' \
              'key. Make sure its a proper RSA key.'
          end
        end

        check_private_key(params[:private_key])
        check_cert(params[:cert])

      when *require_nothing
      when *require_pkcs
        if params[:csr_path] != nil
          params[:csr] = OpenSSL::X509::Request.new(
            File.read(params.fetch(:csr_path))
          )
        elsif params[:csr_plain] != nil
          params[:csr] = OpenSSL::X509::Request.new(params.fetch(:csr_plain))
        end
      when *require_dual_pkcs_and_cert
        if params[:encryption_cert_pkcs10_path] != nil &&
            params[:signing_cert_pkcs10_path] != nil
          params[:encryption_cert_pkcs10] = OpenSSL::X509::Request.new(
            File.read(params.fetch(:encryption_cert_pkcs10_path))
          )
          params[:signing_cert_pkcs10] = OpenSSL::X509::Request.new(
            File.read(params.fetch(:signing_cert_pkcs10_path))
          )
        elsif params[:encryption_cert_pkcs10_plain] != nil &&
            params[:signing_cert_pkcs10_plain] != nil
          params[:encryption_cert_pkcs10] = OpenSSL::X509::Request.new(
            params.fetch(:encryption_cert_pkcs10_plain)
          )
          params[:signing_cert_pkcs10] = OpenSSL::X509::Request.new(
            params.fetch(:signing_cert_pkcs10_plain)
          )
        end
        if params[:enc_cert_path] != nil
          params[:enc_cert] = OpenSSL::X509::Certificate.new(
            File.read(params.fetch(:enc_cert_path))
          )
        elsif params[:enc_cert] != nil
          params[:enc_cert] = OpenSSL::X509::Certificate.new(
            params.fetch(:enc_cert)
          )
        end

        check_encryption_pkcs10(params[:encryption_cert_pkcs10])
        check_signing_pkcs10(params[:signing_cert_pkcs10])
        check_cert(params[:enc_cert])
      else
        fail ArgumentError, "No matching cases for initialize certificates " \
          "and csr"
      end
      params
    end
  end
end
