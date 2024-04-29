//
//  FMHEDNet.swift
//  OCR
//
//  Created by dexiong on 2024/4/29.
//

import Foundation
import TensorFlowLite
import CoreVideo
import CoreImage

class FMHEDNet {
    private var interpreter: Interpreter
    
    internal init(model path: String) throws {
        interpreter = try Interpreter(modelPath: path)
        try interpreter.allocateTensors()
    }
    
    func runModel(onFrame pixelBuffer: CVPixelBuffer) {
        
    }
}


