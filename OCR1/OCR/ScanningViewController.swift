//
//  ScanningViewController.swift
//  OCR
//
//  Created by dexiong on 2024/4/22.
//

import UIKit
import Foundation

class ScanningViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        DDCameraViewController.showDocumentDetectController(at: self) { urls in
            print(urls)
        }
    }

}
