Pod::Spec.new do |s|
  s.name             = "NSTNetworking"
  s.version          = "1.0.10"
  s.summary          = "NS-Networking from Netco Sports"
  s.homepage         = "https://github.com/netcosports/NS-Networking"
  s.license          = 'Private'
  s.author           = { "Netco Sports" => "ios@netcosports.com" }
  s.source           = { :git => "git@github.com:netcosports/NS-Networking.git", :tag => s.version }
  s.social_media_url = 'https://twitter.com/netcosports'

  s.platform     = :ios, '13.0'
  s.requires_arc = true

  s.pod_target_xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }

  s.dependency 'NSTCategories', '~> 1.1'
  s.dependency 'AFNetworking', '4.0.1'

  s.source_files = 'NSHTTPRequester'

  s.frameworks = 'Security'
  s.static_framework = true
end
