module Sepa
  # Contains Samlink specific soap building functionality
  module SamlinkSoapRequest
    private

      def set_receiver_id
        set_node @template, 'bxd|ReceiverId', @target_id
      end

      def cert_ns
        SAMLINK_PKI
      end
  end
end
