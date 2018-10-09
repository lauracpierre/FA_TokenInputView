#
# Be sure to run `pod lib lint FA_TokenInputView.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "FA_TokenInputView"
  s.version          = "0.3.0"
  s.summary          = "FA_TokenInputView is a simple tokenview mimicking Apple mail token view."
  s.description      = <<-DESC
                       A Swift rewrite of TokenInputView used for the iOS FrontApp.
                       FA_TokenInputView is a simple tokenview mimicking Apple mail token view.
                       DESC
  s.homepage         = "https://github.com/lauracpierre/FA_TokenInputView"
  s.license          = 'MIT'
  s.author           = { "Pierre Laurac" => "pierre.laurac@gmail.com" }
  s.source           = { :git => "https://github.com/lauracpierre/FA_TokenInputView.git", :tag => "v#{s.version}" }

  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.swift_version = '4.2'
  s.source_files = 'Pod/Classes/**/*'

end
