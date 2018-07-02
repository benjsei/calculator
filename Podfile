source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
inhibit_all_warnings!

platform :ios, '11.0'

project 'Calculator.xcodeproj'
workspace 'Calculator.xcworkspace'

abstract_target 'app' do

    pod 'Swinject', '2.1.0'
    pod 'RxAppState', '1.0.1'
    pod 'RxCocoa',    '4.0'
    pod 'RxDataSources', '~> 3.0'
    pod 'RxKeyboard', '0.8.1'

    target 'Calculator'

    target 'CalculatorTests' do

        pod 'Cucumberish', '1.1.0'
        pod 'RxBlocking', '4.0'
        pod 'RxTest',     '4.0'
        pod 'OHHTTPStubs/Swift', '6.1.0'

    end

end
