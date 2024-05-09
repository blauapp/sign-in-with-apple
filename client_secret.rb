require 'jwt'

key_id = '' # Key ID from Apple Developer Portal
key_file = 'AuthKey_<key_id>.p8'
team_id = '' # Team ID from Apple Developer Portal
client_id = '' # Services ID from Apple Developer Portal

ecdsa_key = OpenSSL::PKey::EC.new IO.read key_file

headers = {
  'kid' => key_id
}

claims = {
	'iss' => team_id,
	'iat' => Time.now.to_i,
	'exp' => Time.now.to_i + 86400*180,
	'aud' => 'https://appleid.apple.com',
	'sub' => client_id,
}

token = JWT.encode claims, ecdsa_key, 'ES256', headers

puts token
