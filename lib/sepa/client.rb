module Sepa
  class Client
    include ActiveModel::Validations

    attr_accessor :bank, :cert, :command, :content, :customer_id,
                  :encryption_cert_pkcs10, :environment, :file_reference,
                  :file_type, :key_generator_type, :language, :pin, :private_key,
                  :signing_cert_pkcs10, :status, :target_id, :csr, :service

    validates :bank, inclusion: {in: [:nordea, :danske]}
    validates :content, presence: true, :if => lambda { command == :upload_file }
    validates :customer_id, length: {maximum: 16}, presence: true
    validates :environment, inclusion: {in: ['PRODUCTION', 'TEST', 'customertest']}
    validates :file_type, length: {maximum: 40}, presence: true, :if => lambda { [:upload_file, :download_file_list].include? command }
    validates :language, inclusion: {in: ['FI', 'SE', 'EN']}, allow_nil: true
    validates :status, inclusion: {in: ['NEW', 'DOWNLOADED', 'ALL']}, allow_nil: true
    validates :target_id, length: {maximum: 80}, presence: true, :if => lambda { command == :upload_file }
    validates :pin, presence: true, :if => lambda { command == :create_certificate }

    validate :check_command
    validate :check_keys, :unless => lambda { command == :get_certificate }
    validate :check_wsdl
    validate :check_encryption_cert, :if => lambda { command == :create_certificate }
    validate :check_signing_cert, :if => lambda { command == :create_certificate }

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
        begin
          OpenSSL::X509::Request.new signing_cert_pkcs10
        rescue
          errors.add(:signing_cert_pkcs10, "Invalid signing certificate request")
        end
      end

      def check_encryption_cert
      begin
        OpenSSL::X509::Request.new encryption_cert_pkcs10
      rescue
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

  end
end
