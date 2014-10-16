//
//  LooksCollectionView.h
//  CoreImageTest
//
//  Created by Ding Ma on 2/14/14.
//  Copyright (c) 2014 Ding Ma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LooksCollectionView : UICollectionView<UICollectionViewDelegate, UICollectionViewDataSource>

- (BOOL)initImages:(UIImage *)image;

@end
