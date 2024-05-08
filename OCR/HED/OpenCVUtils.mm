//
//  OpenCVUtils.m
//  OCR
//
//  Created by dexiong on 2024/5/7.
//

#import "OpenCVUtils.h"
#import <opencv2/highgui/cap_ios.h>
#import <FMHEDNet/FMHEDNet.h>
#import <FMHEDNet/fm_ocr_scanner.hpp>
#import "OpenCVUtils+Extensions.h"
#import <opencv2/core/version.hpp>



@interface OpenCVUtils ()

@property (nonatomic, strong) FMHEDNet *hedNet;

@end

@implementation OpenCVUtils

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"hed_graph" ofType:@"pb"];
        _hedNet = [[FMHEDNet alloc] initWithModelPath:path];
    }
    return self;
}

/// processUIImage
/// - Parameters:
///   - uiImage: UIImage
///   - block: ComplationBlock
- (void)processUIImage: (UIImage *)uiImage callbackQueue:(nonnull dispatch_queue_t)callbackQueue complationBlock:(nonnull ComplationBlock)block {
    cv::Mat cvImage = [OpenCVUtils cvMatFromUIImage:uiImage];
    [self processCVImage: cvImage callbackQueue:callbackQueue complation:block];
}

/// processCVImageBuffer
/// - Parameters:
///   - sampleBuffer: CMSampleBufferRef
///   - callbackQueue: dispatch_queue_t
///   - block: ComplationBlock
- (void)processCVImageBuffer: (CMSampleBufferRef)sampleBuffer callbackQueue:(nonnull dispatch_queue_t)callbackQueue complationBlock:(nonnull ComplationBlock)block {
    
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    
    //Processing here
    size_t bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
    size_t bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
    unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    // put buffer in open cv, no memory copied
    cv::Mat mat = cv::Mat((int)bufferHeight, (int)bufferWidth, CV_8UC4, pixel);
    
    //End processing
    CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
    [self processCVImage: mat callbackQueue:callbackQueue complation:block];
    
}

