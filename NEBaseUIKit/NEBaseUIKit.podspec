#
# Be sure to run `pod lib lint NEBaseUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
require_relative "../PodConfigs/config_podspec.rb"
require_relative "../PodConfigs/config_third.rb"
require_relative "../PodConfigs/config_local_common.rb"
require_relative "../PodConfigs/config_local_im.rb"

Pod::Spec.new do |s|
  s.name             = NEBaseUIKit.name
  s.version          = NEBaseUIKit.version
  s.summary          = 'Netease XKit'
  s.homepage         = YXConfig.homepage
  s.license = YXConfig.license
  s.author           = YXConfig.author
  s.ios.deployment_target = YXConfig.deployment_target
  s.swift_version = YXConfig.swift_version


  if ENV["USE_SOURCE_FILES"] == "true"
    s.source = { :git => "https://github.com/netease-kit/" }
    s.source_files = 'NEBaseUIKit/Classes/**/*'
    s.resource = 'NEBaseUIKit/Assets/**/*'
    s.dependency NEChatKit.name
    s.dependency SDWebImage.name
  else
    s.source = { :http => "https://yx-web-nosdn.netease.im/xkit/IMUIKit/10.9.51/NEBaseUIKit_iOS_v10.9.51.framework.zip?download=NEBaseUIKit_iOS_v10.9.51.framework.zip" }

    s.subspec 'NOS' do |nos|
      nos.vendored_frameworks = 'NEBaseUIKit.xcframework'
      nos.dependency NEChatKit.NOS
      nos.dependency SDWebImage.name
    end

    s.subspec 'NOS_Special' do |nos|
      nos.vendored_frameworks = 'NEBaseUIKit.xcframework'
      nos.dependency NEChatKit.NOS_Special
      nos.dependency SDWebImage.name
    end

    s.subspec 'FCS' do |fcs|
      fcs.vendored_frameworks = 'NEBaseUIKit.xcframework'
      fcs.dependency NEChatKit.FCS
      fcs.dependency SDWebImage.name
    end

    s.subspec 'FCS_Special' do |fcs|
      fcs.vendored_frameworks = 'NEBaseUIKit.xcframework'
      fcs.dependency NEChatKit.FCS_Special
      fcs.dependency SDWebImage.name
    end
    s.default_subspecs = 'NOS'
  end

  YXConfig.pod_target_xcconfig(s)

end
