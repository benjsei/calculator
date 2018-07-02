//
//  UIApplication+Rx.swift
//  Pods
//
//  Created by Jörn Schoppe on 29.02.16.
//  Copyright © 2015 Jörn Schoppe. All rights reserved.
//

import RxSwift
import RxCocoa

/**
 UIApplication states
 
 There are two more app states in the Apple Docs ("Not running" and "Suspended").
 I decided to ignore those two states because there are no UIApplicationDelegate
 methods for those states.

 +------------------------------------------------+
 |                     active                     |
 +------------------------------------------------+
             ^                        |
             |                        |
      didBecomeActive          willResignActive
             |                        |
             |                        v
 +------------------------------------------------+
 |                    inactive                    |
 +------------------------------------------------+
             ^                        |
             |                        |
    willEnterForeground       didEnterBackground
             |                        |
             |                        v
 +------------------------------------------------+
 |                   background                   |
 +------------------------------------------------+
                                      |
                                      |
                                willTerminate
                                      |
                                      v
 +------------------------------------------------+
 |                   terminated                   |
 +------------------------------------------------+

 */
public enum AppState: Equatable {
    /**
     The application is running in the foreground.
     */
    case active
    /**
     The application is running in the foreground but not receiving events.
     Possible reasons:
     - The user has opens Notification Center or Control Center
     - The user receives a phone call
     - A system prompt is shown (e.g. Request to allow Push Notifications)
     */
    case inactive
    /**
     The application is in the background because the user closed it.
     */
    case background
    /**
     The application is about to be terminated by the system
     */
    case terminated
    
    public static func ==(lhs: AppState, rhs: AppState) -> Bool {
        switch (lhs, rhs) {
        case (.active, .active),
             (.inactive, .inactive),
             (.background, .background),
             (.terminated, .terminated):
            return true
        default:
            return false
        }
    }
}

public struct RxAppState {
    /**
     Allows for the app version to be stored by default in the main bundle from `CFBundleShortVersionString` or
     a custom implementation per app.
     */
    public static var currentAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
}

extension RxSwift.Reactive where Base: UIApplication {
    
    /**
     Keys for NSUserDefaults
     */
    fileprivate struct DefaultName {
        static var isFirstLaunch: String { return "RxAppState_isFirstLaunch" }
        static var numDidOpenApp: String { return "RxAppState_numDidOpenApp" }
        static var lastAppVersion: String { return "RxAppState_lastAppVersion" }
    }
    
    /**
     Reactive wrapper for `delegate`.
     
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var delegate: DelegateProxy<UIApplication, UIApplicationDelegate> {
        return RxApplicationDelegateProxy.proxy(for: base)
    }
    
    /**
     Reactive wrapper for `delegate` message `applicationWillEnterForeground(_:)`.
     */
    public var applicationWillEnterForeground: Observable<AppState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationWillEnterForeground(_:)))
            .map { _ in
                return .inactive
        }
    }

    /**
     Reactive wrapper for `delegate` message `applicationDidBecomeActive(_:)`.
     */
    public var applicationDidBecomeActive: Observable<AppState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationDidBecomeActive(_:)))
            .map { _ in
                return .active
        }
    }

    /**
     Reactive wrapper for `delegate` message `applicationDidEnterBackground(_:)`.
     */
    public var applicationDidEnterBackground: Observable<AppState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationDidEnterBackground(_:)))
            .map { _ in
                return .background
        }
    }
    
    /**
     Reactive wrapper for `delegate` message `applicationWillResignActive(_:)`.
     */
    public var applicationWillResignActive: Observable<AppState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationWillResignActive(_:)))
            .map { _ in
                return .inactive
        }
    }
    
    /**
     Reactive wrapper for `delegate` message `applicationWillTerminate(_:)`.
     */
    public var applicationWillTerminate: Observable<AppState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationWillTerminate(_:)))
            .map { _ in
                return .terminated
        }
    }
    
    /**
     Observable sequence of the application's state
     
     This gives you an observable sequence of all possible application states.
     
     - returns: Observable sequence of AppStates
     */
    public var appState: Observable<AppState> {
        return Observable.of(
            applicationDidBecomeActive,
            applicationWillResignActive,
            applicationWillEnterForeground,
            applicationDidEnterBackground,
            applicationWillTerminate
            )
            .merge()
    }
    
    /**
     Observable sequence that emits a value whenever the user opens the app
     
     This is a handy sequence if you want to run some code everytime
     the user opens the app.
     It ignores `applicationDidBecomeActive(_:)` calls when the app was not
     in the background but only in inactive state (because the user
     opened control center or received a call).
     
     Typical use cases:
     - Track when the user opens the app.
     - Refresh data on app start
     
     - returns: Observable sequence of Void
     */
    public var didOpenApp: Observable<Void> {
        return Observable.of(
            applicationDidBecomeActive,
            applicationDidEnterBackground
            )
            .merge()
            .distinctUntilChanged()
            .filter { $0 == .active }
            .map { _ in
                return
        }
    }
    
    /**
     Observable sequence that emits the number of times a user has opened the app
     
     This is a handy sequence if you want to know how many times the user has opened your app
     
     Typical use cases:
     - Ask a user to review your app after when he opens it for the 10th time
     - Track the number of times a user has opened the app
     
     -returns: Observable sequence of Int
     */
    public var didOpenAppCount: Observable<Int> {
        return base._sharedRxAppState.didOpenAppCount
    }
    
    /**
     Observable sequence that emits if the app is opened for the first time when the user opens the app
     
     This is a handy sequence for all the times you want to run some code only
     when the app is launched for the first time
     
     Typical use case:
     - Show a tutorial to a new user
     
     -returns: Observable sequence of Bool
     */
    public var isFirstLaunch: Observable<Bool> {
        return base._sharedRxAppState.isFirstLaunch
    }
    
    /**
     Observable sequence that emits if the app is opened for the first time after an app has updated when the user
     opens the app. This does not occur on first launch of a new app install. See `isFirstLaunch` for that.
     
     This is a handy sequence for all the times you want to run some code only when the app is launched for the
     first time after an update.
     
     Typical use case:
     - Show a what's new dialog to users, or prompt review or signup
     
     -returns: Observable sequence of Bool
     */
    public var isFirstLaunchOfNewVersion: Observable<Bool> {
        return base._sharedRxAppState.isFirstLaunchOfNewVersion
    }
    
    /**
     Observable sequence that just emits one value if the app is opened for the first time for a new version
     or completes empty if this version of the app has been opened before
     
     This is a handy sequence for all the times you want to run some code only when a new version of the app
     is launched for the first time
     
     Typical use case:
     - Show a what's new dialog to users, or prompt review or signup
     
     -returns: Observable sequence of Void
     */
    public var firstLaunchOfNewVersionOnly: Observable<Void> {
        return base._sharedRxAppState.firstLaunchOfNewVersionOnly
    }

    /**
     Observable sequence that just emits one value if the app is opened for the first time
     or completes empty if the app has been opened before
     
     This is a handy sequence for all the times you want to run some code only
     when the app is launched for the first time
     
     Typical use case:
     - Show a tutorial to a new user
     
     -returns: Observable sequence of Void
     */
    public var firstLaunchOnly: Observable<Void> {
        return base._sharedRxAppState.firstLaunchOnly
    }
    
}

