Pod::Spec.new do |s|

  s.name         = "MKHBlockSequence"
  s.version      = "1.0.1"
  s.summary      = "Lightweight implementation of async operations sequence controller"
  s.homepage     = "https://github.com/maximkhatskevich/MKHBlockSequence"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Maxim Khatskevich" => "maxim.khatskevich@gmail.com" }
  s.platform     = :ios, "6.0"

  s.source       = { :git => "https://github.com/maximkhatskevich/MKHBlockSequence.git", :tag => "#{s.version}" }

  s.requires_arc = true

  s.source_files  = "Main/Src/*.{h,m}"

end
