//
//  AlibabaGeneralModel.swift
//  OCR
//
//  Created by dexiong on 2024/5/23.
//

import Foundation

struct Pos: Decodable {
    internal let x: Int
    internal let y: Int
}

struct PrismWordsInfo: Decodable {
    internal let angle: Int // 文字块的角度。
    internal let direction: Int
    internal let height: Int // 算法矫正图片后的高度。
    internal let width: Int // 算法矫正图片后的宽度。
    internal let prob: Int
    internal let word: String // 文字块的文字内容。
    internal let x: Int
    internal let y: Int
    internal let pos: [Pos] // 文字块的外矩形四个点的坐标按顺时针排列（左上、右上、右下、左下）。
}


struct AlibabaGeneralModel: Decodable {
    internal let algo_version: String
    internal let content: String // 识别出图片的文字块汇总。
    internal let height: Int // 算法矫正图片后的高度。
    internal let width: Int // 算法矫正图片后的宽度。
    internal let orgHeight: Int // 原图的高度。
    internal let orgWidth: Int // 原图的宽度。
    internal let prism_version: String
    internal let prism_wnum: Int // 识别的文字块的数量，prism_wordsInfo 数组的大小。
    internal let prism_wordsInfo: [PrismWordsInfo] // 文字块信息。
}
