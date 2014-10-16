//
//  LooksCollectionView.m
//  CoreImageTest
//
//  Created by Ding Ma on 2/14/14.
//  Copyright (c) 2014 Ding Ma. All rights reserved.
//

#import "LooksCollectionView.h"
#import "CVCell.h"
#import "ImageTools.h"
#import <QuartzCore/QuartzCore.h>

const int CELL_WIDTH = 110;
const int CELL_HEIGHT = 110;
const int COLLECTION_VIEW_HEIGHT = 110;

@interface LooksCollectionView ()

@property (nonatomic, strong) NSMutableDictionary *filterDictionary;
@property (nonatomic, strong) ImageTools *imageTools;
@property (nonatomic, retain) UIImage *thumbnailImage;
@property (nonatomic) BOOL thumbnailHandled;

@end

@implementation LooksCollectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // set flag
    self.thumbnailHandled = FALSE;
    
    // register datasource and delegate
    self.dataSource = self;
    self.delegate = self;

    // get image tools
    self.imageTools = [ImageTools sharedImageTools];
    
    // init filter dictionary
    [self initDictionary];
    
//    // init cell view from nib
//    UINib *cellNib = [UINib nibWithNibName:@"LookCell" bundle:nil];
//    [self registerNib:cellNib forCellWithReuseIdentifier:@"cvCell"];
    
    // init cell view from class
    [self registerClass:[CVCell class] forCellWithReuseIdentifier:@"CVCell"];
    
    // add custom collection view layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(CELL_WIDTH, CELL_HEIGHT)];
    [flowLayout setMinimumLineSpacing:0.0];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self setCollectionViewLayout:flowLayout];
}

- (void)initDictionary
{
    self.filterDictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:@"Exposure" forKey:@"name"];
    [dic setObject:@"CIExposureAdjust" forKey:@"filterName"];
    [dic setObject:@"inputEV" forKey:@"paramName"];
    [dic setObject:@10.0f forKey:@"inputEV"];
    [self.filterDictionary setObject:[[NSMutableDictionary alloc] initWithDictionary:dic] forKey:@"Exposure"];
    [dic removeAllObjects];
    
    [dic setObject:@"Contrast" forKey:@"name"];
    [dic setObject:@"CIColorControls" forKey:@"filterName"];
    [dic setObject:@"inputContrast" forKey:@"paramName"];
    [dic setObject:@10.0f forKey:@"inputContrast"];
    [self.filterDictionary setObject:[[NSMutableDictionary alloc] initWithDictionary:dic] forKey:@"Contrast"];
    [dic removeAllObjects];
    
    [dic setObject:@"Saturation" forKey:@"name"];
    [dic setObject:@"CIColorControls" forKey:@"filterName"];
    [dic setObject:@"inputSaturation" forKey:@"paramName"];
    [dic setObject:@10.0f forKey:@"inputSaturation"];
    [self.filterDictionary setObject:[[NSMutableDictionary alloc] initWithDictionary:dic] forKey:@"Saturation"];
    [dic removeAllObjects];
    
    [dic setObject:@"Vibrance" forKey:@"name"];
    [dic setObject:@"CIVibrance" forKey:@"filterName"];
    [dic setObject:@"inputAmount" forKey:@"paramName"];
    [dic setObject:@10.0f forKey:@"inputAmount"];
    [self.filterDictionary setObject:[[NSMutableDictionary alloc] initWithDictionary:dic] forKey:@"Vibrance"];
    [dic removeAllObjects];
    
    [dic setObject:@"Sharpen" forKey:@"name"];
    [dic setObject:@"CISharpenLuminance" forKey:@"filterName"];
    [dic setObject:@"inputSharpness" forKey:@"paramName"];
    [dic setObject:@10.0f forKey:@"inputSharpness"];
    [self.filterDictionary setObject:[[NSMutableDictionary alloc] initWithDictionary:dic] forKey:@"Sharpen"];
    [dic removeAllObjects];
    
