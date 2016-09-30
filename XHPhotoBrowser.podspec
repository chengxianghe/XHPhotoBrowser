
Pod::Spec.new do |s|

s.name         = "XHPhotoBrowser"
s.version      = "1.0.7"
s.summary      = "XHPhotoBrowser."
s.description  	= <<-DESC
			XHPhotoBrowser...一个图片展示控件, 使用Objective-C
			DESC
s.homepage     = "https://github.com/chengxianghe/XHPhotoBrowser"
# s.screenshots  = "https://github.com/chengxianghe/watch-gif/raw/master/XHPhotoBrowser.gif?raw=true"

s.license      = "MIT"
s.author       = { "chengxianghe" => "chengxianghe@outlook.com" }
s.platform     = :ios, "7.0"

s.source       = { :git => "https://github.com/chengxianghe/XHPhotoBrowser.git", :tag => s.version }


s.frameworks = 'Foundation', 'UIKit'
s.dependency 'YYWebImage'

s.requires_arc = true
s.source_files  = 'Class/XHPhotoBrowser/*.{h,m}'
s.resources     = 'Class/XHPhotoBrowser/XHPhotoBrowser.bundle'

end
