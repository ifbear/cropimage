//
//  OpenCVWrapper.m
//  OCR
//
//  Created by dexiong on 2024/4/11.
//

#include <opencv2/opencv.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/imgproc/imgproc.hpp>

#import <opencv2/imgcodecs/ios.h>//MatToUIImage、MatToUIImage用到
#import <opencv2/imgproc.hpp>//cv::域名下的东西会用到
#import <opencv2/highgui.hpp>

#import "OpenCVWrapper.h"

@interface OpenCVWrapper()


@end

@implementation OpenCVWrapper

- (NSArray<NSValue *> *)minimumBoundingRectangleVertices:(NSArray<NSValue *> *) points {
    std::vector<cv::Point2f> _points;
    for (NSValue *value in points) {
        _points.push_back(cv:: Point2f(value.CGPointValue.x, value.CGPointValue.y));
    }
    // 使用 OpenCV 计算最小外接矩形
    cv::RotatedRect rect = cv::minAreaRect(_points);
    // 获取最小外接矩形的四个顶点
    cv::Point2f vertices[4];
    rect.points(vertices);
    NSMutableArray *results = @[].mutableCopy;
    for (int i = 0; i < 4; ++i) {
        [results addObject:[NSValue valueWithCGPoint:CGPointMake(vertices[i].x, vertices[i].y)]];
    }
    return results.copy;
}


+ (UIImage *)Canny:(UIImage *)uiImage {
    @try {
        // 读取图片
        cv::Mat cvImage;
        UIImageToMat(uiImage, cvImage);
        if (cvImage.empty()) {
            return nil;
        }
        cv::Mat gray;
        cv::cvtColor(cvImage, gray, cv::COLOR_BGR2GRAY);
        
        // 使用 Canny 边缘检测器
        cv::Mat edges;
        cv::Canny(gray, edges, 50, 150, 3);
        
        // 轮廓检测
        std::vector<std::vector<cv::Point>> contours;
        cv::findContours(edges, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);
        
        // 筛选轮廓
        std::vector<std::vector<cv::Point>> filteredContours;
        for (const auto& contour : contours) {
            double area = cv::contourArea(contour);
            if (area > 1000 && area < 100000) { // 根据需要调整面积阈值
                filteredContours.push_back(contour);
            }
        }
        
        // 逼近边缘
        std::vector<std::vector<cv::Point>> approxContours(filteredContours.size());
        for (size_t i = 0; i < filteredContours.size(); i++) {
            cv::approxPolyDP(filteredContours[i], approxContours[i], 10, true);
        }
        
        // 绘制结果
        cv::Mat result = cvImage.clone();
        cv::Scalar color(0, 0, 0); // 绘制红色
        for (const auto& contour : approxContours) {
            cv::drawContours(result, std::vector<std::vector<cv::Point>>{contour}, 0, color, 2);
        }
        return  MatToUIImage(result);
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
    
}

+ (UIImage *)change:(UIImage *)image {
    cv::Mat cvImage;
    UIImageToMat(image, cvImage);
    if (cvImage.empty()) {
        return nil;
    }
    cv::Mat copImage = cvImage.clone();
    cv::Mat shrinkPic;
    cv::pyrDown(cvImage, shrinkPic);
    
    int shrinkCount = (image.size.width / 500);
    int multi = 2;
    if (shrinkCount > 1) {
        shrinkCount = shrinkCount / 2;
        multi = pow(2, shrinkCount + 1);
        for (int i = 0; i < shrinkCount; i++) {
            cv::pyrDown(shrinkPic, shrinkPic);
        }
    }
    
    cv::Mat greyPic, sobPic,enhancePic, threshPic;
    
    cv::cvtColor(shrinkPic, greyPic, cv::COLOR_RGBA2GRAY);
    
    // 边缘直方图法，采用sobel算子提取边缘线，然后水平，垂直分别做直方图
    cv::Mat grabX, grabY;
    cv::Sobel(greyPic, grabX, CV_32F, 1, 0);
    cv::Sobel(greyPic, grabY, CV_32F, 0, 1);
    cv::subtract(grabX, grabY, sobPic);
    cv::convertScaleAbs(sobPic, sobPic);
    
    // 填充空白区域，增强对比度
    cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(25, 25));
    cv::morphologyEx(sobPic, enhancePic, cv::MORPH_CLOSE, kernel);
    
    // 去除噪声
    cv::blur(sobPic, threshPic, cv::Size(5,5));
    cv::threshold(threshPic, threshPic, 30, 255, cv::THRESH_BINARY);//90
    
    //    return MatToUIImage(threshPic);
    
    // 找出轮廓区域
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    cv::findContours(threshPic, contours, hierarchy, cv::RETR_CCOMP, cv::CHAIN_APPROX_SIMPLE);
    
    // 求所有形状的最小外接矩形中最大的一个
    cv::RotatedRect box;
    for( int i = 0; i < contours.size(); i++ ){
        cv::RotatedRect rect = cv::minAreaRect( cv::Mat(contours[i]) );
        if (box.size.width < rect.size.width) {
            box = rect;
        }
    }
    
    {
        // 画出来矩形和4个点, 供调试。此部分代码可以不要
        cv::Mat drawing = cv::Mat::zeros(threshPic.rows, threshPic.cols, CV_8UC3);
        cv::Scalar color = cv::Scalar( rand() & 255, rand() & 255, rand() & 255 );
        cv::Point2f rect_points[4];
        box.points( rect_points );
        for ( int j = 0; j < 4; j++ )
        {
            line( drawing, rect_points[j], rect_points[(j+1)%4], color );
            circle(drawing, rect_points[j], 10, color, 2);
        }
        //        return MatToUIImage(drawing);
    }
    
    // 仿射变换
    cv::Point2f corners[4], canvas[4], tmp[4];
    
    // 固定输出尺寸，可以由外部传入
    cv::Size real_size = cv::Size(image.size.width, image.size.height);
    
    canvas[0] = cv::Point2f(0, 0);
    canvas[1] = cv::Point2f(real_size.width, 0);
    canvas[2] = cv::Point2f(real_size.width, real_size.height);
    canvas[3] = cv::Point2f(0, real_size.height);
    
    box.points( tmp );
    
    bool sorted = false;
    int n = 4;
    while (!sorted){
        for (int i = 1; i < n; i++){
            sorted = true;
            if (tmp[i-1].x > tmp[i].x){
                swap(tmp[i-1], tmp[i]);
                sorted = false;
            }
        }
        n--;
    }
    if (tmp[0].y < tmp[1].y){
        corners[0] = tmp[0];
        corners[3] = tmp[1];
    }
    else{
        corners[0] = tmp[1];
        corners[3] = tmp[0];
    }
    
    if (tmp[2].y < tmp[3].y){
        corners[1] = tmp[2];
        corners[2] = tmp[3];
    }
    else{
        corners[1] = tmp[3];
        corners[2] = tmp[2];
    }
    for (int i = 0; i < 4; i++){
        corners[i] = cv::Point2f(corners[i].x * multi, corners[i].y * multi); //恢复坐标到原图
    }
    
    cv::Mat result;
    cv::Mat M = cv::getPerspectiveTransform(corners, canvas);
    cv::warpPerspective(copImage, result, M, real_size);
    return MatToUIImage(result);
}

