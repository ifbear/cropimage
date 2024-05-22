//
//  OCRTools.swift
//  OCR
//
//  Created by dexiong on 2024/3/25.
//

import UIKit
import Foundation
import Vision
import Alamofire


enum Mode {
    case system
    case aliyun
}

class OCRTool {
    
    internal static let shared: OCRTool = .init()
    
    
    internal func recognize(url: URL, mode: Mode, callbackQueue: DispatchQueue? = nil, complationHandler: @escaping (String?) -> Void) throws {
        switch mode {
        case .system:
            let request = VNRecognizeTextRequest {  request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                for observation in observations {
                    if let text = observation.topCandidates(1).first,
                       let range: Range<String.Index> = text.string.range(of: text.string),
                        let box = try? text.boundingBox(for: range) {
                        print("String coordinates for \"\(text.string)\":")
                                    print("\tTop left: \(box.topLeft)")
                                    print("\tTop right: \(box.topRight)")
                                    print("\tBottom left: \(box.bottomLeft)")
                                    print("\tBottom right: \(box.bottomRight)")
                    }
                }
                let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined()

                print(text)
                if let callbackQueue = callbackQueue {
                    callbackQueue.async {
                        complationHandler(text)
                    }
                } else {
                    complationHandler(text)
                }
            }
            request.progressHandler = { _, progress, _ in
                print(progress)
            }
            request.recognitionLevel = .accurate
            if #available(iOS 16.0, *) {
                request.automaticallyDetectsLanguage = true
            }
            guard let cgImage = UIImage(contentsOfFile: url.path)?.cgImage else { return }
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
            
        case .aliyun:
            guard let dataStr = try? Data(contentsOf: url).base64EncodedString() else { return }
            AF.request("https://shouxiegen.market.alicloudapi.com/ocrservice/shouxie", method: .post, parameters: [
                "img": dataStr,
                //是否需要识别结果中每一行的置信度，默认不需要。 true：需要 false：不需要
                "prob": false,
                //是否需要单字识别功能，默认不需要。 true：需要 false：不需要
                "charInfo": false,
                //是否需要自动旋转功能，默认不需要。 true：需要 false：不需要
                "rotate": false,
                //是否需要表格识别功能，默认不需要。 true：需要 false：不需要
                "table": false,
                //字块返回顺序，false表示从左往右，从上到下的顺序，true表示从上到下，从左往右的顺序，默认false
                "sortPage": false
            ], encoding: JSONEncoding.default, headers: .init([
                .init(name: "Authorization", value: "APPCODE f2ff584e388b4ca9a8c81ad51f9dd552"),
                .init(name: "Content-Type", value: "application/json; charset=UTF-8")
            ])).response { response in
                guard let data = response.data,
                      let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                      let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                      let text = String(data: jsonData, encoding: .utf8)  else { return }
                print(text)
                if let callbackQueue = callbackQueue {
                    callbackQueue.async {
                        complationHandler(text)
                    }
                } else {
                    complationHandler(text)
                }
            }
//            AF.request("https://gjbsb.market.alicloudapi.com/ocrservice/advanced", method: .post, parameters: [
//                "img": dataStr,
//                //是否需要识别结果中每一行的置信度，默认不需要。 true：需要 false：不需要
//                "prob": false,
//                //是否需要单字识别功能，默认不需要。 true：需要 false：不需要
//                "charInfo": false,
//                //是否需要自动旋转功能，默认不需要。 true：需要 false：不需要
//                "rotate": false,
//                //是否需要表格识别功能，默认不需要。 true：需要 false：不需要
//                "table": false,
//                //字块返回顺序，false表示从左往右，从上到下的顺序，true表示从上到下，从左往右的顺序，默认false
//                "sortPage": false,
//                //是否需要去除印章功能，默认不需要。true：需要 false：不需要
//                "noStamp": false,
//                //是否需要图案检测功能，默认不需要。true：需要 false：不需要
//                "figure": false,
//                //是否需要成行返回功能，默认不需要。true：需要 false：不需要
//                "row": false,
//                //是否需要分段功能，默认不需要。true：需要 false：不需要
//                "paragraph": false,
//                // 图片旋转后，是否需要返回原始坐标，默认不需要。true：需要  false：不需要
//                "oricoord": true
//            ], encoding: JSONEncoding.default, headers: .init([
//                .init(name: "Authorization", value: "APPCODE f2ff584e388b4ca9a8c81ad51f9dd552"),
//                .init(name: "Content-Type", value: "application/json; charset=UTF-8")
//            ])).response { response in
//                guard let data = response.data,
//                      let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
//                      let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
//                      let text = String(data: jsonData, encoding: .utf8)  else { return }
//                print(text)
//                if let callbackQueue = callbackQueue {
//                    callbackQueue.async {
//                        complationHandler(text)
//                    }
//                } else {
//                    complationHandler(text)
//                }
//            }
        }
        
    }
}
