module Sepa
  class Client
    def initialize(params)
      # Initialize savon client with params and construct soap message
      wsdl = params.fetch(:wsdl)
      @client = Savon.client(wsdl: wsdl)
      @command = params.fetch(:command)
      if @command == :get_certificate
        @soap = CertRequest.new(params).to_xml
      else
        @soap = SoapRequest.new(params).to_xml
      end
    end

    # Call savon to make the actual request to the server
    def send
      @client.call(@command, xml: @soap)
    end
  end
end