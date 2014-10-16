//
//  MDAnimation.m
//  CoreImageTest
//
//  Created by Ding Ma on 3/7/14.
//  Copyright (c) 2014 Ding Ma. All rights reserved.
//

#import "MDAnimation.h"

@implementation MDAnimation

+ (void)crossFadeExchangeImage:(UIImageView *)view image:(UIImage *)image
{
    // cross fade image
    [UIView transitionWithView:view
                      duration:1.0f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        view.image = image;
                    }
                    completion:NULL];
}

//    // this method is limited in some conditions
//    + (void)crossFadeImage:(UIImageView *)view oldImage:(UIImage *)oldImage newImage:(UIImage *)newImage
//    {
//        CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
//        crossFade.duration = 2.0;
//        crossFade.fromValue = (__bridge id)(oldImage.CGImage);
//        crossFade.toValue = (__bridge id)(newImage.CGImage);
//        [view.layer addAnimation:crossFade forKey:@"animateContents"];
//    }

@end
