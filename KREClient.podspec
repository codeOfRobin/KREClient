Pod::Spec.new do |s|
  s.name         = "KREClient"
  s.version      = "0.1"
  s.summary      = "Client for Kayako Realtime Engine"
  s.description  = "Client for Kayako Realtime Engine. Works with iOS 8.0 and greater."
  s.homepage     = "https://github.com/codeOfRobin/KREClient"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Robin Malhotra" => "robin.malhotra@kayako.com" }
  s.social_media_url   = "https://twitter.com/codeofrobin"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/codeOfRobin/KREClient.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "UIKit"
  s.depedency "Birdsong"
  s.depedency "Unbox"
end
