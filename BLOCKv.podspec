#
# Be sure to run `pod lib lint BlockV.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name                  = 'BLOCKv'
  s.version               = '0.9.7'
  s.summary               = 'The BLOCKv SDK allows you to easily integrate your apps into the BLOCKv Platform.'
  s.homepage              = 'https://blockv.io'
  s.license               = { :type => 'BLOCKv AG', :file => 'LICENSE' }
  s.author                = { 'BLOCKv' => 'developer.blockv.io' }
  s.source                = { :git => 'https://github.com/BLOCKvIO/ios-sdk.git', :tag => s.version.to_s }
  s.social_media_url      = 'https://twitter.com/blockv_io'
  s.ios.deployment_target = '10.0'
  s.source_files          = 'BlockV/Classes/**/*'
  s.swift_version         = '4.1'
  
  s.dependency 'Alamofire', '~> 4.7'
  s.dependency 'JWTDecode', '~> 2.1'
end