//
//  HEDNetViewController.swift
//  OCR
//
//  Created by dexiong on 2024/4/30.
//

import UIKit

class HEDNetViewController: UIViewController {
    
    private lazy var imageView1: UIImageView = {
        let _imageView: UIImageView = .init()
        
        return _imageView
    }()
    private lazy var imageView2: UIImageView = {
        let _imageView: UIImageView = .init()
        
        return _imageView
    }()
    private lazy var imageView3: UIImageView = {
        let _imageView: UIImageView = .init()
        
        return _imageView
    }()
    private lazy var imageView4: UIImageView = {
        let _imageView: UIImageView = .init()
        
        return _imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(imageView1)
        imageView1.snp.makeConstraints {
            $0.left.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.width.equalToSuperview().multipliedBy(0.4)
        }
        
        view.addSubview(imageView2)
        imageView2.snp.makeConstraints {
            $0.right.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.width.equalToSuperview().multipliedBy(0.4)
        }
        
        view.addSubview(imageView3)
        imageView3.snp.makeConstraints {
            $0.left.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.width.equalToSuperview().multipliedBy(0.4)
        }
        
        view.addSubview(imageView4)
        imageView4.snp.makeConstraints {
            $0.right.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.width.equalToSuperview().multipliedBy(0.4)
        }
    }
    
}
