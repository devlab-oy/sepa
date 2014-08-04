module Sepa
  module AttributeChecks
    include ErrorMessages

    def allowed_commands
      case bank
      when :nordea
        [:get_certificate, :get_user_info, :download_file_list, :download_file, :upload_file]
      when :danske
        [:get_bank_certificate, :download_file_list, :download_file,
         :upload_file, :create_certificate]
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
        rsa_key signing_private_key
      rescue
        errors.add(:signing_private_key, "Invalid signing private key")
      end

      begin
        x509_certificate signing_certificate
      rescue
        errors.add(:signing_certificate, "Invalid signing certificate")
      end
    end

    def check_signing_csr
      return unless command == :create_certificate

      unless cert_request_valid?(signing_csr)
        errors.add(:signing_csr, SIGNING_CERT_REQUEST_ERROR_MESSAGE)
      end
    end

    def check_encryption_cert_request
      return unless command == :create_certificate

      unless cert_request_valid?(encryption_csr)
        errors.add(:encryption_csr, ENCRYPTION_CERT_REQUEST_ERROR_MESSAGE)
      end
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
      return unless [:upload_file, :download_file_list, :download_file].include? command

      unless file_type && file_type.respond_to?(:size) && file_type.size < 35
        errors.add(:file_type, FILE_TYPE_ERROR_MESSAGE)
      end
    end

    def check_target_id
      return if [:get_user_info,
                 :get_certificate,
                 :create_certificate,
                 :get_bank_certificate].include? command

      # Danske Bank does not use target_id
      return if bank == :danske

      check_presence_and_length(:target_id, 80, TARGET_ID_ERROR_MESSAGE)
    end

    def check_presence_and_length(attribute, length, error_message)
      unless send(attribute) && send(attribute).respond_to?(:size) && send(attribute).size < length
        errors.add(attribute, error_message)
      end
    end

    def check_content
      return unless command == :upload_file

      errors.add(:content, CONTENT_ERROR_MESSAGE) unless content && content.respond_to?(:length)
    end

    def check_pin
      return unless command == :create_certificate

      check_presence_and_length(:pin, 10, PIN_ERROR_MESSAGE)
    end

    def check_environment
      return if command == :get_bank_certificate

      unless Client::ENVIRONMENTS.include? environment
        errors.add(:environment, ENVIRONMENT_ERROR_MESSAGE)
      end
    end

    def check_customer_id
      unless customer_id && customer_id.respond_to?(:length) && customer_id.length.between?(1, 16)
        errors.add(:customer_id, CUSTOMER_ID_ERROR_MESSAGE)
      end
    end

    def check_encryption_certificate
      return unless bank == :danske
      return if command == :get_bank_certificate

      unless encryption_certificate
        return errors.add(:encryption_certificate, ENCRYPTION_CERT_ERROR_MESSAGE)
      end

      x509_certificate encryption_certificate

    rescue
      errors.add(:encryption_certificate, ENCRYPTION_CERT_ERROR_MESSAGE)
    end

    def check_status
      return unless [:download_file_list, :download_file].include? command

      unless status && Client::STATUSES.include?(status)
        errors.add :status, STATUS_ERROR_MESSAGE
      end
    end

    def check_file_reference
      return unless command == :download_file

      unless file_reference && file_reference.length <= 32
        errors.add :file_reference, FILE_REFERENCE_ERROR_MESSAGE
      end
    end

    def check_encryption_private_key
      return unless bank == :danske
      return if [:create_certificate, :get_bank_certificate].include? command

      rsa_key encryption_private_key

    rescue
      errors.add :encryption_private_key, ENCRYPTION_PRIVATE_KEY_ERROR_MESSAGE
    end

  end
end
