Pod::Spec.new do |s|

  s.name         = "BlockSequence"
  s.version      = "1.0.0"
  s.summary      = "Lightweight implementation of async operations sequence controller"
  s.homepage     = "https://github.com/maximkhatskevich/BlockSequence"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Maxim Khatskevich" => "maxim.khatskevich@gmail.com" }
  s.platform     = :ios, "6.0"

  s.source       = { :git => "https://github.com/maximkhatskevich/BlockSequence.git", :tag => "#{s.version}" }

  s.requires_arc = true

  s.source_files  = "Main/Src/*.{h,m}"

  #s.dependency 'CocoaTouchHelpers/Core'

end
