//
//  MultipleSelectionViewController.swift
//  OCR
//
//  Created by dexiong on 2024/4/24.
//

import UIKit
import PanModal

class MultipleSelectionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let controller: DDOcrResultsViewController = .init()
        presentPanModal(controller)
    }
}
