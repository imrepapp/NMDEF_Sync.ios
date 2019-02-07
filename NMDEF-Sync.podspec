#
# Be sure to run `pod lib lint NMDEF-Sync.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NMDEF-Sync'
  s.version          = '0.1.0'
  s.summary          = 'Data synchronization framework for NMDEF applications'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This framework handles synchronization and data manipulation process between NMDEF applications and the API.
                       DESC

  s.homepage         = 'https://xaptdev.visualstudio.com/CE%20Mobile/_git/nmdef.sync.ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xapt Kft' => 'mobileteam@xapt.com' }
  s.source           = { :git => 'https://xaptdev.visualstudio.com/CE_Mobile/_git/nmdef.sync.ios', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'NMDEF-Sync/Classes/**/*'
  
  # s.resource_bundles = {
  #   'NMDEF-Sync' => ['NMDEF-Sync/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'MicrosoftAzureMobile-Xapt'
  s.dependency 'RealmSwift'
  s.dependency 'EVReflection/Realm'
  s.dependency 'ReachabilitySwift'
  s.dependency 'Alamofire', '~> 4.7'
  s.dependency 'RxSwift',    '~> 4.0'
  s.dependency 'RxCocoa',    '~> 4.0'
end
