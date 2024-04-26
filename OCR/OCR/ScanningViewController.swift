//
//  ScanningViewController.swift
//  OCR
//
//  Created by dexiong on 2024/4/22.
//

import UIKit

class ScanningViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let controller: DDCameraViewController = .init()
        let navi: UINavigationController = .init(rootViewController: controller)
        navi.modalPresentationStyle = .fullScreen
        present(navi, animated: true)
    }

}
