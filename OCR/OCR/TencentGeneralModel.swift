//
//  TencentGeneralModel.swift
//  OCR
//
//  Created by dexiong on 2024/5/23.
//

import Foundation

struct ItemCoord: Decodable {
    internal let X: Int
    internal let Y: Int
    internal let Width: Int
    internal let Height: Int
}

struct Coord: Decodable {
    internal let X: Int
    internal let Y: Int
}

struct DetectedWords: Decodable {
    internal let Confidence: Int
    internal let Character: String
}

struct DetectedWordCoordPoint: Decodable {
    internal let WordCoordinate: [Coord]
}

struct TextDetection: Decodable {
    internal let DetectedText: String // 识别出的文本行内容
    internal let Confidence: Int // 置信度 0 ~100
    internal let Polygon: [Coord] // 文本行坐标，以四个顶点坐标表示 注意：此字段可能返回 null，表示取不到有效值。
    internal let AdvancedInfo: String // 此字段为扩展字段。  GeneralBasicOcr接口返回段落信息Parag，包含ParagNo。
    internal let ItemPolygon: ItemCoord // 文本行在旋转纠正之后的图像中的像素坐标，表示为（左上角x, 左上角y，宽width，高height）
    internal let Words: [DetectedWords] // 识别出来的单字信息包括单字（包括单字Character和单字置信度confidence）， 支持识别的接口：GeneralBasicOCR、GeneralAccurateOCR
    internal let WordCoordPoint: [DetectedWordCoordPoint] // 单字在原图中的四点坐标， 支持识别的接口：GeneralBasicOCR、GeneralAccurateOCR
}

struct TencentGeneralModel: Decodable {
    internal let TextDetections: [TextDetection]
    internal let Language: String// 检测到的语言类型，目前支持的语言类型参考入参LanguageType说明。
    internal let PdfPageSize: Int //图片为PDF时，返回PDF的总页数，默认为0
    internal let Angle: Float // 图片旋转角度（角度制），文本的水平方向为0°；顺时针为正，逆时针为负。点击查看如何纠正倾斜文本
    internal let RequestId: String // 唯一请求 ID，由服务端生成，每次请求都会返回（若请求因其他原因未能抵达服务端，则该次请求不会获得 RequestId）。定位问题时需要提供该次请求的 RequestId。
}

struct TencentGeneralResponse: Decodable {
    internal let Response: TencentGeneralModel
}



//MARK: - 手写体

struct Polygon: Decodable {
    internal let LeftTop: Coord
    internal let RightTop: Coord
    internal let RightBottom: Coord
    internal let LeftBottom: Coord
}

struct TextGeneralHandwriting: Decodable {
    internal let DetectedText: String
    internal let Confidence: Int
    internal let Polygon: [Coord]
    internal let AdvancedInfo: String
    internal let WordPolygon: [Polygon]
}

struct TextHandwritingModel: Decodable {
    internal let TextDetections: [TextGeneralHandwriting]
    internal let Angle: Float // 图片旋转角度（角度制），文本的水平方向为0°；顺时针为正，逆时针为负。点击查看如何纠正倾斜文本
    internal let RequestId: String // 唯一请求 ID，由服务端生成，每次请求都会返回（若请求因其他原因未能抵达服务端，则该次请求不会获得 RequestId）。定位问题时需要提供该次请求的 RequestId。
}

struct TencentHandWritingResponse: Decodable {
    internal let Response: TextHandwritingModel
}
