
Pod::Spec.new do |s|
  s.name                  = 'JSLayoutSizeFit'
  s.summary               = 'JSLayoutSizeFit'
  s.homepage              = 'https://github.com/jiasongs/JSLayoutSizeFit'
  s.license               = 'MIT'
  s.author                = { 'jiasong' => '593908937@qq.com' }
  s.source                = { :git => 'https://github.com/jiasongs/JSLayoutSizeFit.git', :tag => "#{s.version}" }
  s.version               = '1.0.0'
  s.platform              = :ios, '15.0'
  s.swift_versions        = ['5.9']
  s.requires_arc          = true
  s.frameworks            = 'Foundation', 'UIKit'

  s.dependency 'JSCoreKit', '~> 1.0'

  s.default_subspec = 'Core'
  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/Core/**/*.{h,m,swift}'
    ss.private_header_files = 'Sources/Core/_Private/*.{h,m,swift}'
  end

  s.subspec 'ExtensionForSwift' do |ss|
    ss.source_files = 'Sources/Swift/*.{h,m,swift}'
    ss.dependency 'JSLayoutSizeFit/Core'
  end
end
