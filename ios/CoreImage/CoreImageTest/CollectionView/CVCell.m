//
//  CVCell.m
//  CoreImageTest
//
//  Created by Ding Ma on 2/25/14.
//  Copyright (c) 2014 Ding Ma. All rights reserved.
//

#import "CVCell.h"

@implementation CVCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"CVCell" owner:self options:Nil];
        
        if ([arrayOfViews count] < 1) {
            return Nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return Nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];

        // set content view
        [self.contentView addSubview:self.viewForContent];
        
        // set background view
        
        // set selected background view
        UIView *bgView = [[UIView alloc] init];
        [bgView setBackgroundColor:[UIColor colorWithRed:139.0/255 green:166.0/255 blue:147.0/255 alpha:1]];
        self.selectedBackgroundView = bgView;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
