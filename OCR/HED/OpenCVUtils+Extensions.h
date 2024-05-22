//
//  OpenCVUtils+Extensions.h
//  OCR
//
//  Created by dexiong on 2024/5/7.
//

#import <opencv2/opencv.hpp>
#import <UIKit/UIKit.h>
#import "OpenCVUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVUtils (Extensions)

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
