//
//  AppDelegate.swift
//  Remove Polyline When Object Move
//
//  Created by Sandip Gill on 10/15/20.
//  Copyright © 2020 apptunix. All rights reserved.
//
var googleKey = "AIzaSyBEACOIxlaj4MrN9-XcAHFQctWCfe_gYN8"

import UIKit
import GooglePlaces
import GoogleMaps
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window : UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSPlacesClient.provideAPIKey(googleKey)
             GMSServices.provideAPIKey(googleKey)
        if #available(iOS 13.0, *) {
             // In iOS 13 setup is done in SceneDelegate
           } else {
             let window = UIWindow(frame: UIScreen.main.bounds)
             self.window = window
                    let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
               let newViewcontroller:UIViewController = mainstoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
             let nav = UINavigationController(rootViewController: newViewcontroller)
               window.rootViewController = nav
           }
        return true
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
                  return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
       
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

