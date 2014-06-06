module Sepa
  class Client
    include ActiveModel::Validations
    include Utilities

    attr_accessor :bank, :cert, :command, :content, :customer_id,
                  :encryption_cert_pkcs10, :environment, :file_reference,
                  :file_type, :key_generator_type, :language, :pin, :private_key,
                  :signing_cert_pkcs10, :status, :target_id, :csr, :service, :bank_root_cert_serial

    BANKS = [:nordea, :danske]
    LANGUAGES = ['FI', 'SE', 'EN']
    ENVIRONMENTS = ['PRODUCTION', 'TEST', 'customertest']
    STATUSES = ['NEW', 'DOWNLOADED', 'ALL']

    validates :bank, inclusion: { in: BANKS }
    validates :customer_id, length: { maximum: 16 }, presence: true
    validates :environment, inclusion: { in: ENVIRONMENTS }
    validates :language, inclusion: { in: LANGUAGES }, allow_nil: true
    validates :status, inclusion: { in: STATUSES }, allow_nil: true

    validate :check_file_type
    validate :check_target_id
    validate :check_content
    validate :check_pin
    validate :check_command
    validate :check_wsdl
    validate :check_keys
    validate :check_encryption_cert
    validate :check_signing_cert
    validate :check_bank_root_cert_serial

    def initialize(hash = {})
      self.attributes hash
    end

    def attributes(hash)
      hash.each do |name, value|
        send("#{name}=", value)
      end
    end

    def send_request
      raise ArgumentError unless valid?

      soap = SoapBuilder.new(create_hash).to_xml

      client = Savon.client(wsdl: wsdl, pretty_print_xml: true)
      client.call(command, xml: soap)
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
        return if command == :get_certificate

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
          errors.add(:signing_cert_pkcs10, "Invalid signing certificate request")
        end
      end

      def check_encryption_cert
        return unless command == :create_certificate

        unless cert_request_valid?(encryption_cert_pkcs10)
          errors.add(:encryption_cert_pkcs10, "Invalid encryption certificate request")
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
          if command == :get_bank_certificate || command == :create_certificate
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

        if file_type.nil? || file_type.size > 40
          errors.add(:file_type, "Invalid file type")
        end
      end

      def check_target_id
        return unless command == :upload_file

        if target_id.nil? || target_id.size > 80
          errors.add(:file_type, "Invalid target id")
        end
      end

      def check_content
        return unless command == :upload_file

        errors.add(:content, "Invalid content") if content.nil?
      end

      def check_pin
        return unless command == :create_certificate

        errors.add(:pin, "Invalid pin") if pin.nil?
      end

      def check_bank_root_cert_serial
        return unless command == :get_bank_certificate

        unless bank_root_cert_serial && bank_root_cert_serial.between?(1, 64)
          errors.add(:bank_root_cert_serial, "Invalid bank root certificate serial")
        end
      end

  end
end
