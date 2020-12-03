#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_mixpanel'
  s.version          = '0.0.1'
  s.summary          = 'Flutter Mixpanel'
  s.description      = <<-DESC
Flutter Mixpanel
                       DESC
  s.homepage         = 'https://github.com/amondnet/flutter_mixpanel'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Minsu Lee' => 'amond@amond.net' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  # Swift 5
  s.dependency 'Mixpanel-swift', '2.8.1'
  s.ios.deployment_target = '9.0'
end

