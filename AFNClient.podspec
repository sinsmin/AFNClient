Pod::Spec.new do |s|
  s.name             = 'AFNClient'
  s.version          = '0.1.0'
  s.summary          = 'This is an HTTP library from AFNetworking.'
  s.homepage         = 'https://github.com/sinsmin/AFNClient'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sinsmin' => 'wkcdeie@gmail.com' }
  s.source           = { :git => 'https://github.com/sinsmin/AFNClient.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'

  s.source_files = 'AFNClient/Classes/**/*'
  s.requires_arc  = true
  s.dependency 'AFNetworking', '~> 3.0'
end
