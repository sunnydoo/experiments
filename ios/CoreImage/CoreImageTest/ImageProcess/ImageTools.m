//
//  ImageTools.m
//  CoreImageTest
//
//  Created by Ding Ma on 2/13/14.
//  Copyright (c) 2014 Ding Ma. All rights reserved.
//

#import "ImageTools.h"
#import "RulerType.h"
#import <CoreImage/CoreImage.h>

@interface ImageTools ()

typedef NS_ENUM(NSInteger, FilterStyle) {
    FExposure,
    FContrast,
    FSaturation,
    FVibrance,
    FSharpen,
    FNoise,
    FHighlight,
    FShadow,
    FTemperature,
    FTint
};
@property (nonatomic, strong) NSMutableDictionary *filterDictionary;
@property (nonatomic) NSString *nameString, *filterNameString, *paramTypeString;

@end

@implementation ImageTools

- (id)init
{
    self = [super init];
    if (self) {
        // initialization
        self.filterDictionary = [[NSMutableDictionary alloc] init];
        
        // create filter map
        [self.filterDictionary setObject:[NSNumber numberWithInteger:FExposure] forKey:@"Exposure"];
        [self.filterDictionary setObject:[NSNumber numberWithInteger:FContrast] forKey:@"Contrast"];
        [self.filterDictionary setObject:[NSNumber numberWithInteger:FSaturation] forKey:@"Saturation"];
        [self.filterDictionary setObject:[NSNumber numberWithInteger:FVibrance] forKey:@"Vibrance"];
        [self.filterDictionary setObject:[NSNumber numberWithInteger:FSharpen] forKey:@"Sharpen"];
        [self.filterDictionary setObject:[NSNumber numberWithInteger:FNoise] forKey:@"Noise"];
        [self.filterDictionary setObject:[NSNumber numberWithInteger:FHighlight] forKey:@"Highlight"];
        [self.filterDictionary setObject:[NSNumber numberWithInteger:FShadow] forKey:@"Shadow"];
        [self.filterDictionary setObject:[NSNumber numberWithInteger:FTemperature] forKey:@"Temperature"];
        [self.filterDictionary setObject:[NSNumber numberWithInteger:FTemperature] forKey:@"Tint"];
        
        // set filter name string
        self.nameString = @"name";
        self.filterNameString = @"filterName";
        self.paramTypeString = @"paramName";
    }
    return self;
}

+(ImageTools *)sharedImageTools
{
    static ImageTools *sharedImageTools;
    @synchronized(self){
        if (!sharedImageTools) {
            sharedImageTools = [[ImageTools alloc] init];
        }
        return sharedImageTools;
    }
}

+ (UIImage *)scaleToSize:(CGSize)size image:(UIImage *)image
{
    if (size.width > image.size.width && size.height > image.size.height) {
        // the image is small enough, we don't need scale it
        return image;
    }else{
        // scale image
        // get image orientation
        CGFloat imageOrientation = image.imageOrientation;
        
        // get original size
        CGFloat width;
        CGFloat height;
        if (imageOrientation == UIImageOrientationLeft || imageOrientation == UIImageOrientationRight) {
            width = CGImageGetHeight(image.CGImage);
            height = CGImageGetWidth(image.CGImage);
        }else{
            width = CGImageGetWidth(image.CGImage);
            height = CGImageGetHeight(image.CGImage);
        }
        
        // calculate radio for target/original
        float horizontalRadio = size.width*1.0/width;
        float verticalRadio = size.height*1.0/height;
        
        // get final radio
        float radio = 1;
        if (verticalRadio > 1 || horizontalRadio > 1) {
            // narrow
            radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
        }else{
            // enlarge
            radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
        }
        
        // get final size
        width = width*radio;
        height = height*radio;
        
        // calculate position
        int xPos = (size.width - width)/2;
        int yPos = (size.height - height)/2;
        
        // create a bitmap context
        UIGraphicsBeginImageContext(size);
        
        // draw final image in context
        [image drawInRect:CGRectMake(xPos, yPos, width, height)];
        
        // create a new image from context
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // end the context
        UIGraphicsEndImageContext();
        
        return scaledImage;
    }
}

- (UIImage *)filterImage:(UIImage *)image filter:(CIFilter *)filter
{
    //    // CPU method
    //    CIContext *context = [CIContext contextWithOptions:nil];
    
    // GPU method
    EAGLContext *myEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    CIContext *context = [CIContext contextWithEAGLContext:myEAGLContext];
    
    // create CIImage
    CGFloat imageOrientation = image.imageOrientation;
    CIImage *ciimage = [[CIImage alloc] initWithCGImage:image.CGImage];
    
    // set input image and filter it
    [filter setValue:ciimage forKey:kCIInputImageKey];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // fill image view with new image
    CGRect extent = [result extent];
    CGImageRef cgImage = [context createCGImage:result fromRect:extent];
    UIImage *newImage = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:imageOrientation];
    
    // release storage
    CGImageRelease(cgImage);    // must release or you will die
    
    return newImage;
}

- (CIFilter *)createFilter:(NSDictionary *)filterInfo
{
    // get enum for name
    NSString *name = [filterInfo objectForKey:self.nameString];
    NSInteger nameEnum = [[self.filterDictionary objectForKey:name] integerValue];
    
    // create filter
    // set filter name
    NSString *filterName = [NSString stringWithString:[filterInfo objectForKey:self.filterNameString]];
    CIFilter *filter = [CIFilter filterWithName:filterName];
    
    // set param
    RulerType *rulerType = [RulerType sharedRulerType];
    NSString *paramName = [NSString stringWithString:[filterInfo objectForKey:self.paramTypeString]];
    float rulerValue = [[filterInfo objectForKey:paramName] floatValue];
    NSNumber *number = [NSNumber numberWithFloat:[rulerType rulerValueToFilterValue:paramName value:rulerValue]];
    
    // generate filter
    switch (nameEnum) {
        case FExposure:
            [filter setValue:number forKey:kCIInputEVKey];
            break;
            
        case FContrast:
            [filter setValue:number forKey:kCIInputContrastKey];
            break;
            
        case FSaturation:
            [filter setValue:number forKey:kCIInputSaturationKey];
            break;
            
        case FVibrance:
            [filter setValue:number forKey:paramName];
            break;
            
        case FSharpen:
            [filter setValue:number forKey:kCIInputSharpnessKey];
            break;
            
        case FNoise:
            [filter setValue:number forKey:paramName];
            break;
            
        case FHighlight:
            [filter setValue:number forKey:paramName];
            break;
        
        case FShadow:
            [filter setValue:number forKey:paramName];
            break;
            
        case FTemperature:
            [filter setValue:[CIVector vectorWithX:[number floatValue] Y:0] forKey:@"inputTargetNeutral"];
            break;
            
        case FTint:
            [filter setValue:[CIVector vectorWithX:6500 Y:[number floatValue]] forUndefinedKey:@"inputTargetNeutral"];
            break;
            
        default:
            break;
    }
    
    return filter;
    
//    // Cannot use this. Why?
//    // should not use this
//    CIFilter *filter = [self createExposureFilter:filterInfo];
//    return filter;
}

@end