fileprivate struct _SharedRxAppState {
    typealias DefaultName = Reactive<UIApplication>.DefaultName
    
    /**
     App versions
     */
    fileprivate struct AppVersions {
        let last: String?
        let current: String
        
        var isLastEmpty: Bool { return last?.isEmpty ?? true }
        var isUpgraded: Bool {
            if let last = last, last != current {
                return true
            }
            return false
        }
        
        static func get() -> AppVersions {
            return AppVersions(last: UserDefaults.standard.string(forKey: DefaultName.lastAppVersion),
                               current: RxAppState.currentAppVersion ?? "")
        }
        
        static func setLastVersion(lastVersion: String) {
            let userDefaults = UserDefaults.standard
            userDefaults.set(lastVersion, forKey: DefaultName.lastAppVersion)
            userDefaults.synchronize()
        }
    }
    
    let rx: Reactive<UIApplication>
    
    init(_ application: UIApplication) {
        rx = application.rx
    }
    
    lazy var didOpenAppCount: Observable<Int> = self.rx.didOpenApp
        .map { _ in
            let userDefaults = UserDefaults.standard
            var count = userDefaults.integer(forKey: DefaultName.numDidOpenApp)
            count = min(count + 1, Int.max - 1)
            userDefaults.set(count, forKey: DefaultName.numDidOpenApp)
            userDefaults.synchronize()
            return count
        }
        .share(replay: 1, scope: .forever)
    
    lazy var isFirstLaunch: Observable<Bool> = self.rx.didOpenApp
        .map { _ in
            let userDefaults = UserDefaults.standard
            let didLaunchBefore = userDefaults.bool(forKey: DefaultName.isFirstLaunch)
            
            if didLaunchBefore {
                return false
            } else {
                userDefaults.set(true, forKey: DefaultName.isFirstLaunch)
                userDefaults.synchronize()
                return true
            }
        }
        .share(replay: 1, scope: .forever)
    
    lazy var isFirstLaunchOfNewVersion: Observable<Bool> = self.rx.didOpenApp
        .map { _ in
            let appVersions = AppVersions.get()
            
            if appVersions.isLastEmpty || appVersions.isUpgraded {
                AppVersions.setLastVersion(lastVersion: appVersions.current)
            }
            
            return appVersions.isUpgraded
        }
        .share(replay: 1, scope: .forever)
    
    lazy var firstLaunchOfNewVersionOnly: Observable<Void> = Observable
        .create { observer in
            let appVersions = AppVersions.get()
            
            if appVersions.isUpgraded {
                AppVersions.setLastVersion(lastVersion: appVersions.current)
                observer.onNext(())
            }
            observer.onCompleted()
            return Disposables.create {}
        }
        .share(replay: 1, scope: .forever)
    
    lazy var firstLaunchOnly: Observable<Void> = Observable
        .create { observer in
            let userDefaults = UserDefaults.standard
            let didLaunchBefore = userDefaults.bool(forKey: DefaultName.isFirstLaunch)
            
            if !didLaunchBefore {
                userDefaults.set(true, forKey: DefaultName.isFirstLaunch)
                userDefaults.synchronize()
                observer.onNext(())
            }
            observer.onCompleted()
            return Disposables.create {}
        }
        .share(replay: 1, scope: .forever)
}

private var _sharedRxAppStateKey: UInt8 = 0
extension UIApplication {
    fileprivate var _sharedRxAppState: _SharedRxAppState {
        get {
            if let stored = objc_getAssociatedObject(self, &_sharedRxAppStateKey) as? _SharedRxAppState {
                return stored
            }
            let defaultValue = _SharedRxAppState(self)
            self._sharedRxAppState = defaultValue
            return defaultValue
        }
        set {
            objc_setAssociatedObject(self, &_sharedRxAppStateKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension RxAppState {
    /**
     For testing purposes
     */
    internal static func clearSharedObservables() {
        objc_setAssociatedObject(UIApplication.shared,
                                 &_sharedRxAppStateKey,
                                 nil,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
