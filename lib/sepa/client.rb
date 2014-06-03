module Sepa
  class Client
    include ActiveModel::Validations

    attr_accessor :bank, :cert, :command, :content, :customer_id,
                  :encryption_cert_pkcs10, :environment, :file_reference,
                  :file_type, :key_generator_type, :language, :pin, :private_key,
                  :signing_cert_pkcs10, :status, :target_id, :csr, :service

    validates :bank, inclusion: { in: [ :nordea, :danske ] }
    validates :content, presence: true, :if => lambda { command == :upload_file }
    validates :customer_id, length: { maximum: 16 }, presence: true
    validates :environment, inclusion: { in: ['PRODUCTION', 'TEST', 'customertest'] }
    validates :file_type, length: { maximum: 40 }, presence: true
    validates :language, inclusion: { in: ['FI', 'SE', 'EN'] }
    validates :status, inclusion: { in: ['NEW', 'DOWNLOADED', 'ALL'] }
    validates :target_id, length: { maximum: 80 }, presence: true

    validate :check_command
    validate :check_keys
    validate :check_wsdl

    def initialize(hash = {})
      self.attributes hash
      @hash = hash
    end

    def attributes(hash)
      hash.each do |name, value|
        send("#{name}=", value)
      end
    end

    def send_request
      # raise ArgumentError unless valid?
      soap = SoapBuilder.new(@hash).to_xml

      client = Savon.client(wsdl: wsdl, pretty_print_xml: true)
      client.call(command, xml: soap)
    end

    private

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
