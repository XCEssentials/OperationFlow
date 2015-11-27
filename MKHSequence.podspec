Pod::Spec.new do |s|

  s.name         = "MKHSequenceCtrl"
  s.version      = "1.0.3"
  s.summary      = "Lightweight implementation of async operations sequence controller"
  s.homepage     = "https://github.com/maximkhatskevich/MKHSequenceCtrl"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Maxim Khatskevich" => "maxim@khatskevi.ch" }
  s.platform     = :ios, "6.0"

  s.source       = { :git => "https://github.com/maximkhatskevich/MKHBlockSequence.git", :tag => "#{s.version}" }

  s.requires_arc = true

  s.source_files  = "Src/*.{h,m}"

end
