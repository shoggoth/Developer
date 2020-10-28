//
//  RevisionApp.swift
//  Shared
//
//  Created by Richard Henry on 28/06/2020.
//

import SwiftUI

@main struct RevisionApp: App {

    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        print("This is how to restore the app delegate behaviour for \(application).")
        
        return true
    }
}
#endif

struct RevisionApp_Previews: PreviewProvider {
    
    static var previews: some View { ContentView() }
}
