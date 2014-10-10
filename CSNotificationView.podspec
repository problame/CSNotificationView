Pod::Spec.new do |s|
  s.name         = 'CSNotificationView'
  s.version      = '0.5.1'
  s.summary      = "Drop-in, semi-translucent and blurring notification view."
  s.homepage     = "https://github.com/problame/CSNotificationView"
  s.license      = { :type => 'MIT License', :file => "LICENSE.md" }
  s.author       = 'Christian Schwarz'
  s.source       = { :git => 'https://github.com/problame/CSNotificationView.git', :tag => s.version.to_s }
  s.platform     = :ios
  s.ios.deployment_target = "7.0"
  s.requires_arc = true
  s.source_files = 'CSNotificationView/*.{h,m}'
  s.resource_bundle = { 'CSNotificationView' => ['CSNotificationView/Resources/*.png'] }
end
