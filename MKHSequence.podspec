Pod::Spec.new do |s|

  s.name             = "MKHSequence"
  s.version          = "1.0.3"
  s.summary          = "Lightweight implementation of async operations sequence controller"
  s.homepage         = "https://github.com/maximkhatskevich/#{s.name}"

  s.license          = { :type => "MIT", :file => "LICENSE" }

  s.author           = { "Maxim Khatskevich" => "maxim@khatskevi.ch" }
  s.platform         = :ios, "6.0"

  s.source           = { :git => "#{s.homepage}.git", :tag => "#{s.version}" }
  s.source_files     = "Src/*.{h,m}"

  s.requires_arc     = true

  s.social_media_url = "http://www.linkedin.com/in/maximkhatskevich"

end
