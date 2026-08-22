#
#  Be sure to run `pod spec lint NEAISearchKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#
require_relative "../PodConfigs/config_podspec.rb"
require_relative "../PodConfigs/config_third.rb"
require_relative "../PodConfigs/config_local_common.rb"
require_relative "../PodConfigs/config_local_im.rb"

Pod::Spec.new do |spec|
  spec.name         = NEAISearchKit.name
  spec.version      = YXConfig.imuikit_version
  spec.summary      = 'Netease XKit'
  spec.homepage         = YXConfig.homepage
  spec.license          = YXConfig.license
  spec.author           = YXConfig.author
  spec.ios.deployment_target = YXConfig.deployment_target
  spec.swift_version = YXConfig.swift_version
  
  if ENV["USE_SOURCE_FILES"] == "true"
    spec.source = { :git => "https://github.com/netease-kit/" }
    spec.source_files = 'NEAISearchKit/Classes/**/*'
    spec.resource = 'NEAISearchKit/Assets/**/*'
    
    spec.dependency NEBaseUIKit.name
    spec.dependency NEChatKit.name
  else
    spec.source = { :http => "https://yx-web-nosdn.netease.im/xkit/IMUIKit/10.9.51/NEAISearchKit_iOS_v10.9.51.framework.zip?download=NEAISearchKit_iOS_v10.9.51.framework.zip" }

    spec.subspec 'NOS' do |nos|
      nos.vendored_frameworks = 'NEAISearchKit.xcframework'
      nos.dependency NEChatKit.NOS
      nos.dependency NEBaseUIKit.NOS, NEBaseUIKit.version
    end
    
    spec.subspec 'NOS_Special' do |nos|
      nos.vendored_frameworks = 'NEAISearchKit.xcframework'
      nos.dependency NEChatKit.NOS_Special
      nos.dependency NEBaseUIKit.NOS_Special, NEBaseUIKit.version
    end
    
    spec.subspec 'FCS' do |fcs|
      fcs.vendored_frameworks = 'NEAISearchKit.xcframework'
      fcs.dependency NEChatKit.FCS
      fcs.dependency NEBaseUIKit.FCS, NEBaseUIKit.version
    end
    
    spec.subspec 'FCS_Special' do |fcs|
      fcs.vendored_frameworks = 'NEAISearchKit.xcframework'
      fcs.dependency NEChatKit.FCS_Special
      fcs.dependency NEBaseUIKit.FCS_Special, NEBaseUIKit.version
    end
    spec.default_subspecs = 'NOS'
  end

  YXConfig.pod_target_xcconfig(spec)
end
