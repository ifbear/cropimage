//
//  OpenCVUtils.h
//  OCR
//
//  Created by dexiong on 2024/5/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ComplationBlock)(NSArray<NSValue *> * _Nullable, UIImage * _Nullable);

@interface OpenCVUtils : NSObject

- (void)processUIImage: (UIImage *)uiImage complation: (ComplationBlock)block;

- (void)processCVImageBuffer: (CMSampleBufferRef)sampleBuffer complation: (ComplationBlock)block;

@end

NS_ASSUME_NONNULL_END
