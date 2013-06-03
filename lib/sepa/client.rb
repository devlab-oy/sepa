module Sepa
  class Client
    def initialize(params)
      # Initialize savon client with params
      @client = Savon.client(wsdl: params.fetch(:wsdl), pretty_print_xml: true)
      @soap = SoapRequest.new(params).to_xml
      @command = params.fetch(:command)
    end

    # Call savon to make the actual request to the server
    def send
      @client.call(@command, xml: @soap)
    end

    def ar_to_xml
      hash_key = (@command.to_s + "out").to_sym
      response = @client.call(@command, xml: @soap)
      ar = response.body[hash_key][:application_response]
      Base64.decode64(ar)
    end
  end
end