module Sepa
  class Client
    include ActiveModel::Validations
    include Utilities
    include ErrorMessages

    attr_accessor :bank, :cert, :command, :content, :customer_id, :enc_cert,
                  :encryption_cert_pkcs10, :environment, :file_reference,
                  :file_type, :key_generator_type, :language, :pin, :private_key,
                  :signing_cert_pkcs10, :status, :target_id, :csr, :service, :bank_root_cert_serial

    BANKS = [:nordea, :danske]
    LANGUAGES = ['FI', 'SE', 'EN']
    STATUSES = ['NEW', 'DOWNLOADED', 'ALL']

    validates :bank, inclusion: { in: BANKS }
    validates :language, inclusion: { in: LANGUAGES }, allow_nil: true
    validates :status, inclusion: { in: STATUSES }, allow_nil: true

    validate :check_customer_id
    validate :check_file_type
    validate :check_environment
    validate :check_target_id
    validate :check_content
    validate :check_pin
    validate :check_command
    validate :check_wsdl
    validate :check_keys
    validate :check_enc_cert
    validate :check_encryption_cert_request
    validate :check_signing_cert
    validate :check_bank_root_cert_serial

    def initialize(hash = {})
      self.attributes hash
      self.environment ||= 'PRODUCTION'
    end

    def attributes(hash)
      hash.each do |name, value|
        send("#{name}=", value)
      end
    end

    def send_request
      raise ArgumentError unless valid?

      soap = SoapBuilder.new(create_hash).to_xml

      client = Savon.client(wsdl: wsdl)

      response = client.call(command, xml: soap).doc

      case bank
        when :nordea
          NordeaResponse.new response, command: command
        when :danske
          DanskeResponse.new response, command: command
      end
    end

    private

      def create_hash
        # Create hash of all instance variables
        iv = instance_variables.map do |name|
          [ name[1..-1].to_sym, instance_variable_get(name) ]
        end

        iv.to_h
      end

      def allowed_commands
        case bank
        when :nordea
          [ :get_certificate, :get_user_info, :download_file_list, :download_file, :upload_file ]
        when :danske
          [ :get_bank_certificate, :get_user_info, :download_file_list, :download_file,
            :upload_file, :create_certificate ]
        else
          []
        end
      end

      def check_command
        errors.add(:command, "Invalid command") unless allowed_commands.include? command
      end

      def check_keys
        return if [:get_certificate, :get_bank_certificate, :create_certificate].include? command

        begin
          OpenSSL::PKey::RSA.new private_key
        rescue
          errors.add(:private_key, "Invalid private key")
        end

        begin
          OpenSSL::X509::Certificate.new cert
        rescue
          errors.add(:cert, "Invalid certificate")
        end
      end

      def check_signing_cert
        return unless command == :create_certificate

        unless cert_request_valid?(signing_cert_pkcs10)
          errors.add(:signing_cert_pkcs10, SIGNING_CERT_REQUEST_ERROR_MESSAGE)
        end
      end

      def check_encryption_cert_request
        return unless command == :create_certificate

        unless cert_request_valid?(encryption_cert_pkcs10)
          errors.add(:encryption_cert_pkcs10, ENCRYPTION_CERT_REQUEST_ERROR_MESSAGE)
        end
      end

      def wsdl
        case bank
        when :nordea
          if command == :get_certificate
            file = "wsdl_nordea_cert.xml"
          else
            file = "wsdl_nordea.xml"
          end
        when :danske
          if [:get_bank_certificate, :create_certificate].include? command
            file = "wsdl_danske_cert.xml"
          else
            file = "wsdl_danske.xml"
          end
        else
          return nil
        end

        "#{WSDL_PATH}/#{file}"
      end

      def check_wsdl
        return unless wsdl.present?

        xsd = Nokogiri::XML::Schema(File.read(SCHEMA_FILE))
        wsdl_file = File.read(wsdl)
        xml = Nokogiri::XML(wsdl_file)

        unless xsd.valid?(xml)
          errors.add(:wsdl, "Invalid wsdl file")
        end
      end

      def check_file_type
        return unless [:upload_file, :download_file_list].include? command

        if file_type.nil? || file_type.size > 35
          errors.add(:file_type, FILE_TYPE_ERROR_MESSAGE)
        end
      end

      def check_target_id
        return unless command == :upload_file

        check_presence_and_length(:target_id, 80, TARGET_ID_ERROR_MESSAGE)
      end

      def check_presence_and_length(attribute, length, error_message)
        if send(attribute).nil? || send(attribute).size > length
          errors.add(attribute, error_message)
        end
      end

      def check_content
        return unless command == :upload_file

        errors.add(:content, CONTENT_ERROR_MESSAGE) if content.nil?
      end

      def check_pin
        return unless command == :create_certificate

        check_presence_and_length(:pin, 10, PIN_ERROR_MESSAGE)
      end

      def check_bank_root_cert_serial
        return unless command == :get_bank_certificate

        unless bank_root_cert_serial && bank_root_cert_serial.length.between?(1, 64)
          errors.add(:bank_root_cert_serial, "Invalid bank root certificate serial")
        end
      end

      def check_environment
        return if command == :get_bank_certificate

        environments = ['PRODUCTION', 'TEST', 'customertest']

        unless environments.include? environment
          errors.add(:environment, ENVIRONMENT_ERROR_MESSAGE )
        end
      end

      def check_customer_id
        return if command == :get_bank_certificate

        unless customer_id && customer_id.length.between?(1, 16)
          errors.add(:customer_id, CUSTOMER_ID_ERROR_MESSAGE)
        end
      end

      def check_enc_cert
        return unless command == :create_certificate

        errors.add(:enc_cert, ENCRYPTION_CERT_ERROR_MESSAGE) unless enc_cert
      end

  end
end
