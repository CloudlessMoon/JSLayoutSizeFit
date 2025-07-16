
Pod::Spec.new do |s|
  s.name                  = 'JSLayoutSizeFit'
  s.version               = '0.6.7'
  s.summary               = 'JSLayoutSizeFit'
  s.homepage              = 'https://github.com/jiasongs/JSLayoutSizeFit'
  s.author                = { 'jiasong' => '593908937@qq.com' }
  s.platform              = :ios, '13.0'
  s.swift_versions        = ['5.1']
  s.source                = { :git => 'https://github.com/jiasongs/JSLayoutSizeFit.git', :tag => "#{s.version}" }
  s.frameworks            = 'Foundation', 'UIKit'
  s.static_framework      = true
  s.license               = 'MIT'
  s.requires_arc          = true

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
