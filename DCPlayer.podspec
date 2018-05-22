Pod::Spec.new do |s|
  s.name         = "DCPlayer"
  s.version      = "1.6"
  s.summary      = "a light weight and easy to use AVPlayer to play video"

  s.homepage     = "https://github.com/CupidLoud/DCPlayer"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Daen" => "lq150924@icloud.com" }
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/CupidLoud/DCPlayer.git", :tag => s.version}
  s.source_files  = 'DCPlayer/*'
  s.resource = "DCPlayer/PlayerImgs.bundle"
  s.requires_arc = true
  s.swift_version = '4.0'
end