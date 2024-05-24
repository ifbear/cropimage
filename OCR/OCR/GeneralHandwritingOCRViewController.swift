//
//  GeneralHandwritingOCRViewController.swift
//  OCR
//
//  Created by dexiong on 2024/5/23.
//

import UIKit
import Alamofire
import CryptoKit
import AlibabacloudOpenApi
import AlibabacloudOcrApi20210707


class GeneralHandwritingOCRViewController: BaseOCRViewController {

    internal override func aliHandler(with image: UIImage) async {
        guard let alibabaClient = alibabaClient, let data = image.jpegData(compressionQuality: 0.75) else { return }
        do {
            let request: RecognizeHandwritingRequest = .init()
            request.body = .init(data: data)
            guard let string = try await alibabaClient.recognizeHandwriting(request).body?.data, let data = string.data(using: .utf8) else { return }
            let model = try JSONDecoder().decode(AlibabaGeneralModel.self, from: data)
            aliResultView.text = model.content
            print(string)
        } catch {
            print(error)
        }
    }
    
    internal override func tencentHandler(with image: UIImage) {
        guard let base64 = image.jpegData(compressionQuality: 0.75)?.base64EncodedString() else { return }
        
        let action = "GeneralHandwritingOCR"
        let region = "ap-beijing"
        let version = "2018-11-19"
        let timestamp = Int(Date().timeIntervalSince1970)
        
        let parameters: [String: Any] = [
            "ImageBase64": base64
        ]
        
        var headers = HTTPHeaders.default
        headers.add(name: "X-TC-Action", value: action)
        headers.add(name: "X-TC-Region", value: region)
        headers.add(name: "X-TC-Timestamp", value: "\(timestamp)")
        headers.add(name: "X-TC-Version", value: version)
        headers.add(name: "Content-Type", value: "application/json; charset=utf-8")
        headers.add(name: "Authorization", value: tencentAuthorization(for: "ocr", region: region, action: action, version: version, timestamp: timestamp, parameters: parameters))
        AF.request("https://ocr.tencentcloudapi.com", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseDecodable(of: TencentHandWritingResponse.self) { response in
                guard let textDetections = response.value?.Response.TextDetections else { return }
                var text: String = ""
                textDetections.forEach { detection in
                    text.append(detection.DetectedText + "\n")
                }
                self.tencentResultView.text = text
            }
    }
}
