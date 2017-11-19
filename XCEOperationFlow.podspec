Pod::Spec.new do |s|

  s.name                      = 'XCEOperationFlow'
  s.summary                   = 'Lightweight async serial operation flow controller.'
  s.version                   = '0.1.0'
  s.homepage                  = 'https://XCEssentials.github.io/OperationFlow'

  s.source                    = { :git => 'https://github.com/XCEssentials/OperationFlow.git', :tag => s.version }

  s.requires_arc              = true

  s.license                   = { :type => 'MIT', :file => 'LICENSE' }
  s.author                    = { 'Maxim Khatskevich' => 'maxim@khatskevi.ch' }

  s.ios.deployment_target     = '9.0'

  s.watchos.deployment_target = '4.0'

  s.tvos.deployment_target    = '11.0'

  s.osx.deployment_target     = '10.11'

  s.source_files              = 'Sources/OperationFlow/**/*.swift'

end