//    // Noise filter is not supported by iOS now
//    [dic setObject:@"Noise" forKey:@"name"];
//    [dic setObject:@"CINoiseReduction" forKey:@"filterName"];
//    [dic setObject:@"inputNoiseLevel" forKey:@"paramName"];
//    [dic setObject:@10.0f forKey:@"inputNoiseLevel"];
//    [self.filterDictionary setObject:[[NSMutableDictionary alloc] initWithDictionary:dic] forKey:@"Noise"];
//    [dic removeAllObjects];
    
    [dic setObject:@"Highlight" forKey:@"name"];
    [dic setObject:@"CIHighlightShadowAdjust" forKey:@"filterName"];
    [dic setObject:@"inputHighlightAmount" forKey:@"paramName"];
    [dic setObject:@10.0f forKey:@"inputHighlightAmount"];
    [self.filterDictionary setObject:[[NSMutableDictionary alloc] initWithDictionary:dic] forKey:@"Highlight"];
    [dic removeAllObjects];
    
    [dic setObject:@"Shadow" forKey:@"name"];
    [dic setObject:@"CIHighlightShadowAdjust" forKey:@"filterName"];
    [dic setObject:@"inputShadowAmount" forKey:@"paramName"];
    [dic setObject:@10.0f forKey:@"inputShadowAmount"];
    [self.filterDictionary setObject:[[NSMutableDictionary alloc] initWithDictionary:dic] forKey:@"Shadow"];
    [dic removeAllObjects];
    
    [dic setObject:@"Temperature" forKey:@"name"];
    [dic setObject:@"CITemperatureAndTint" forKey:@"filterName"];
    [dic setObject:@"inputTemperature" forKey:@"paramName"];
    [dic setObject:@10.0f forKey:@"inputTemperature"];
    [self.filterDictionary setObject:[[NSMutableDictionary alloc] initWithDictionary:dic] forKey:@"Temperature"];
    [dic removeAllObjects];
    
    [dic setObject:@"Tint" forKey:@"name"];
    [dic setObject:@"CITemperatureAndTint" forKey:@"filterName"];
    [dic setObject:@"inputTint" forKey:@"paramName"];
    [dic setObject:@10.0f forKey:@"inputTint"];
    [self.filterDictionary setObject:[[NSMutableDictionary alloc] initWithDictionary:dic] forKey:@"Tint"];
    [dic removeAllObjects];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.filterDictionary.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // get value by indexPath
    id key = [[self.filterDictionary allKeys] objectAtIndex:indexPath.row];
    id params = [self.filterDictionary objectForKey:key];
    
    static NSString *cellIdentifier = @"CVCell";
    
    // create reusable cell
    CVCell *cell = (CVCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell.valueInContent setText:[[params objectForKey:[params objectForKey:@"paramName"]] stringValue]];
    [cell.nameInContent setText:key];
    
    // if thumbnail is not loaded, don't show it
    if (self.thumbnailHandled == FALSE) {
        
    }else{
        CIFilter *filter = [self.imageTools createFilter:params];
        UIImage *filteredImage = [self.imageTools filterImage:self.thumbnailImage filter:filter];
        
        [cell.imageInContent setImage:filteredImage];
    }
    
    return cell;
}

- (BOOL)initImages:(UIImage *)image
{
    // scale image
    self.thumbnailImage = [ImageTools scaleToSize:CGSizeMake(200, 200) image:image];

    // set flag
    self.thumbnailHandled = TRUE;
    
    // update whole collection view
    [self reloadData];
    
    return TRUE;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // get value by indexPath
    id key = [[self.filterDictionary allKeys] objectAtIndex:indexPath.row];
    id params = [self.filterDictionary objectForKey:key];
    
    // notify 'LOOK_SELECTED'
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LOOK_SELECTED" object:nil userInfo:params];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{

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
