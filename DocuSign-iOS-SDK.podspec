Pod::Spec.new do |s|
  s.name = "DocuSign-iOS-SDK"
  s.version = "0.1.3-beta"
  s.summary = "DocuSign iOS SDK Beta"
  s.description = "An iOS SDK that provides a quick and easy way for registered developers to add DocuSign's world-class document signing experience to their native iOS apps."
  s.homepage = "https://github.com/docusign/docusign-ios-sdk"
  s.license = 'DOCUSIGN API SDK LICENSE'
  s.author = { "Arlo Armstrong" => "arlo.armstrong@docusign.com" }
  s.source = { :git => "https://github.com/docusign/docusign-ios-sdk.git", :tag => "v0.1.3-beta" }
  s.social_media_url = 'https://twitter.com/DocuSignDev'
  
  s.platform = :ios, '7.0'
  s.requires_arc = true
  
  s.source_files = ['**/SDK/**/*.{h,m}']
  s.resources = ['**/SDK/**/*.{storyboard,xcassets}']
  
  s.frameworks = 'AVFoundation', 'CoreLocation', 'Foundation', 'ImageIO', 'MobileCoreServices', 'QuartzCore', 'UIKit'
  s.libraries = 'objc'
  
  s.dependency 'AKANetworkLogging', '~>0.1'
  s.dependency 'DSTextEntryValidation', '~>1.0'
  s.dependency 'Mantle', '~>1.4'
  s.dependency 'TPKeyboardAvoiding', '~>1.2'
  
end
