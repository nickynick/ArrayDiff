#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'ArrayDiff'
  s.version          = '0.2.1'
  s.summary          = 'A short description of ArrayDiff.'
  s.description      = <<-DESC
                       An optional longer description of ArrayDiff

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = 'https://github.com/nickynick/ArrayDiff'
  s.license          = 'MIT'
  s.author           = { 'Nikolay Tymchenko' => 't.nick.a@gmail.com' }
  s.source           = { :git => 'https://github.com/nickynick/ArrayDiff.git', :tag => '0.1.0' }

  s.ios.deployment_target = '6.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true

  s.source_files = 'ArrayDiff/**/*.{h,m}'
  s.public_header_files = 'ArrayDiff/**/*.h'

  # s.frameworks = 'SomeFramework', 'AnotherFramework'
end
