module Sepa
  # Contains Nordea specific soap building functionality
  module NordeaSoapRequest
    private

      def set_receiver_id
        set_node(@template, 'bxd|ReceiverId', @target_id)
      end

      def cert_ns
        NORDEA_PKI
      end
  end
end
