#
#  Be sure to run `pod spec lint PlayolaCore.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
    s.name         = "PlayolaCore"
    s.version      = "0.3.0"
    s.summary      = "Basic Playola Communication and Models."
    s.homepage     = "https://github.com/briankeane/PlayolaCore.git"
    s.license      = { :type => 'MIT' }
    s.swift_version = "4.2"
    s.pod_target_xcconfig = { "SWIFT_VERSION" => "5.0" }
    s.author       = { "Brian Keane" => "brian@playola.fm" }
    s.ios.deployment_target = '10.3'
    s.osx.deployment_target = '10.12'
    s.source       = { :git => "https://github.com/briankeane/PlayolaCore.git", :tag => s.version }
    s.exclude_files = []
    s.swift_version = "5.0"
    # s.ios.frameworks = 'AudioToolbox','AVFoundation','GLKit', 'Accelerate'
    # s.osx.frameworks = 'AudioToolbox','AudioUnit','CoreAudio','QuartzCore','OpenGL','GLKit', 'Accelerate'
    # s.requires_arc = true;
    # s.default_subspec = 'Full'
    s.dependency 'Alamofire', '~> 4.7.3'
    s.dependency 'PromiseKit', '~> 6.5.0'
    s.dependency 'SwiftRemoteFileCache', '~> 0.1'
    s.dependency 'Kingfisher', '~> 4.10.0'
    s.dependency 'SwiftyJSON', '~> 4.2.0'

    # s.ios.dependency 'KDCircularProgress', '~> 1.5.2'  # manually include until he fixes cocoapod

    
    s.source_files = 'Sources/**/*.{h,m,c,swift}'
    s.ios.exclude_files = 'Sources/osxOnly/**/*.{h,m,swift}'
    s.osx.exclude_files = 'Sources/iosOnly/**/*.{h,m,swift}'
    s.resource_bundle = {
      'PlayolaImages' => ['Sources/Images/**/*.{png,xcassets,imageset,json}']
    }
    s.resources = 'Sources/Images/**/*.{png,xcassets,imageset,json}'

    # probably will use this later when start subSpecing (PlayolaCore-Player, PlayolaCore-Core, etc)
    # s.subspec 'Core' do |core|
    #     core.source_files  = 'Sources/**/*.{h,m,swift}'
    # end


    # s.subspec 'Full' do |full|
    #     full.dependency 'Alamofire', '4.5.0'
    #     full.dependency 'PromiseKit', '~> 4.0'
    # end
end
