//
//  OpenCVWrapper.h
//  OCR
//
//  Created by dexiong on 2024/4/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

- (NSArray<NSValue *> *)minimumBoundingRectangleVertices:(NSArray<NSValue *> *) points;

+ (UIImage *)Canny:(UIImage *)uiImage;

+ (UIImage *)change:(UIImage *)image;

+ (UIImage *)imgcorr: (UIImage *)uiImage;

+ (UIImage *)imageEdge: (UIImage *)uiImage ;

+ (UIImage *)contours: (UIImage *)uiImage;


@end

NS_ASSUME_NONNULL_END
