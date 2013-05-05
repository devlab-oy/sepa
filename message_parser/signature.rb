class Signature
  # This class contains signature attributes, could be used to add
  # functionality to confirm sender from crendentials
  attr_accessor :digestValue, :signatureValue, :X509Certificate, :X509IssuerName

end