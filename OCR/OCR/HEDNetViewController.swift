//
//  HEDNetViewController.swift
//  OCR
//
//  Created by dexiong on 2024/4/30.
//

import UIKit

class HEDNetViewController: UIViewController {
    
    let image: UIImage = .init(named: "IMG_3213.jpg")!
    
    private lazy var imageView1: UIImageView = {
        let _imageView: UIImageView = .init()
        _imageView.image = image
        return _imageView
    }()
    
    private lazy var openCVUtils: OpenCVUtils = .init()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView1)
        imageView1.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        openCVUtils.processUIImage(image) { values, image in
            guard let values = values else { return }
            let p1 = values[0].cgPointValue
            let p2 = values[1].cgPointValue
            let p3 = values[2].cgPointValue
            let p4 = values[3].cgPointValue
            
            let _image = image?.drawBezierPath(with: [p1, p2, p3, p4])
            self.imageView1.image = _image
        }
    }
    
}
