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

/// processUIImage
/// - Parameters:
///   - uiImage: UIImage
///   - callbackQueue: dispatch_queue_t
///   - block: ComplationBlock
- (void)processUIImage: (UIImage *)uiImage callbackQueue: (nonnull dispatch_queue_t)callbackQueue complationBlock: (ComplationBlock)block;


/// processCVImageBuffer
/// - Parameters:
///   - sampleBuffer: CMSampleBufferRef
///   - callbackQueue: dispatch_queue_t
///   - block: ComplationBlock
- (void)processCVImageBuffer: (CMSampleBufferRef)sampleBuffer callbackQueue: (nonnull dispatch_queue_t)callbackQueue complationBlock: (ComplationBlock)block;

@end

NS_ASSUME_NONNULL_END
