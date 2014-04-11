module Sepa
  class Client
    include ActiveModel::Validations

    attr_accessor :bank, :cert_plain, :command, :content, :customer_id,
                  :encryption_cert_pkcs10_plain, :environment, :file_reference,
                  :file_type, :key_generator_type, :language, :pin, :private_key_plain,
                  :signing_cert_pkcs10_plain, :status, :target_id, :csr_plain, :cert_path,
                  :service, :private_key_path

    validates :bank, inclusion: { in: [ :nordea, :danske ] }

    validate :check_command
    validate :check_wsdl

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

      client = Savon.client(wsdl: wsdl, pretty_print_xml: true)
      soap = SoapBuilder.new(bank: bank, command: command).to_xml
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
