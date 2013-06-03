require 'openssl'
require 'base64'
key = "1234567890"
value = "sha1"

kempo = OpenSSL::HMAC.new(key,value)
#puts kempo

File.open("hmac.pem", 'w') { |file| file.write(kempo.to_s) }

%x(openssl req -newkey rsa:1024 -keyout key.pem -out req.der -outform DER -config cer.cnf)

digest = Base64.encode64("kissa")
skartje = OpenSSL::HMAC.digest(value,digest,key)

puts Base64.encode64(skartje)
