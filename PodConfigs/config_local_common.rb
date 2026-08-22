# ---------- NECommonKit ----------
module NECommonKit
  def self.use_path
    true
  end

  def self.name
    "NECommonKit"
  end

  def self.version
    "9.7.7"
  end

  def self.path
    "Common/NECommonKit/NECommonKit.podspec"
  end

  def self.install(pod)
    if NECommonKit.use_path
      puts "NECommonKit use path"
      pod.pod NECommonKit.name, :path => NECommonKit.path
    else
      puts "NECommonKit use http"
      pod.pod NECommonKit.name, NECommonKit.version
    end
  end
end

# ---------- NECommonUIKit ----------
module NECommonUIKit
  def self.use_path
    true
  end

  def self.name
    "NECommonUIKit"
  end

  def self.version
    "9.8.4"
  end

  def self.path
    "NECommonUIKit/NECommonUIKit.podspec"
  end

  def self.NOS
    "NECommonUIKit/NOS"
  end

  def self.NOS_Special
    "NECommonUIKit/NOS_Special"
  end

  def self.FCS
    "NECommonUIKit/FCS"
  end

  def self.FCS_Special
    "NECommonUIKit/FCS_Special"
  end

  def self.install(pod)
    if NECommonUIKit.use_path
      puts "NECommonUIKit use path"
      pod.pod NECommonUIKit.name, :path => NECommonUIKit.path
    else
      puts "NECommonUIKit use http"
      pod.pod NECommonUIKit.name, NECommonUIKit.version
    end
  end
end

# ---------- NEBaseUIKit ----------
module NEBaseUIKit
  def self.use_path
    true
  end

  def self.name
    "NEBaseUIKit"
  end

  def self.version
    YXConfig.imuikit_version
  end

  def self.path
    "NEBaseUIKit/NEBaseUIKit.podspec"
  end

  def self.NOS
    "NEBaseUIKit/NOS"
  end

  def self.NOS_Special
    "NEBaseUIKit/NOS_Special"
  end

  def self.FCS
    "NEBaseUIKit/FCS"
  end

  def self.FCS_Special
    "NEBaseUIKit/FCS_Special"
  end

  def self.install(pod)
    if NEBaseUIKit.use_path
      puts "NEBaseUIKit use path"
      pod.pod NEBaseUIKit.name, :path => NEBaseUIKit.path
    else
      puts "NEBaseUIKit use http"
      pod.pod NEBaseUIKit.name, NEBaseUIKit.version
    end
  end
end

# ---------- NETranscodingKit ----------
module NETranscodingKit
  def self.use_path
    true
  end

  def self.name
    "NETranscodingKit"
  end

  def self.version
    "1.0.1"
  end

  def self.path
    "Common/NETranscodingKit/NETranscodingKit.podspec"
  end

  def self.install(pod)
    if NETranscodingKit.use_path
      puts "NETranscodingKit use path"
      pod.pod NETranscodingKit.name, :path => NETranscodingKit.path
    else
      puts "NETranscodingKit use http"
      pod.pod NETranscodingKit.name, NETranscodingKit.version
    end
  end
end



# ---------- YXLogin ----------
module YXLogin
  def self.use_path
    true
  end

  def self.name
    "YXLogin"
  end

  def self.version
    "1.2.3"
  end

  def self.path
    "YXLogin/YXLogin.podspec"
  end

  def self.install(pod)
    if YXLogin.use_path
      puts "YXLogin use path"
      pod.pod YXLogin.name, :path => YXLogin.path
    else
      puts "YXLogin use http"
      pod.pod YXLogin.name, YXLogin.version
    end
  end
end

# ---------- Hawk ----------
module Hawk
  def self.name
    "Hawk"
  end

  def self.path
    "AutoTest/Hawk/Hawk.podspec"
  end

  def self.install(pod)
    pod.pod Hawk.name, :path => Hawk.path
  end
end
