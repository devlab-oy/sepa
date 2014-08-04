require 'test_helper'

# Tests Danske Bank specific response stuff
class DanskeResponseTest < ActiveSupport::TestCase
  setup do

    # The private key of the certificate used to encrypt
    # the response which can be used to decrypt it
    encryption_private_key = '-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAw3hHNCubtBxxztGaLU85WujGCWyE1RYdixlng/L+XwulaWum
XFstMCXQkGDIJyRqNXN9w+Dc9v62BbgR1t4GdqDXNSTBKYpxreXHOSC4DyAzUwsJ
yZDKERCzueVCkgQl3ShcK1TPnQ+FWT+yzyIXQV9ZlY4bc1WaF9HlBJ/2lbBcqSKr
Mq1AADMHOeS0cQatbaGd2QwzH+o1yVHHn1XuPM3Qm3xLKDMbj1gR7+AqhUlfNwbk
kkea6pSxaD8Wm3wvfPz6QqG09DrPLVzUr/H3Gh7JO0c9xrwfesjFyRp7Hon3BMZY
t6COjJqYUSAb12eSqBffs6O2OrPzbyh496Cx6QIDAQABAoIBAG+zbSUwAmNTmemx
N6TK0CDWQk0iWWoXoDxcAR6THq+bzSPII6JFbDZGdb/7voU3twXigK0N89elyMjN
3kvmRtVFppW08jlV5w6T71wDCYuDQDElbqtj9UT5QWtqyrb8bdLK/Ji6d4XuV6qf
zwO1HIr7/QqM0bz/3vXbuT8CVnxE8mviQaLBLAN8h7qZRq2Z39vpoImaNp9APRh1
/oSYkKdiELcH0+JkVhxZqi2op7R0MxcsvT4M91Vs+fqO8PADLf72fHKUDb4D+Nkx
S+YF8Xe3RxpYTHrTgEBl08WXmqhc/Bbk+lKJoLuIkb3bUHW3RNrOSJ8uuJqKRczg
FHTw+DECgYEA9gQjdr1nxPolDl3+reXo02Ig5Ah2pe7uuTrgmqnMJ/EKJSiLgedM
ulI+wp7270dXIJC0nOawDtd6hNFpAQvNkCnWmQCsV3lM9w9EPWRsZzBiSUsejYdz
VGBprpxjf8hL7ASDoOnAW/JBhFoVuyOYeR5rrghY5mPw++lNPXlzuB0CgYEAy2cD
jj5cw6I7Caj1qdxCGseNvNyk1ZrAIzQaKlnJ20uWqdlLCYGzK8JTgubwnkL/mQcE
2axbLCsiU4cn7GeJLUkZKfUMNuEMTDgVgey7yt2VmX++qaZmRJfBnGCKKnfzfafE
OUfUfIdgimOKpwUdCsy6mbznvPiLQSJptFparz0CgYEAkd3+UQcYofhXRF+DBATP
uZXzPoGuJ9C1hupcBhgrTntisomJviowmkDtqWOrslAwXsSt8mHtfb9Ri7LGebJP
3eyQqwN1LCBl/A73PRdwFvbfL+n0YaIwRZUs1DUx4bAXJAfBLAWs4lePdTQcsmr2
msnourWEUIZtek/oVkzOyhkCgYB+tWuXnu22yUcx21k+OYHMoOeA8YqVrlNnGrv6
CfkfbVUr9bsy7uMorWPMtgTK8j27nI2+9AnP2AcINbf/Ivhnh5PveUHkpgk9Kers
BwdtduAMwXGKyagHrunjephXoGXEr1AjxsVt1f+j9iKXrS3MXoEX6IAMTmChcMic
m3TGmQKBgQCm8Qkb5KVF7EexYhpoaGVcrTtX+K/M3OsSga3vdvQSZ+OFcpN8BfnP
2a3h/ocFwRLzZcsDSpyJplDSZO71/5TSs6g/rQNqH3G9UL3//x7yr2I8e7taE+Qk
l+Ul4l4+FfAysq3a7b3xoQ59kN1CrEWqDo2KqndxGv6wQft3n/dxnQ==
-----END RSA PRIVATE KEY-----'

    options = {
      response: File.read("#{DANSKE_TEST_RESPONSE_PATH}/download_file_list.xml"),
      command: :download_file_list,
      encryption_private_key: rsa_key(encryption_private_key)
    }
    @download_file_list_response = Sepa::DanskeResponse.new options
  end

  test 'application response can be extracted' do
    application_response = @download_file_list_response.application_response
    assert_equal '061133', xml_doc(application_response).at('CustomerId').content
  end

  test 'certificate used to sign the response can be extracted from the response' do
    certificate = @download_file_list_response.certificate

    assert_nothing_raised do
      x509_certificate certificate
    end
  end

  test 'proper error message is returned if wrong encryption private key is given' do
    wrong_encryption_private_key = '-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAuzOFRV7RWJXwga+2tyj+2vJvfr2CNBypJGuSlIvuHhnEF1Lx
