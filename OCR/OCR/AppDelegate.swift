//
//  AppDelegate.swift
//  OCR
//
//  Created by dexiong on 2024/3/25.
//

import UIKit
import CoreGraphics

func convertPointFromUIKitToCoreImage(point: CGPoint, imageSize: CGSize) -> CGPoint {
    // 创建一个仿射变换，用于将 UIKit 坐标转换为 Core Image 坐标
    let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -imageSize.height)
    
    // 将 UIKit 坐标转换为 Core Image 坐标
    return point.applying(transform)
}

func convertPointFromCoreImageToUIKit(point: CGPoint, imageSize: CGSize) -> CGPoint {
    // 创建一个仿射变换，用于将 Core Image 坐标转换为 UIKit 坐标
    let transform = CGAffineTransform(translationX: 0, y: imageSize.height).scaledBy(x: 1, y: -1)
    
    // 将 Core Image 坐标转换为 UIKit 坐标
    return point.applying(transform)
}


@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // UIKit 坐标转 Core Image 坐标
        let uiPoint = CGPoint(x: 100, y: 200)
        let imageSize = CGSize(width: 300, height: 400)
        let coreImagePoint = uiPoint.convert(for: imageSize, scaleBy: 1) // convertPointFromUIKitToCoreImage(point: uiPoint, imageSize: imageSize)
        print(coreImagePoint)
        // Core Image 坐标转 UIKit 坐标
        let anotherPoint = coreImagePoint.convert(for: imageSize, scaleBy: 1) //convertPointFromCoreImageToUIKit(point: coreImagePoint, imageSize: imageSize)
        print(anotherPoint)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

