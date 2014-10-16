//
//  ImageTools.h
//  CoreImageTest
//
//  Created by Ding Ma on 2/13/14.
//  Copyright (c) 2014 Ding Ma. All rights reserved.
//

#import <Foundation/Foundation.h>

// ImageTools is a singleton
@interface ImageTools : NSObject

+ (ImageTools *)sharedImageTools;
+ (UIImage *)scaleToSize:(CGSize)size image:(UIImage *)image;
- (CIFilter *)createFilter:(NSDictionary *)filterInfo;
- (UIImage *)filterImage:(UIImage *)image filter:(CIFilter *)filter;

@end
