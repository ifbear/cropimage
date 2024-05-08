//
//  DDNavigationController.swift
//  OCR
//
//  Created by dexiong on 2024/5/8.
//

import UIKit

class DDNavigationController: UINavigationController {
    
    /// [DDCropModel]
    internal var cropModels: [DDCropModel] = []
    
    internal override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        modalPresentationStyle = .fullScreen
        let buttonAppearance: UIBarButtonItemAppearance = .init(style: .plain)
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let appearance: UINavigationBarAppearance = .init()
        appearance.configureWithOpaqueBackground()
        appearance.buttonAppearance = buttonAppearance
        appearance.backButtonAppearance = buttonAppearance

        navigationBar.standardAppearance = appearance
        navigationBar.tintColor = UIColor.white
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print(#function, #file.hub.lastPathComponent)
    }
}
