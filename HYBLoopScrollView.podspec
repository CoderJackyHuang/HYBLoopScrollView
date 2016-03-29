Pod::Spec.new do |s|
 s.name         = "HYBLoopScrollView"
  s.version      = "3.1.2"
  s.summary      = "简单易用的app必用的广告轮播组件，一行代码解决"

  s.description  = <<-DESC
                   一行代码解决轮播图问题，无任何库依赖，自带下载及缓存功能，可随时获取缓存大小、清空缓存。支持横屏、竖屏。支持自动布局。
                   支持带标题与不带标题。支持pagecontrl显示与隐藏。
                   DESC
s.homepage      = "http://www.henishuo.com/ios-open-source-hybloopscrollview/"
 s.license      = "MIT"
  s.author      = { "Jacky Huang" => "huangyibiao520@163.com" }
 s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/CoderJackyHuang/HYBLoopScrollView.git", :tag => "3.1.2" }
 s.source_files  = "HYBLoopScrollView/HYBLoopScrollview/*"
 s.requires_arc = true

end
