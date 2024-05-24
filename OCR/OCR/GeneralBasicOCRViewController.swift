//
//  GeneralBasicOCRViewController.swift
//  OCR
//
//  Created by dexiong on 2024/5/23.
//

import UIKit
import PhotosUI
import Vision
import Alamofire
import CryptoKit
import AlibabacloudOpenApi
import AlibabacloudOcrApi20210707


class GeneralBasicOCRViewController: BaseOCRViewController {
    
    internal override func tencentHandler(with image: UIImage) {
        guard let base64 = image.jpegData(compressionQuality: 0.75)?.base64EncodedString() else { return }
        
        let action = "GeneralBasicOCR"
        let region = "ap-beijing"
        let version = "2018-11-19"
        let timestamp = Int(Date().timeIntervalSince1970)
        
        let parameters: [String: Any] = [
            "ImageBase64": base64
        ]
        
        var headers = HTTPHeaders.default
        headers.add(name: "x-acs-action", value: action)
        headers.add(name: "X-TC-Region", value: region)
        headers.add(name: "x-acs-date", value: "\(timestamp)")
        headers.add(name: "x-acs-version", value: version)
        headers.add(name: "x-acs-signature-nonce", value: "\(Date().timeIntervalSince1970)\(UUID().uuidString)".md5())
        headers.add(name: "Content-Type", value: "application/json; charset=utf-8")
        headers.add(name: "Authorization", value: tencentAuthorization(for: "ocr", region: region, action: action, version: version, timestamp: timestamp, parameters: parameters))
        AF.request("https://ocr.tencentcloudapi.com", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseDecodable(of: TencentGeneralResponse.self) { response in
                guard let textDetections = response.value?.Response.TextDetections else { return }
                var text: String = ""
                textDetections.forEach { detection in
                    text.append(detection.DetectedText + "\n")
                }
                self.tencentResultView.text = text
            }
    }
    
    internal override func aliHandler(with image: UIImage) async {
        guard let alibabaClient = alibabaClient, let data = image.jpegData(compressionQuality: 0.75) else { return }
        do {
            let request: RecognizeGeneralRequest = .init()
            request.body = .init(data: data)
            guard let string = try await alibabaClient.recognizeGeneral(request).body?.data, let data = string.data(using: .utf8) else { return }
            let model = try JSONDecoder().decode(AlibabaGeneralModel.self, from: data)
            var _text: String = ""
            model.prism_wordsInfo.forEach { wordinfo in
                _text.append(wordinfo.word + "\n")
            }
            
            aliResultView.text = _text
            print(string)
        } catch {
            print(error)
        }
    }
}

