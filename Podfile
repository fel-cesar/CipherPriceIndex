# Uncomment the next line to define a global platform for your project
platform :ios, '12.2'

# ignore all warnings from all pods - ( lots of warnings due to recent release of Swift 5)
inhibit_all_warnings!
#TODO: pod 'FBSDKCoreKit', :inhibit_warnings => true - just placeholder code

target 'Cipher Price Index' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'RxSwift',    '~> 4.4.2'
  pod 'RxCocoa',    '~> 4.4.2'
  pod 'Alamofire', '~> 4.8.2'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'Charts', '~> 3.2.2'
  pod 'SwipeableTabBarController'

  # Pods for Cipher Price Index
  target 'Cipher Price IndexTests' do
    inherit! :search_paths
    pod 'RxBlocking', '~> 4.4.2'
    pod 'RxTest',     '~> 4.4.2'
  end

  target 'Cipher Price IndexUITests' do
    inherit! :search_paths
    pod 'RxBlocking', '~> 4.4.2'
    pod 'RxTest',     '~> 4.4.2'
  end

end
