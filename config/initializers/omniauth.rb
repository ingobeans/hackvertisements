Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect, {
    name: :hackclub,
    scope: [:openid, :profile],
    response_type: :code,
    discovery: "https://auth.hackclub.com/.well-known/openid-configuration"
  }
end