mIIx+G/jUMI6mPBmW4Y8jKEPLBCWNeuSpGC8CUzahLEzmUj3RbYh43Jx1V6R632h
8CpgS8pxkyzgvaCvyv2kkX+n87sMUzhoNQFoc8pTTcpGVrnNIF7TtBSO7oWY+OJZ
A8HEZH2t++d0ZN02B7MtfeFsW5M83IjTUAJy6+P0mNmW4X4Xpbdx+PzkyuuVvPlP
NxBX2iPpvSY3SZy2fTgcasDaQMoMtCBL4nNL5A39JNOUeDt3PCa0pUXqA9HmzElb
Ps0Q7XgMitPZTk1BkSgAGzGqId6FwXSpeOYAQQIDAQABAoIBAEa5mEg1InKNc2gL
ssRQQLkHjwgbIO3/Rgf0fFSS6UuGAIevVod/6NErtH32Y50UdhduB8I5tzm2qomE
jsp7oY8B8izfpdbrskAsJ3F+83LhX8/QjzXlTKxVt8Ma2W3LH59ZZKtzx0hWCroG
PZiJB6V3czGYkiqB1/W63dDTU4zZVd02SCwlhGUEuncAnfpty+JpROpzRAcgquTF
VEIoK2tDieas4uAgpmE5cjKxuyOSY26HV5GlUDkmb+cUiE3J/3gjHUlvAV48qMY4
EePA+0n3JA/dhVOF5SUbp/txEMhHI8G1loCDC47xNkyQ48mUdjokgajpM0ODmKxj
JnFkcGECgYEA96ZDmyxUE+dfcl7vM8wcZSp3akuYOXWpxA3JPTX1LeY5/jVUnAF6
iA/Dzf1iR4dzsrtSiRc8Qeh0fJs8ObhX5H4loWemptT9KSj84a2zeMuxC6LyMXFx
8qhA166V/kRMdpR3WgCrO3+kJLFhu/jnqT27wWDHSmR5Nithk14ovCMCgYEAwYN2
EsOEraZ2qNcAzZe4ujLKCaFeeNl00v4O+y8D8q+m7mzg8SVKtdzsFAR/F8p7s689
VUrKDti4Lt/cwzrkPRbIzxXVhOxGkkneQ8mFr77sji2UFAYXl9GtURp91dCk0/Zh
LkJAeoF24YDeDYJ5M0ODcsgy/sAN6+p8b05StksCgYBf2jSUnOW2BnnE9MW00K20
4mjx9Wxn4QjiX0uiq33IVDHiGJY1A8V/YEqzMf2WHfFEHojlkt65y9U6XYND+/vY
7pJ2FH5GWG3cPocSen7apExUaq8/P9+QwlrGoEZh8eF+jBxd86BTGSZZJWbksIRJ
1yESyfiY7KaVtti/h1RQ7QKBgHXon/z23NTh5NMjjf23QHtTjv8nL+T6utAEtSQf
lYw9srz74mOMkWUWY1IfG0Fnws/NKtXZaBx7uF33URAzxfXi+CAV8a+4N5fTInaz
R525+3D2HI/G1oFO5QfR2HJ7WrM8ICKLg7YhREpKtwIMScUOkf1SNqA6bUEd8wvu
8T7ZAoGAOPLMNVJv07zJsaiktjYODcVOenINp+LoUJphblWCliXWvaHpDdpAiqKq
aimQ9Emu6u+JHCvRdHGGnAUEQKRCjUL+oAQhJfWimlhSfqbS0uQAo9XakIZGRyhO
ufGDBuk6Qe7BSx+/iYvjK1o/IP42RSwj7Ar/IaQuzzfxsflqrGA=
-----END RSA PRIVATE KEY-----'

    options = {
      response: File.read("#{DANSKE_TEST_RESPONSE_PATH}/download_file_list.xml"),
      command: :download_file_list,
      encryption_private_key: rsa_key(wrong_encryption_private_key)
    }
    response = Sepa::DanskeResponse.new options

    refute response.valid?
    refute_empty response.errors.messages
  end
end
