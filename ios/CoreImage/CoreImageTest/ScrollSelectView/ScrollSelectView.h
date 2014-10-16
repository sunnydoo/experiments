//
//  ScrollSelectView.h
//  CoreImageTest
//
//  Created by Ding Ma on 2/19/14.
//  Copyright (c) 2014 Ding Ma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollSelectView : UIView<UIScrollViewDelegate>

- (IBAction)onClickYes:(id)sender;
- (IBAction)onClickNo:(id)sender;
- (void)show:(NSDictionary *)dic;
- (void)hide;

@end
