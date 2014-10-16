//
//  ViewController.h
//  CoreImageTest
//
//  Created by Ding Ma on 2/13/14.
//  Copyright (c) 2014 Ding Ma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (IBAction)imagePickerClicked:(id)sender;
- (IBAction)saveImageClicked:(id)sender;
- (IBAction)shareWeibo:(id)sender;

@end
