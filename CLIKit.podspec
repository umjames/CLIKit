#
# Be sure to run `pod lib lint CLIKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CLIKit"
  s.version          = "0.2.0"
  s.summary          = "Tools to help you build Cocoa command-line applications"
  s.description      = <<-DESC
			Includes classes for parsing command-line options for your Objective-C programs
                       DESC
  s.homepage         = "https://github.com/umjames/CLIKit"
  s.license          = 'MIT'
  s.author           = { "Michael James" => "umjames29@gmail.com" }
  s.source           = { :git => "https://github.com/umjames/CLIKit.git", :tag => s.version.to_s }

  s.platform     = :osx, '10.9'
  s.requires_arc = true

  s.source_files = 'CLIKit/**/*.{h,m}'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
