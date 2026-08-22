#
# Be sure to run `pod lib lint NEContactUIKit.podspec' to ensure this is a
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
  s.name             = NEContactUIKit.name
  s.version          = YXConfig.imuikit_version
  s.summary          = 'Netease XKit'
  s.homepage         = YXConfig.homepage
  s.license          = YXConfig.license
  s.author           = YXConfig.author
  s.ios.deployment_target = YXConfig.deployment_target
  s.swift_version = YXConfig.swift_version
  
  if ENV["USE_SOURCE_FILES"] == "true"
    s.source = { :git => "https://github.com/netease-kit/" }

    s.source_files = 'NEContactUIKit/Classes/**/*'
    s.resource = 'NEContactUIKit/Assets/**/*'
    s.dependency NEChatKit.name
    s.dependency NEBaseUIKit.name
    s.dependency MJRefresh.name
  else
    s.source = { :http => "https://yx-web-nosdn.netease.im/xkit/IMUIKit/10.9.51/NEContactUIKit_iOS_v10.9.51.framework.zip?download=NEContactUIKit_iOS_v10.9.51.framework.zip" }
    
    s.subspec 'NOS' do |nos|
      nos.vendored_frameworks = 'NEContactUIKit.xcframework'
      nos.dependency NEChatKit.NOS
      nos.dependency NEBaseUIKit.NOS, NEBaseUIKit.version
      nos.dependency MJRefresh.name, MJRefresh.version
    end
    
    s.subspec 'NOS_Special' do |nos|
      nos.vendored_frameworks = 'NEContactUIKit.xcframework'
      nos.dependency NEChatKit.NOS_Special
      nos.dependency NEBaseUIKit.NOS_Special, NEBaseUIKit.version
      nos.dependency MJRefresh.name, MJRefresh.version
    end
    
    s.subspec 'FCS' do |fcs|
      fcs.vendored_frameworks = 'NEContactUIKit.xcframework'
      fcs.dependency NEChatKit.FCS
      fcs.dependency NEBaseUIKit.FCS, NEBaseUIKit.version
      fcs.dependency MJRefresh.name, MJRefresh.version
    end
    
    s.subspec 'FCS_Special' do |fcs|
      fcs.vendored_frameworks = 'NEContactUIKit.xcframework'
      fcs.dependency NEChatKit.FCS_Special
      fcs.dependency NEBaseUIKit.FCS_Special, NEBaseUIKit.version
      fcs.dependency MJRefresh.name, MJRefresh.version
    end
    s.default_subspecs = 'NOS'
  end

  YXConfig.pod_target_xcconfig(s)

end