cv::Point2f CrossPoint(cv::Vec4i line1, cv::Vec4i line2) {
    float x0 = line1[0], y0 = line1[1], x1 = line1[2], y1 = line1[3];
    float x2 = line2[0], y2 = line2[1], x3 = line2[2], y3 = line2[3];

    float dx1 = x1 - x0;
    float dy1 = y1 - y0;

    float dx2 = x3 - x2;
    float dy2 = y3 - y2;

    float D1 = x1 * y0 - x0 * y1;
    float D2 = x3 * y2 - x2 * y3;

    float y = float(dy1 * D2 - D1 * dy2) / (dy1 * dx2 - dx1 * dy2);
    float x = float(y * dx1 - D1) / dy1;

    return cv::Point2f(x, y);
}

std::vector<cv::Point2f> SortPoint(std::vector<cv::Point2f>& points) {
    std::vector<cv::Point2f> sp = points;
    std::sort(sp.begin(), sp.end(), [](const cv::Point2f& a, const cv::Point2f& b) {
        return (a.y < b.y) || ((a.y == b.y) && (a.x < b.x));
    });

    if (sp[0].x > sp[1].x) {
        std::swap(sp[0], sp[1]);
    }

    if (sp[2].x > sp[3].x) {
        std::swap(sp[2], sp[3]);
    }

    return sp;
}

