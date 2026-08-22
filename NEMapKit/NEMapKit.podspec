#
# Be sure to run `pod lib lint NEMapKit.podspec' to ensure this is a
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
  s.name             = NEMapKit.name
  s.version          = YXConfig.imuikit_version
  s.summary          = 'Netease XKit'
  s.homepage         = YXConfig.homepage
  s.license          = YXConfig.license
  s.author           = YXConfig.author
  s.ios.deployment_target = YXConfig.deployment_target
  s.swift_version = YXConfig.swift_version
  s.static_framework = true
  
  if ENV["USE_SOURCE_FILES"] == "true"
    s.source = { :git => "https://github.com/netease-kit/" }

    s.source_files = 'NEMapKit/Classes/**/*'
#    s.resource = 'NEMapKit/Assets/**/*'
    s.resource_bundles = {
      'NEMapKit' => ['NEMapKit/Assets/*.xcassets','NEMapKit/Assets/*.lproj']
    }

    s.dependency 'AMap3DMap'
    s.dependency 'AMapSearch'
    s.dependency 'AMapLocation'
    s.dependency NEChatUIKit.name
    s.dependency NEChatKit.name
  else
    s.source = { :http => "https://yx-web-nosdn.netease.im/xkit/IMUIKit/10.9.51/NEMapKit_iOS_v10.9.51.framework.zip?download=NEMapKit_iOS_v10.9.51.framework.zip" }

    s.subspec 'NOS' do |nos|
      nos.vendored_frameworks = 'NEMapKit.xcframework'
      nos.dependency 'AMap3DMap'
      nos.dependency 'AMapSearch'
      nos.dependency 'AMapLocation'
      nos.dependency NEChatUIKit.NOS
      nos.dependency NEChatKit.NOS
    end

    s.subspec 'NOS_Special' do |nos|
      nos.vendored_frameworks = 'NEMapKit.xcframework'
      nos.dependency 'AMap3DMap'
      nos.dependency 'AMapSearch'
      nos.dependency 'AMapLocation'
      nos.dependency NEChatUIKit.NOS_Special
      nos.dependency NEChatKit.NOS_Special
    end

    s.subspec 'FCS' do |fcs|
      fcs.vendored_frameworks = 'NEMapKit.xcframework'
      fcs.dependency 'AMap3DMap'
      fcs.dependency 'AMapSearch'
      fcs.dependency 'AMapLocation'
      fcs.dependency NEChatUIKit.FCS
      fcs.dependency NEChatKit.FCS
    end

    s.subspec 'FCS_Special' do |fcs|
      fcs.vendored_frameworks = 'NEMapKit.xcframework'
      fcs.dependency 'AMap3DMap'
      fcs.dependency 'AMapSearch'
      fcs.dependency 'AMapLocation'
      fcs.dependency NEChatUIKit.FCS_Special
      fcs.dependency NEChatKit.FCS_Special
    end
    s.default_subspecs = 'NOS'
  end

  YXConfig.pod_target_xcconfig(s)
end
