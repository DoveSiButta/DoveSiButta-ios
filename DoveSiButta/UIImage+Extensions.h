//
//  UIImage+Extensions.h
//  DoveSiButta
//
//  Created by Giovanni Maggini on 30/01/12.
//  Copyright (c) 2012 Giovanni Maggini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extensions)

- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end