/// processCVImage
/// - Parameters:
///   - bgraImage: bgraImage
///   - block: ComplationBlock
- (void)processCVImage:(cv::Mat&)bgraImage callbackQueue:(nonnull dispatch_queue_t)callbackQueue complation: (ComplationBlock)block {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    /**
     https://stackoverflow.com/questions/10167534/how-to-find-out-what-type-of-a-mat-object-is-with-mattype-in-opencv
     
     +--------+----+----+----+----+------+------+------+------+
     |        | C1 | C2 | C3 | C4 | C(5) | C(6) | C(7) | C(8) |
     +--------+----+----+----+----+------+------+------+------+
     | CV_8U  |  0 |  8 | 16 | 24 |   32 |   40 |   48 |   56 |
     | CV_8S  |  1 |  9 | 17 | 25 |   33 |   41 |   49 |   57 |
     | CV_16U |  2 | 10 | 18 | 26 |   34 |   42 |   50 |   58 |
     | CV_16S |  3 | 11 | 19 | 27 |   35 |   43 |   51 |   59 |
     | CV_32S |  4 | 12 | 20 | 28 |   36 |   44 |   52 |   60 |
     | CV_32F |  5 | 13 | 21 | 29 |   37 |   45 |   53 |   61 |
     | CV_64F |  6 | 14 | 22 | 30 |   38 |   46 |   54 |   62 |
     +--------+----+----+----+----+------+------+------+------+
     */
    
    /**
     2018-04-17 16:56:22.993532+0800 DemoWithStaticLib[945:184826] ___log_OpenCV_info___, rawBgraImage.type() is: 24
     2018-04-17 16:56:22.995671+0800 DemoWithStaticLib[945:184826] ___log_OpenCV_info___, hedSizeOriginalImage.type() is: 24
     2018-04-17 16:56:22.995895+0800 DemoWithStaticLib[945:184826] ___log_OpenCV_info___, rgbImage.type() is: 16
     2018-04-17 16:56:22.996490+0800 DemoWithStaticLib[945:184826] ___log_OpenCV_info___, floatRgbImage.type() is: 21
     2018-04-17 16:56:23.082157+0800 DemoWithStaticLib[945:184826] ___log_OpenCV_info___, hedOutputImage.type() is: 5
     */
    
    cv::Mat& rawBgraImage = bgraImage;
    
    assert(rawBgraImage.type() == CV_8UC4);
    
    
    // resize rawBgraImage HED Net size
    int height = [FMHEDNet inputImageHeight];
    int width = [FMHEDNet inputImageWidth];
    cv::Size size(width, height);
    cv::Mat hedSizeOriginalImage;
    cv::resize(rawBgraImage, hedSizeOriginalImage, size, 0, 0, cv::INTER_LINEAR);
    assert(hedSizeOriginalImage.type() == CV_8UC4);
    
    
    // convert from BGRA to RGB
    cv::Mat rgbImage;
    cv::cvtColor(hedSizeOriginalImage, rgbImage, cv::COLOR_BGRA2RGB);
    assert(rgbImage.type() == CV_8UC3);
    
    
    // convert pixel type from int to float, and value range from (0, 255) to (0.0, 1.0)
    cv::Mat floatRgbImage;
    /**
     void convertTo( OutputArray m, int rtype, double alpha=1, double beta=0 ) const;
     */
    rgbImage.convertTo(floatRgbImage, CV_32FC3, 1.0 / 255);
    /**
     floatRgbImage 是归一化处理后的矩阵，
     如果使用 VGG style HED，并且没有使用 batch norm 技术，那就不需要做归一化处理，
     而是参照 VGG 的使用惯例，减去像素平均值，类似下面的代码
     //http://answers.opencv.org/question/59529/how-do-i-separate-the-channels-of-an-rgb-image-and-save-each-one-using-the-249-version-of-opencv/
     //http://opencvexamples.blogspot.com/2013/10/split-and-merge-functions.html
     const float R_MEAN = 123.68;
     const float G_MEAN = 116.78;
     const float B_MEAN = 103.94;
     
     cv::Mat rgbChannels[3];
     cv::split(floatRgbImage, rgbChannels);
     
     rgbChannels[0] = rgbChannels[0] - R_MEAN;
     rgbChannels[1] = rgbChannels[1] - G_MEAN;
     rgbChannels[2] = rgbChannels[2] - B_MEAN;
     
     std::vector<cv::Mat> channels;
     channels.push_back(rgbChannels[0]);
     channels.push_back(rgbChannels[1]);
     channels.push_back(rgbChannels[2]);
     
     cv::Mat vggStyleImage;
     cv::merge(channels, vggStyleImage);
     */
    
    
    // run hed net
    cv::Mat hedOutputImage;
    NSError *error;
    
    if ([self.hedNet processImage:floatRgbImage outputImage:hedOutputImage error:&error]) {
        
        auto tuple = ProcessEdgeImage(hedOutputImage, rgbImage, false);
        
        auto find_rect = std::get<0>(tuple);
        auto cv_points = std::get<1>(tuple);
        auto debug_mats = std::get<2>(tuple);
        
        if (find_rect == true) {
            std::vector<cv::Point> scaled_points;
            int original_height, original_width;
            original_height = rawBgraImage.rows;
            original_width = rawBgraImage.cols;
            
            for(int i = 0; i < cv_points.size(); i++) {
                cv::Point cv_point = cv_points[i];
                
                cv::Point scaled_point = cv::Point(cv_point.x * original_width / [FMHEDNet inputImageWidth], cv_point.y * original_height / [FMHEDNet inputImageHeight]);
                scaled_points.push_back(scaled_point);
                /** convert from cv::Point to CGPoint
                 CGPoint point = CGPointMake(scaled_point.x, scaled_point.y);
                 */
            }
            UIImage *image = [OpenCVUtils UIImageFromCVMat:rawBgraImage];
            if (block) {
                dispatch_async(callbackQueue, ^{
                    block(@[
                        [NSValue valueWithCGPoint:CGPointMake(scaled_points[0].x, scaled_points[0].y)],
                        [NSValue valueWithCGPoint:CGPointMake(scaled_points[1].x, scaled_points[1].y)],
                        [NSValue valueWithCGPoint:CGPointMake(scaled_points[2].x, scaled_points[2].y)],
                        [NSValue valueWithCGPoint:CGPointMake(scaled_points[3].x, scaled_points[3].y)]
                    ], image);
                });
            }
            
            //            cv::line(rawBgraImage, scaled_points[0], scaled_points[1], CV_RGB(255, 0, 0), 2);
            //            cv::line(rawBgraImage, scaled_points[1], scaled_points[2], CV_RGB(255, 0, 0), 2);
            //            cv::line(rawBgraImage, scaled_points[2], scaled_points[3], CV_RGB(255, 0, 0), 2);
            //            cv::line(rawBgraImage, scaled_points[3], scaled_points[0], CV_RGB(255, 0, 0), 2);
        } else {
            if (block) {
                dispatch_async(callbackQueue, ^{
                    block(nil, nil);
                });
            }
        }
    } else {
        if (block) {
            dispatch_async(callbackQueue, ^{
                block(nil, nil);
            });
        }
    }
}

@end
