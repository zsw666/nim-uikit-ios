#
#  Be sure to run `pod spec lint NEChatUIKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the s.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/pods.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#
require_relative "../PodConfigs/config_podspec.rb"
require_relative "../PodConfigs/config_third.rb"
require_relative "../PodConfigs/config_local_common.rb"
require_relative "../PodConfigs/config_local_im.rb"

Pod::Spec.new do |s|
  s.name         = NEChatUIKit.name
  s.version      = YXConfig.imuikit_version
  s.summary      = 'Chat Module of IM.'
  s.homepage         = YXConfig.homepage
  s.license          = YXConfig.license
  s.author           = YXConfig.author
  s.ios.deployment_target = YXConfig.deployment_target
  s.swift_version = YXConfig.swift_version
  
  if ENV["USE_SOURCE_FILES"] == "true"
    s.source = { :git => "https://github.com/netease-kit/" }
    s.source_files = 'NEChatUIKit/Classes/**/*'
    s.resource = 'NEChatUIKit/Assets/**/*'
    s.dependency NEChatKit.name
    s.dependency NEBaseUIKit.name
    s.dependency MJRefresh.name
    s.dependency 'SDWebImageWebPCoder'
    s.dependency 'SDWebImageSVGKitPlugin'
  else
    s.source = { :http => "https://yx-web-nosdn.netease.im/xkit/IMUIKit/10.9.51/NEChatUIKit_iOS_v10.9.51.framework.zip?download=NEChatUIKit_iOS_v10.9.51.framework.zip" }
    
    s.subspec 'NOS' do |nos|
      nos.vendored_frameworks = 'NEChatUIKit.xcframework'
      nos.dependency NEChatKit.NOS
      nos.dependency NEBaseUIKit.NOS, NEBaseUIKit.version
      nos.dependency MJRefresh.name, MJRefresh.version
      nos.dependency 'SDWebImageWebPCoder'
      nos.dependency 'SDWebImageSVGKitPlugin'
    end
    
    s.subspec 'NOS_Special' do |nos|
      nos.vendored_frameworks = 'NEChatUIKit.xcframework'
      nos.dependency NEChatKit.NOS_Special
      nos.dependency NEBaseUIKit.NOS_Special, NEBaseUIKit.version
      nos.dependency MJRefresh.name, MJRefresh.version
      nos.dependency 'SDWebImageWebPCoder'
      nos.dependency 'SDWebImageSVGKitPlugin'
    end
    
    s.subspec 'FCS' do |fcs|
      fcs.vendored_frameworks = 'NEChatUIKit.xcframework'
      fcs.dependency NEChatKit.FCS
      fcs.dependency NEBaseUIKit.FCS, NEBaseUIKit.version
      fcs.dependency MJRefresh.name, MJRefresh.version
      fcs.dependency 'SDWebImageWebPCoder'
      fcs.dependency 'SDWebImageSVGKitPlugin'
    end
    
    s.subspec 'FCS_Special' do |fcs|
      fcs.vendored_frameworks = 'NEChatUIKit.xcframework'
      fcs.dependency NEChatKit.FCS_Special
      fcs.dependency NEBaseUIKit.FCS_Special, NEBaseUIKit.version
      fcs.dependency MJRefresh.name, MJRefresh.version
      fcs.dependency 'SDWebImageWebPCoder'
      fcs.dependency 'SDWebImageSVGKitPlugin'
    end
    s.default_subspecs = 'NOS'
  end

  YXConfig.pod_target_xcconfig(s)
end
