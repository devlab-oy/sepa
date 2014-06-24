module Sepa
  class Client
    include ActiveModel::Validations
    include Utilities
    include ErrorMessages
    include AttributeChecks

    attr_accessor :bank, :cert, :command, :content, :customer_id, :enc_cert,
                  :encryption_cert_pkcs10, :environment, :file_reference,
                  :file_type, :key_generator_type, :language, :pin, :private_key,
                  :signing_cert_pkcs10, :status, :target_id, :csr, :service, :bank_root_cert_serial

    BANKS = [:nordea, :danske]
    LANGUAGES = ['FI', 'SE', 'EN']

    validates :bank, inclusion: { in: BANKS }
    validates :language, inclusion: { in: LANGUAGES }, allow_nil: true

    validate :check_status
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
    validate :check_file_reference

    def initialize(hash = {})
      self.attributes hash
      self.environment ||= 'PRODUCTION'
    end

    def bank=(value)
      @bank = value.to_sym
    end

    def command=(value)
      @command = value.to_sym
    end

    def attributes(hash)
      hash.each do |name, value|
        send("#{name}=", value)
      end
    end

    def send_request
      raise ArgumentError, errors.messages unless valid?

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
        initialize_private_key
        iv = {}

        # Create hash of all instance variables
        instance_variables.map do |name|
          key = name[1..-1].to_sym
          value = instance_variable_get(name)

          iv[key] = value
        end

        iv
      end

      def initialize_private_key
        @private_key = OpenSSL::PKey::RSA.new(@private_key) if @private_key
      end

      # Returns path to WSDL file
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

  end
end
