Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name = "YCXBannerView"
  s.version = "0.0.1"
  s.summary = "很好用的轮播控件, 可以加载本地图片资源, 可以通过URL链接加载网络图片. 同时可以为图片添加描述文字."

  s.homepage = "https://github.com/Aster0id/YCXBannerViewDemo"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author = "Aster0id"
  s.social_media_url = "http://weibo.com/aster0id"


  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform = :ios, "7.0"
  s.ios.deployment_target = "7.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source = { :git => "https://github.com/Aster0id/YCXBannerViewDemo.git", :tag => "0.0.1" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "YCXBannerViewDemo/YCXBannerView/*.{h,m}"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.frameworks = "UIKit"
  s.dependency pod 'SDWebImage'
  s.dependency pod 'DDPageControl'

end
