require 'openssl'
require 'base64'
key = "1234567890"
value = "sha1"

kempo = OpenSSL::HMAC.new(key,value)
#puts kempo

File.open("hmac.pem", 'w') { |file| file.write(kempo.to_s) }

%x(openssl req -newkey rsa:1024 -keyout key.pem -out req.der -outform DER -config cer.cnf)

#digest = Base64.encode64("kissa")
digest = Base64.decode64("MIIDCTCCAnICAQAwOjEXMBUGA1UEAxMOUGV0cmkgVC4gTHVvdG8xEjAQBgNVBAUT
CTY3OTE1NTMzMDELMAkGA1UEBhMCRkkwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJ
AoGBAJo41eSLt4P7FBwXZtFBNEks55y1sl2zdfRHqTH1QsfZvs5lKbkhIKRXWb6y
Ifnw5pktY6nYYM+Jd6SwbZbtvuUTIHTtNxlGSkfvGOXndlczky3e7qRRFfKy9LFS
WIAH7baVr/lDsTPxWXOOFxrTiyfWtTye0lrjvyRqWaBvBKdLAgMBAAGgggGNMBoG
CisGAQQBgjcNAgMxDBYKNS4xLjI2MDAuMjB7BgorBgEEAYI3AgEOMW0wazAOBgNV
HQ8BAf8EBAMCBPAwRAYJKoZIhvcNAQkPBDcwNTAOBggqhkiG9w0DAgICAIAwDgYI
KoZIhvcNAwQCAgCAMAcGBSsOAwIHMAoGCCqGSIb3DQMHMBMGA1UdJQQMMAoGCCsG
AQUFBwMCMIHxBgorBgEEAYI3DQICMYHiMIHfAgEBHk4ATQBpAGMAcgBvAHMAbwBm
AHQAIABTAHQAcgBvAG4AZwAgAEMAcgB5AHAAdABvAGcAcgBhAHAAaABpAGMAIABQ
AHIAbwB2AGkAZABlAHIDgYkAbII1TrHis4afw+wbLrZIOYe1boagX3QNyHNj4kpk
tRyBgIFt6WofQ1nXK6TXmpAm2/AmY20/h+a1GZ1/vn7EEzHcNQfjvHoSZH7yU5Fz
vBVs5PGGZ//dlrlYX0iY8qhQicTdPQT3MRoYjUKBvi7IRJnfbWbpQKIZSweblEKN
1IYAAAAAAAAAADANBgkqhkiG9w0BAQUFAAOBgQBSO7NiaLLu7vB3ZEMV7qjnBhPP
7P7OjDsBG7G+4XFeqiRkpOPHDj9mb9PKp7SptH4rtv6bZZ4R3xnLWO74ZqIZuy3d
GmwtTeBavOJLLRkdYZhVsBkRX4sAHTt0190G80jbl+5NJRpb/ii0e2Sm0x7gIu66
qu8t+G80raOpKwI8CA==")
skartje = OpenSSL::HMAC.digest(value,digest,key)
puts skartje
puts Base64.encode64(skartje)

%x(openssl asn1parse -inform DER -in req.der)

