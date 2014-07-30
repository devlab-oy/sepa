module Sepa
  class Client
    include ActiveModel::Validations
    include Utilities
    include ErrorMessages
    include AttributeChecks

    attr_accessor :bank,
                  :command,
                  :content,
                  :customer_id,
                  :target_id,
                  :environment,
                  :file_reference,
                  :file_type,
                  :language,
                  :status,
                  :pin,
                  :signing_private_key,
                  :signing_certificate,
                  :signing_csr,
                  :encryption_private_key,
                  :encryption_certificate,
                  :encryption_csr

    BANKS = [:nordea, :danske]
    LANGUAGES = ['FI', 'SE', 'EN']
    ENVIRONMENTS = [:production, :test]
    STATUSES = ['NEW', 'DOWNLOADED', 'ALL']

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
    validate :check_encryption_certificate
    validate :check_encryption_cert_request
    validate :check_signing_csr
    validate :check_file_reference

    def initialize(hash = {})
      self.attributes hash
      self.environment ||= :production
      self.language ||= 'EN'
      self.status ||= 'NEW'
    end

    def bank=(value)
      @bank = value.to_sym
    end

    def command=(value)
      @command = value.to_sym
    end

    def environment=(value)
      @environment = value.downcase.to_sym
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

      begin
        response = client.call(command, xml: soap)
        response &&= response.to_xml
      rescue Savon::Error => e
        response = nil
        error = e.to_s
      end

      options = {
        response: response,
        error: error,
        command: command
      }
      options[:encryption_private_key] = encryption_private_key if encryption_private_key

      case bank
      when :nordea
        NordeaResponse.new options
      when :danske
        DanskeResponse.new options
      end
    end

    private

      def create_hash
        initialize_signing_private_key
        iv = {}

        # Create hash of all instance variables
        instance_variables.map do |name|
          key = name[1..-1].to_sym
          value = instance_variable_get(name)

          iv[key] = value
        end

        iv
      end

      def initialize_signing_private_key
        @signing_private_key = rsa_key(@signing_private_key) if @signing_private_key
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
