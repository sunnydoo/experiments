//
//  CVCell.h
//  CoreImageTest
//
//  Created by Ding Ma on 2/25/14.
//  Copyright (c) 2014 Ding Ma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CVCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *viewForContent;
@property (weak, nonatomic) IBOutlet UIImageView *imageInContent;
@property (weak, nonatomic) IBOutlet UILabel *valueInContent;
@property (weak, nonatomic) IBOutlet UILabel *nameInContent;

@end
