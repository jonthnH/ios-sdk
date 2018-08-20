#
# Be sure to run `pod lib lint BlockV.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name                  = 'BLOCKv'
  s.version               = '1.1.0'
  s.summary               = 'The BLOCKv SDK allows you to easily integrate your apps into the BLOCKv Platform.'
  s.homepage              = 'https://blockv.io'
  s.license               = { :type => 'BLOCKv AG', :file => 'LICENSE' }
  s.author                = { 'BLOCKv' => 'developer.blockv.io' }
  s.source                = { :git => 'https://github.com/BLOCKvIO/ios-sdk.git', :tag => s.version.to_s }
  s.social_media_url      = 'https://twitter.com/blockv_io'
  s.ios.deployment_target = '10.0'
  s.swift_version         = '4.1'
  s.default_subspecs      = 'Core'
  
  s.subspec 'Core' do |s|
      s.source_files = 'BlockV/Core/**/*'
      s.dependency 'Alamofire',  '~> 4.7'  # Networking
      s.dependency 'Starscream', '~> 3.0'  # Web socket
      s.dependency 'JWTDecode',  '~> 2.1'  # JWT decoding
      s.dependency 'Signals',    '~> 5.0'  # Elegant eventing
      s.dependency 'SwiftLint',  '~> 0.26' # Linter
      #s.exclude_files = '**/Info*.plist'
  end
  
  s.subspec 'Face' do |s|
      s.ios.source_files = 'BlockV/Face/**/*'
      s.dependency 'BLOCKv/Core'
      #s.exclude_files = "**/Info*.plist"
      #s.ios.resources = "Source/**/*.xib"
      
      # native://image
      s.dependency 'FLAnimatedImage', '~> 1.0'
  end
  
end
