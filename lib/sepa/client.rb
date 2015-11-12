# Main module for this gem
module Sepa

  # Handles parameter validation, key initialization, {SoapBuilder} initialization, communicating
  # with the bank and {Response} initialization.
  class Client
    include ActiveModel::Validations
    include Utilities
    include ErrorMessages
    include AttributeChecks


    # The bank that is used in this client. One of {BANKS}.
    #
    # @return [Symbol]
    attr_accessor :bank

    # The command that is used with this client. One of {AttributeChecks#allowed_commands}.
    #
    # @return [Symbol]
    attr_accessor :command

    # The payload in base64 encoded form. Used with upload file command.
    #
    # @return [String]
    # @example Dummy payload
    #   'a2lzc2E='
    attr_accessor :content

    # Customer id got from the bank.
    #
    # @return [String]
    # @example Nordea's testing customer id
    #   '11111111'
    attr_accessor :customer_id

    # A file categorization id used by Nordea. Can be retrieved with get_user_info request. Not
    # used with Danske Bank
    #
    # @return [String]
    # @example Nordea's testing target id
    #   '11111111A1'
    attr_accessor :target_id

    # The environment to be used. One of {ENVIRONMENTS}.
    #
    # @return [Symbol]
    attr_accessor :environment

    # File reference number used in download_file requests.
    #
    # @return [String]
    # @example
    #   '11111111A12006030319503000000010'
    attr_accessor :file_reference

    # The file type of the file that is about to be uploaded or downloaded. These vary by bank.
    #
    # @return [String]
    # @example Nordea's electronic bank statement
    #   'TITO'
    attr_accessor :file_type

    # The language to be used in this client. One of {LANGUAGES}.
    #
    # @return [String]
    attr_accessor :language

    # Used to filter files in download_file_list request. One of {STATUSES}.
    #
    # @return [String]
    attr_accessor :status

    # The one-time pin got for bank. Used with certificate requests.
    #
    # @return [String]
    # @example Danske Bank's testing pin
    #   '1234'
    attr_accessor :pin

    # Signing private key which is used to sign the request
    #
    # @return [String]
    # @example Nordea's testing private key
    #   '-----BEGIN RSA PRIVATE KEY-----
    #   MIICXQIBAAKBgQDC0UR8C1sm4bNDDBG6ZmS9iHYGMZhWwAxR6Iq06d7dtlJ6Kx8K
    #   r5NeovWAj0uh/J4BD0j+wObq0vzTKsPmJpJSpWboDvf0yyalb+LJlxV/uazzEA3n
    #   URJSA3pqTBkJT2kfraeAkOPaBSyS1jR+myhWwBF2u84WTR9NJRcpZ3ottwIDAQAB
    #   AoGBAKrfddv+8eI2kE68ZUhCyxVafXqNQXrFU4j8F7z6bBm28rxo2f87ZFzbPc2W
    #   4dWghs2TJIkdlOxeRpbIqa5SIn+HBel8+6wo2gLO4g0bfT44Y1bqjRkdiPlSCJW0
    #   PV1hSd5SRVt7+0yGfCWy559Fzhc/mQQUkhkytc0zYeEwULYxAkEA3uTN7rvZuEcE
    #   sPUehmg8PyBUGYK9KFkr9FiI0cL8FpxZ0l9pW5DQI7pT9HWhrJp+78SKamcT8cHK
    #   1OMBakxeXQJBAN/A52wpt2H6IM8Cxza3toQZhqo1mq4bcarUWq65IJ5jnfFtGdR2
    #   9XUh65YlElUqyDWyuWXRFdeUabu1Qznj8yMCQDzLJUvvGpQDcskdIiVAuuXw2F9Y
    #   5GTj5XQwzaiAyScVn/4cHe1mkw6bnJh5mQ4t2V9mOOaKlMsEs2DbRaCLkdUCQGWF
    #   Gbsqpkiu+0nRgd+itQ30ovQBREAwtX8DwG08E7+phRTwImMS4kWV8VT7VvkLYzFx
    #   +MpodleMv/hpwqm2ci8CQQCUEgwDBEp+FM+2Y5N1KwSGzGBL9LtpnAsqcLG9JxhO
    #   f4Mwz4xhPXMVlvq1wESLPrDUFQpZ4eOZ4XX2MTo4GH39
    #   -----END RSA PRIVATE KEY-----'
    attr_accessor :signing_private_key

    # Own signing certificate in "pem" format. Embedded in the request
    #
    # @return [String]
    # @example Nordea's testing signing certificate
    #   '-----BEGIN CERTIFICATE-----
    #   MIIDwTCCAqmgAwIBAgIEAX1JuTANBgkqhkiG9w0BAQUFADBkMQswCQYDVQQGEwJT
    #   RTEeMBwGA1UEChMVTm9yZGVhIEJhbmsgQUIgKHB1YmwpMR8wHQYDVQQDExZOb3Jk
    #   ZWEgQ29ycG9yYXRlIENBIDAxMRQwEgYDVQQFEws1MTY0MDYtMDEyMDAeFw0xMzA1
    #   MDIxMjI2MzRaFw0xNTA1MDIxMjI2MzRaMEQxCzAJBgNVBAYTAkZJMSAwHgYDVQQD
    #   DBdOb3JkZWEgRGVtbyBDZXJ0aWZpY2F0ZTETMBEGA1UEBRMKNTc4MDg2MDIzODCB
    #   nzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAwtFEfAtbJuGzQwwRumZkvYh2BjGY
    #   VsAMUeiKtOne3bZSeisfCq+TXqL1gI9LofyeAQ9I/sDm6tL80yrD5iaSUqVm6A73
    #   9MsmpW/iyZcVf7ms8xAN51ESUgN6akwZCU9pH62ngJDj2gUsktY0fpsoVsARdrvO
    #   Fk0fTSUXKWd6LbcCAwEAAaOCAR0wggEZMAkGA1UdEwQCMAAwEQYDVR0OBAoECEBw
    #   2cj7+XMAMBMGA1UdIAQMMAowCAYGKoVwRwEDMBMGA1UdIwQMMAqACEALddbbzwun
    #   MDcGCCsGAQUFBwEBBCswKTAnBggrBgEFBQcwAYYbaHR0cDovL29jc3Aubm9yZGVh
    #   LnNlL0NDQTAxMA4GA1UdDwEB/wQEAwIFoDCBhQYDVR0fBH4wfDB6oHigdoZ0bGRh
    #   cCUzQS8vbGRhcC5uYi5zZS9jbiUzRE5vcmRlYStDb3Jwb3JhdGUrQ0ErMDElMkNv
    #   JTNETm9yZGVhK0JhbmsrQUIrJTI4cHVibCUyOSUyQ2MlM0RTRSUzRmNlcnRpZmlj
    #   YXRlcmV2b2NhdGlvbmxpc3QwDQYJKoZIhvcNAQEFBQADggEBACLUPB1Gmq6286/s
    #   ROADo7N+w3eViGJ2fuOTLMy4R0UHOznKZNsuk4zAbS2KycbZsE5py4L8o+IYoaS8
    #   8YHtEeckr2oqHnPpz/0Eg7wItj8Ad+AFWJqzbn6Hu/LQhlnl5JEzXzl3eZj9oiiJ
    #   1q/2CGXvFomY7S4tgpWRmYULtCK6jode0NhgNnAgOI9uy76pSS16aDoiQWUJqQgV
    #   ydowAnqS9h9aQ6gedwbOdtkWmwKMDVXU6aRz9Gvk+JeYJhtpuP3OPNGbbC5L7NVd
    #   no+B6AtwxmG3ozd+mPcMeVuz6kKLAmQyIiBSrRNa5OrTkq/CUzxO9WUgTnm/Sri7
    #   zReR6mU=
    #     -----END CERTIFICATE-----'
    attr_accessor :own_signing_certificate

    # The signing certificate signing request. Used in certificate requests.
    #
    # @return [String]
    # @example
    #   '-----BEGIN CERTIFICATE REQUEST-----
    #   MIIBczCB3QIBADA0MRIwEAYDVQQDEwlEZXZsYWIgT3kxETAPBgNVBAUTCDExMTEx
    #   MTExMQswCQYDVQQGEwJGSTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAo9wU
    #   c2Ys5hSso4nEanbc+RIhL71aS6GBGiWAegXjhlyb6dpwigrZBFPw4u6UZV/Vq7Y7
    #   Ku3uBq5rfZwk+lA+c/B634Eu0zWdI+EYfQxKVRrBrmhiGplKEtglHXbNmmMOn07e
    #   LPUaB0Ipx/6h/UczJGBINdtcuIbYVu0r7ZfyWbUCAwEAAaAAMA0GCSqGSIb3DQEB
    #   BQUAA4GBAIhh2o8mN4Byn+w1jdbhq6lxEXYqdqdh1F6GCajt2lQMUBgYP23I5cS/
    #   Z+SYNhu8vbj52cGQPAwEDN6mm5yLpcXu40wYzgWyfStLXV9d/b4hMy9qLMW00Dzb
    #   jo2ekdSDdw8qxKyxj1piv8oYzMd4fCjCpL+WDZtq7mdLErVZ92gH
    #   -----END CERTIFICATE REQUEST-----'
    attr_accessor :signing_csr

    # Own encryption private key. Used to decrypt the response. In "pem" format.
    #
    # @return [String]
    # @see #signing_private_key The format is the same as in signing private key
    attr_accessor :encryption_private_key

    # Bank's encryption certificate. The request is encrypted with this so that the bank can decrypt
    # the request with their private key. In "pem" format.
    #
    # @return [String]
    # @see #own_signing_certificate The format is the same as in own signing certificate
    attr_accessor :bank_encryption_certificate

    # Encryption certificate signing request. This needs to be generated and is then sent to the
    # bank to be signed.
    #
    # @return [String]
    # @see #signing_csr The format is the same as in signing csr
    attr_accessor :encryption_csr

    # The list of banks that are currently supported by this gem
    BANKS = [:danske, :nordea, :op]

    # Languages that are currently supported by the gem
    LANGUAGES = ['FI', 'SE', 'EN']

    # Environments that are currently supported by the gem
    ENVIRONMENTS = [:production, :test]

    # Statuses that can be given to download file list command. When NEW is given, only those files
    # that have not yet been downloaded will be listed. DOWNLOADED will list only downloaded files
    # and ALL will list every file
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
    validate :check_keys
    validate :check_encryption_certificate
    validate :check_encryption_cert_request
    validate :check_signing_csr
    validate :check_file_reference
    validate :check_encryption_private_key

    # Initializes the class. An optional hash of attributes can be given. Environment is set to
    # production if not given, language to 'EN' and status to 'NEW'.
    #
    # @param hash [Hash] All the attributes of the client can be given to the construcor in a hash
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
      return unless value.respond_to? :downcase

      @environment = value.downcase.to_sym
    end

    # Sets the attributes given in a hash
    #
    # @param hash [Hash] Hash of parameters
    # @example
    #   {
    #     bank: :nordea,
    #     command: :download_file_list
    #   }
    def attributes(hash)
      hash.each do |name, value|
        send("#{name}=", value)
      end
    end

    # Sends request to the bank specified in the attributes. First a new {SoapBuilder} class is
    # initialized with a hash of the parameters given to the client with the {#create_hash} method.
    # After this, a Savon client is initialized with a WSDL file got from {#wsdl}. After this, the
    # Savon client makes the actual call to the server with the {#command} and the constructed
    # {SoapBuilder}. After the call, the xml is extracted from the Savon response and the response
    # is then checked for any Savon::Error errors. After this a {Response} is initialized using
    # the {#initialize_response} method with the xml response and possible errors.
    # @raise [ArgumentError] if some of the parameters are not valid
    # @return [Response]
    def send_request
      raise ArgumentError, errors.messages unless valid?

      soap = SoapBuilder.new(create_hash).to_xml
      client = Savon.client(wsdl: wsdl)

      begin
        error = nil
        response = client.call(command, xml: soap)
        response &&= response.to_xml
      rescue Savon::Error => e
        response = nil
        error = e.http.body
      end

      initialize_response(error, response)
    end

    private

      # Creates a hash of all instance variables and their values. Before the actual hash is
      # created, the {#signing_private_key} is converted to OpenSSL::PKey::RSA using
      # {#initialize_signing_private_key} method.
      #
      # @return [Hash] All instance variables in a hash with their names as symbols as keys
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

      # Converts the {#signing_private_key} from String to OpenSSL::PKey::RSA
      # @return [OpenSSL::PKey::RSA]
      def initialize_signing_private_key
        @signing_private_key = rsa_key(@signing_private_key) if @signing_private_key
      end

      # Returns path to WSDL file according to {#bank} and {#command}
      # @return [String] Path to the WSDL file of the bank and command
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
        when :op
          if %i(
            get_certificate
            get_service_certificates
          ).include? command
            if environment == :test
              file = "wsdl_op_cert_test.xml"
            end
          else
            if environment == :test
              file = "wsdl_op_test.xml"
            end
          end
        else
          raise "WSDL file could not be loaded"
        end

        "#{WSDL_PATH}/#{file}"
      end

      # Initializes {Response} as correct class for a bank. Also converts possible
      # {#encryption_private_key} from String to OpenSSL::PKey::RSA.
      #
      # @param error [String] Possible error got from {#send_request}
      # @param response [String] A soap response in plain xml
      # @return [Response] A {Response} with a correct class for a bank
      def initialize_response(error, response)
        options = {
          response: response,
          error: error,
          command: command
        }
        if encryption_private_key && !encryption_private_key.empty?
          options[:encryption_private_key] = rsa_key(encryption_private_key)
        end

        case bank
        when :nordea
          NordeaResponse.new options
        when :danske
          DanskeResponse.new options
        when :op
          OpResponse.new options
        else
          raise "Cannot process #{bank}'s responses"
        end
      end

  end
end
