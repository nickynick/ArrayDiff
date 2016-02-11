Pod::Spec.new do |s|
  s.name             = "NNArrayDiff"
  s.version          = "0.3.0"
  s.summary          = "Yet another diff calculation utility, efficient & tested."

  s.description      = 'A detailed description will be here when I think of a good one.'

  s.homepage         = "https://github.com/nickynick/ArrayDiff"  
  s.license          = 'MIT'
  s.author           = { "Nick Tymchenko" => "t.nick.a@gmail.com" }
  s.source           = { :git => "https://github.com/nickynick/ArrayDiff.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/nickynick42'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'ArrayDiff/**/*.{h,m}'
  s.public_header_files = 'ArrayDiff/**/*.h'

  s.frameworks = 'UIKit'

  s.dependency 'UIKitWorkarounds', '>= 0.2.1'
end