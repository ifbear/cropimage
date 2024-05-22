//
//  TFHelper.h
//  Demo
//
//  Created by zjcneil on 2019/1/30.
//  Copyright © 2019 zjcneil. All rights reserved.
//

#include <vector>
#import <opencv2/opencv.hpp>

#include "tensorflow_lite/tensorflow/lite/kernels/register.h"
#include "tensorflow_lite/tensorflow/lite/model.h"

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ComplationBlock)(UIImage  * _Nullable origin, UIImage  * _Nullable crop, NSArray<NSValue *>  * _Nullable  points);

@interface TFHelper : NSObject {
    std::unique_ptr<tflite::FlatBufferModel> model;
    std::unique_ptr<tflite::Interpreter> interpreter;
    tflite::ops::builtin::BuiltinOpResolver resolver;
}

//- (BOOL) inferImage:(const cv::Mat &)inputImage
//        resultImage:(cv::Mat&)result
//            heatmap:(cv::Mat&)heatmap;
//
//- (void) rectifyReceipt:(cv::Mat&) resultMat;



- (NSArray<NSValue *> *)inferWithImage: (UIImage *)inputImage;

- (NSArray<NSValue *> *)inferWithImageBuffer: (CMSampleBufferRef)sampleBuffer;

- (void)capture: (ComplationBlock)complation;

@end

NS_ASSUME_NONNULL_END