+ (UIImage *)imgcorr: (UIImage *)uiImage {
    cv::Mat cvImage;
    UIImageToMat(uiImage, cvImage);
    if (cvImage.empty()) {
        return uiImage;
    }
    
    cv::Mat copyImage = cvImage.clone();
    
    cv::Mat grayImage;
    cv::cvtColor(cvImage, grayImage, cv::COLOR_BGR2GRAY);
    cv::Mat blurImage;
    cv::GaussianBlur(cvImage, blurImage, cv::Size(3, 3), 0);
    cv::Mat canyImage;
    cv::Canny(blurImage, canyImage, 35, 189);
    
    std::vector<cv::Vec4i> lines;
    cv::HoughLinesP(canyImage, lines, 1, CV_PI / 180, 30, 320, 40);
    if (lines.size() == 0) {
        return  uiImage;
    }
    
    for (size_t i = 0; i < lines.size(); i++) {
        cv::Vec4i line = lines[i];
        cv::line(cvImage, cv::Point(line[0], line[1]), cv::Point(line[2], line[3]), cv::Scalar(255, 255, 0), 3);
    }
    
    std::vector<cv::Point2f> points(4);
    points[0] = CrossPoint(lines[0], lines[2]);
    points[1] = CrossPoint(lines[0], lines[3]);
    points[2] = CrossPoint(lines[1], lines[2]);
    points[3] = CrossPoint(lines[1], lines[3]);
    
    std::vector<cv::Point2f> sp = SortPoint(points);
    
    float width = sqrt(pow(sp[0].x - sp[1].x, 2) + pow(sp[0].y - sp[1].y, 2));
    float height = sqrt(pow(sp[0].x - sp[2].x, 2) + pow(sp[0].y - sp[2].y, 2));
    
    std::vector<cv::Point2f> dstrect = {
        cv::Point2f(0, 0),
        cv::Point2f(width - 1, 0),
        cv::Point2f(0, height - 1),
        cv::Point2f(width - 1, height - 1)
    };
    
    cv::Mat transform = cv::getPerspectiveTransform(sp, dstrect);
    cv::Mat warpedimg;
    cv::warpPerspective(copyImage, warpedimg, transform, cv::Size(width, height));
    return MatToUIImage(warpedimg);
}

+ (UIImage *)imageEdge: (UIImage *)uiImage {
    cv::Mat image;
    UIImageToMat(uiImage, image);
    if (image.empty()) {
        return uiImage;
    }

     // 灰度化
     cv::Mat gray;
     cv::cvtColor(image, gray, cv::COLOR_BGR2GRAY);
    
     // 高斯模糊
     cv::Mat blurred;
     cv::GaussianBlur(gray, blurred, cv::Size(5, 5), 0);

     // 边缘检测
     cv::Mat edges;
     cv::Canny(blurred, edges, 50, 50);

     // 轮廓检测
     std::vector<std::vector<cv::Point>> contours;
     cv::findContours(edges, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);

     // 寻找最大的轮廓
     double maxArea = 0;
     std::vector<cv::Point> maxContour;
     for (const auto& contour : contours) {
         double area = cv::contourArea(contour);
         if (area > maxArea) {
             maxArea = area;
             maxContour = contour;
         }
     }

     // 绘制轮廓
     cv::Mat contourImage = cv::Mat::zeros(image.size(), CV_8UC3);
     cv::drawContours(contourImage, std::vector<std::vector<cv::Point>>{maxContour}, -1, cv::Scalar(0, 255, 0), 2);
    return MatToUIImage(contourImage);
}
double  minThreshold = 10;
double  ratioThreshold = 3;
+ (UIImage *)contours: (UIImage *)uiImage {
    cv::Mat sourceMatImage;
    UIImageToMat(uiImage, sourceMatImage);
    if (sourceMatImage.empty()) {
        return uiImage;
    }
    // 降噪
       blur(sourceMatImage, sourceMatImage, cv::Size(3,3));
       // 转为灰度图
       cvtColor(sourceMatImage, sourceMatImage, CV_BGR2GRAY);
       // 二值化
       threshold(sourceMatImage, sourceMatImage, 190, 255, CV_THRESH_BINARY);
       // 检测边界
       cv::Canny(sourceMatImage, sourceMatImage, minThreshold * ratioThreshold, minThreshold);
       // 获取轮廓
       std::vector<std::vector<cv::Point>> contours;
       findContours(sourceMatImage, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
       
       /*
        *  重新绘制轮廓
        */
       // 初始化一个8UC3的纯黑图像
       cv::Mat dstImg(sourceMatImage.size(), CV_8UC3, cv::Scalar::all(0));
       // 用于存放轮廓折线点集
       std::vector<std::vector<cv::Point>> contours_poly(contours.size());
       // STL遍历
       std::vector<std::vector<cv::Point>>::const_iterator itContours = contours.begin();
       std::vector<std::vector<cv::Point>>::const_iterator itContourEnd = contours.end();
       // ++i 比 i++ 少一次内存写入,性能更高
       for (int i=0 ; itContours != itContourEnd; ++itContours,++i) {
           approxPolyDP(cv::Mat(contours[i]), contours_poly[i], 15, true);
           // 绘制处理后的轮廓,可以一段一段绘制,也可以一次性绘制
           // drawContours(dstImg, contours_poly, i, Scalar(208, 19, 29), 8, 8);
       }
       
      /*如果C++ 基础不够,可以使用 for 循环
       *    for (int i = 0; i < contours.size(); i ++) {
       *        approxPolyDP(contours[i] , contours_poly[i], 5, YES);
       *    }
       */
       
       // 绘制处理后的轮廓,一次性绘制
       drawContours(dstImg, contours_poly, -1, cv::Scalar(208, 19, 29), 8, 8);
    return MatToUIImage(dstImg);
}

@end
