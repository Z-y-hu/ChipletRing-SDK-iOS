#
# Be sure to run `pod lib lint Rings-SDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Rings-SDK'
  s.version          = '1.0.10'
  s.summary          = 'ring SDK'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  This is a sdk for the ios platform specifically for the Yongxin ring
                       DESC

  s.homepage         = 'https://github.com/Z-y-hu/ChipletRing-SDK-iOS' 
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zyh' => 'yuhu.zheng@bravechip.com' }
  s.source           = { :git => 'https://github.com/Z-y-hu/ChipletRing-SDK-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.source_files = 'SDK%26Demo/Rings-SDK/Rings-SDK/Classes/*'

  s.vendored_frameworks = 'SDK%26Demo/Rings-SDK/RingsSDK.framework'
  s.requires_arc     = true
end
