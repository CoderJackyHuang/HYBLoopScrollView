Pod::Spec.new do |s|
 s.name         = "HYBLoopScrollView"
  s.version      = "2.2.3"
  s.summary      = "简单易用的app必用的广告轮播组件，一行代码解决"

  s.description  = <<-DESC
                   A longer description of HYBLoopScrollView in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC
s.homepage      = "http://www.henishuo.com/ios-open-source-hybloopscrollview/"
 s.license      = "MIT"
  s.author             = { "Jacky Huang" => "huangyibiao520@163.com" }
 s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/CoderJackyHuang/HYBLoopScrollView.git", :tag => "2.2.3" }
 s.source_files  = "HYBLoopScrollView/HYBLoopScrollview/*"

  # s.public_header_files = "Classes/**/*.h"
 s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  s.dependency "AFNetworking", "~> 2.5.2"

end
