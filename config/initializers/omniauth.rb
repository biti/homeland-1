require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env == "development"
    provider :github, '60cd983b1cbb4f342a6a', 'e04e93c7b9f7e9a571fe390c886600825c93d7d7', :client_options => {:ssl => {:ca_file => '/etc/pki/tls/certs/ca-bundle.crt'}}
    provider :douban, '088f885bfed7f36819ae9913fc87da38','ca3a5bd89c6bc37f'
  else
    provider :github, '60cd983b1cbb4f342a6a', 'e04e93c7b9f7e9a571fe390c886600825c93d7d7', {:client_options => {:ssl => {:ca_file => '/etc/pki/tls/certs/ca-bundle.crt'}}}
    provider :douban, '088f885bfed7f36819ae9913fc87da38','ca3a5bd89c6bc37f'
  end

  provider :openid, OpenID::Store::Filesystem.new('./tmp'), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
end

