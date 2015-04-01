Pod::Spec.new do |s|
  s.name         = "HYBLoopScrollView"
  s.version      = "0.0.1"
  s.summary      = “A scroll view can cycle scroll.”

  s.description  = <<-DESC
                   A longer description of HYBLoopScrollView in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "http://EXAMPLE/HYBLoopScrollView"
  s.license      = "MIT"
  s.author             = { "HuangYiBiao" => “huangyibiao520@163.com" }
  s.platform     = :ios
  s.source       = { :git => "http://EXAMPLE/HYBLoopScrollView.git", :tag => "0.0.1" }
  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.requires_arc = true
  s.dependency “AFNetworking”, "~> 2.0”

end
