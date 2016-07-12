module Sepa
  # Contains functionality to check the attributes passed to {Client}. Uses
  # ActiveModel::Validations for the actual validation.
  module AttributeChecks
    include ErrorMessages

    # Commands which are allowed for a specific bank
    #
    # @return [Array<Symbol>] the commands which are allowed for {Client#bank}.
    def allowed_commands
      case bank
      when :nordea
        [
          STANDARD_COMMANDS,
          :get_certificate,
          :renew_certificate
        ].flatten
      when :danske
        [
          STANDARD_COMMANDS - [:get_user_info],
          :create_certificate,
          :get_bank_certificate,
          :renew_certificate,
        ].flatten
      when :op
        [
          STANDARD_COMMANDS - [:get_user_info],
          :get_certificate,
          :get_service_certificates,
        ].flatten
      else
        []
      end
    end

    # Checks that {Client#command} is included in {#allowed_commands}
    def check_command
      errors.add(:command, "Invalid command") unless allowed_commands.include? command
    end

    # Checks that signing keys and certificates can be initialized properly.
    def check_keys
      return if %i(
        create_certificate
        get_bank_certificate
        get_certificate
        get_service_certificates
      ).include? command

      begin
        rsa_key signing_private_key
      rescue
        errors.add(:signing_private_key, "Invalid signing private key")
      end

      begin
        x509_certificate own_signing_certificate
      rescue
        errors.add(:own_signing_certificate, "Invalid signing certificate")
      end
    end

    # Checks that signing certificate signing request can be initialized properly.
    def check_signing_csr
      return unless [:get_certificate, :create_certificate, :renew_certificate].include? command
      return if cert_request_valid?(signing_csr)

      errors.add(:signing_csr, SIGNING_CERT_REQUEST_ERROR_MESSAGE)
    end

    # Checks that encryption certificate signing request can be initialized properly.
    def check_encryption_cert_request
      return unless [:create_certificate, :renew_certificate].include? command
      return if cert_request_valid?(encryption_csr)

      errors.add(:encryption_csr, ENCRYPTION_CERT_REQUEST_ERROR_MESSAGE)
    end

    # Checks that {Client#file_type} is proper
    def check_file_type
      if file_type.present?
        valid = file_type.size < 35
      else
        return if bank == :op && %i(download_file
                                  download_file_list).include?(command)

        valid = !(%i(
          download_file
          download_file_list
          upload_file
        ).include? command)
      end

      errors.add(:file_type, FILE_TYPE_ERROR_MESSAGE) unless valid
    end

    # Checks that {Client#target_id} is valid.
    def check_target_id
      return if %i(
          create_certificate
          get_bank_certificate
          get_certificate
          renew_certificate
          get_user_info
        ).include?(command) ||
        %i(
          danske
          op
        ).include?(bank)

      check_presence_and_length(:target_id, 80, TARGET_ID_ERROR_MESSAGE)
    end

    # Checks presence and length of an attribute
    #
    # @param attribute [Symbol] the attribute to validate
    # @param length [Integer] the maximum length of the attribute
    # @param error_message [#to_s] the error message to display if the validation fails
    def check_presence_and_length(attribute, length, error_message)
      check = true
      check &&= send(attribute)
      check &&= send(attribute).respond_to? :size
      check &&= send(attribute).size < length
      check &&= send(attribute).size > 0

      errors.add(attribute, error_message) unless check
    end

    # Checks that the content (payload) of the request is somewhat correct. This validation is only
    # run when {Client#command} is `:upload_file`.
    def check_content
      return unless command == :upload_file

      check = true
      check &&= content
      check &&= content.respond_to? :length
      check &&= content.length > 0

      errors.add(:content, CONTENT_ERROR_MESSAGE) unless check
    end

    # Checks that the {Client#pin} used in certificate requests in valid
    def check_pin
      return unless [:create_certificate, :get_certificate].include? command

      check_presence_and_length(:pin, 20, PIN_ERROR_MESSAGE)
    end

    # Checks that {Client#environment} is included in {Client::ENVIRONMENTS}. Not run if
    # {Client#command} is `:get_bank_certificate`.
    def check_environment
      return if command == :get_bank_certificate

      unless Client::ENVIRONMENTS.include? environment
        errors.add(:environment, ENVIRONMENT_ERROR_MESSAGE)
      end
    end

    # Checks that {Client#customer_id} is valid
    def check_customer_id
      unless customer_id && customer_id.respond_to?(:length) && customer_id.length.between?(1, 16)
        errors.add(:customer_id, CUSTOMER_ID_ERROR_MESSAGE)
      end
    end

    # Checks that {Client#bank_encryption_certificate} can be initialized properly. Only run if
    # {Client#bank} is `:danske` and {Client#command} is not `:get_bank_certificate`.
    def check_encryption_certificate
      return unless bank == :danske
      return if command == :get_bank_certificate

      unless bank_encryption_certificate
        return errors.add(:bank_encryption_certificate, ENCRYPTION_CERT_ERROR_MESSAGE)
      end

      x509_certificate bank_encryption_certificate

    rescue
      errors.add(:bank_encryption_certificate, ENCRYPTION_CERT_ERROR_MESSAGE)
    end

    # Checks that {Client#status} is included in {Client::STATUSES}.
    def check_status
      return unless [:download_file_list, :download_file].include? command

      unless status && Client::STATUSES.include?(status)
        errors.add :status, STATUS_ERROR_MESSAGE
      end
    end

    # Checks presence and length of {Client#file_reference} if {Client#command} is `:download_file`
    def check_file_reference
      return unless command == :download_file

      check_presence_and_length :file_reference, 33, FILE_REFERENCE_ERROR_MESSAGE
    end

    # Checks that {Client#encryption_private_key} can be initialized properly. Is only run if
    # {Client#bank} is `:danske` and {Client#command} is not `:create_certificate` or
    # `:get_bank_certificate`.
    def check_encryption_private_key
      return unless bank == :danske
      return if [:create_certificate, :get_bank_certificate].include? command

      rsa_key encryption_private_key

    rescue
      errors.add :encryption_private_key, ENCRYPTION_PRIVATE_KEY_ERROR_MESSAGE
    end

  end
end
