//
//  ScrollSelectView.m
//  CoreImageTest
//
//  Created by Ding Ma on 2/19/14.
//  Copyright (c) 2014 Ding Ma. All rights reserved.
//

#import "ScrollSelectView.h"
#import "RulerType.h"

const int SCROLL_VIEW_HEIGHT = 100;

@interface ScrollSelectView ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;
@property (nonatomic, strong) RulerType *rulerType;
@property (nonatomic) float filterMin, filterMax, filterValue;
@property (nonatomic) float rulerMin, rulerMax, rulerStep, currentRulerValue;
@property (nonatomic) NSString *filterName, *paramName;
@property (nonatomic) CGSize viewSize;
@property (nonatomic, strong) NSMutableDictionary *currentFilter;

@end

@implementation ScrollSelectView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // add xib
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"ScrollSelectView" owner:self options:nil];
        self = [arrayOfViews objectAtIndex:0];
        [self setFrame:frame];
        
        // Initialization code
        self.currentRulerValue = 0;
        self.filterName = [NSString new];
        self.currentFilter = [NSMutableDictionary new];
        
        // set view size
        self.viewSize = CGSizeMake(frame.size.width, SCROLL_VIEW_HEIGHT);
        
        // init subviews
        [self initSubviews:self.viewSize];
        
        // get rule type list
        self.rulerType = [RulerType sharedRulerType];
        self.rulerMax = [self.rulerType getMax];
        self.rulerMin = [self.rulerType getMin];
        self.rulerStep = [self.rulerType getStep];
    }
    return self;
}

- (void)initSubviews:(CGSize)size
{
    // init scrollview
    self.scrollView.delegate = self;
    UIImage *image = [UIImage imageNamed:@"rule-ex.jpg"];

    [self.scrollView setContentSize:CGSizeMake(image.size.width, 60)];
    [self.scrollView setContentOffset:CGPointMake((image.size.width - size.width) / 2, 0)];
    [self.scrollView setContentInset:UIEdgeInsetsMake(0, size.width / 2, 0, size.width / 2)];
    [self.scrollView setBounces:FALSE];
    [self.scrollView setShowsHorizontalScrollIndicator:FALSE];
    
    // add rule image view to scroll view
    UIImageView *imageView = [UIImageView new];
    [imageView setImage:image];
    [imageView setFrame:CGRectMake(0, 0, image.size.width, 60)];
    [self.scrollView addSubview:imageView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // update UI
    float rulerValue = -50 + (scrollView.contentOffset.x + self.viewSize.width / 2) / scrollView.contentSize.width * 100;
    NSString *valueString = [NSString stringWithFormat:@"%.0f", rulerValue];
    [self.valueLabel setText:valueString];
    
    // send notification
    float newRulerValue = [valueString floatValue];
    if (newRulerValue != self.currentRulerValue) {
        // update current filter value
        self.currentRulerValue = newRulerValue;
        
        // create post dic
        NSMutableDictionary *dic = [self createFilterDic];

        // notify 'VALUE_UPDATED'
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VALUE_UPDATED" object:nil userInfo:dic];
    }
}

- (void)refreshRuleType:(NSNotification *)notify
{
    // get rule type
    NSString *ruleType = [[notify userInfo] objectForKey:@"paramName"];
    NSDictionary *ruleTypeInfo = [[self.rulerType getRulerTypeList] objectForKey:ruleType];
    
    // refresh info
    self.filterName = [[notify userInfo] objectForKey:@"name"];
    [self setFilterMax:[[ruleTypeInfo objectForKey:@"max"] floatValue] filterMin:[[ruleTypeInfo objectForKey:@"min"] floatValue]];
}

- (void)setFilterMax:(float)max filterMin:(float)min
{
    self.filterMax = max;
    self.filterMin = min;
}

- (NSMutableDictionary *)createFilterDic
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    [dic setDictionary:self.currentFilter];
    [dic setObject:[NSNumber numberWithFloat:self.currentRulerValue] forKey:self.paramName];
    
    return dic;
}

- (IBAction)onClickYes:(id)sender {
    NSMutableDictionary* dic = [self createFilterDic];
    
    // notify 'SCROLL_YES_CLICKED'
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCROLL_YES_CLICKED" object:nil userInfo:dic];
}

- (IBAction)onClickNo:(id)sender {
    NSMutableDictionary* dic = [self createFilterDic];
    
    // notify 'SCROLL_NO_CLICKED'
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCROLL_NO_CLICKED" object:nil userInfo:dic];
}

- (void)hide
{
    CGRect tempFrame = [[UIScreen mainScreen] bounds];
    [UIView animateWithDuration:0.5 animations:^{
        CGPoint point = CGPointMake(tempFrame.size.width / 2, tempFrame.size.height + SCROLL_VIEW_HEIGHT / 2);
        [self setCenter:point];
    }];
}

- (void)show:(NSDictionary *)dic
{
    // update view
    [self updateByFilter:dic];
    
    CGRect tempFrame = [[UIScreen mainScreen] bounds];
    [UIView animateWithDuration:0.5 animations:^{
        CGPoint point = CGPointMake(tempFrame.size.width / 2, tempFrame.size.height - SCROLL_VIEW_HEIGHT / 2);
        [self setCenter:point];
    }];
}

- (void)updateByFilter:(NSDictionary *)dic
{
    // update current filter dic
    self.currentFilter = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    // update filter name
    self.filterName = [dic objectForKey:@"name"];
    
    // get ruler type
    self.paramName = [NSString stringWithString:[dic objectForKey:@"paramName"]];

    // update ruler value
    self.currentRulerValue = [[dic objectForKey:self.paramName] floatValue];
    
    // update filter value
    self.filterValue = [self.rulerType rulerValueToFilterValue:self.paramName value:self.currentRulerValue];

    // update view
    float value =  (self.currentRulerValue - self.rulerMin) / (self.rulerMax - self.rulerMin) * self.scrollView.contentSize.width - self.viewSize.width / 2;
    [self.scrollView setContentOffset:CGPointMake(value, 0)];

    // notify 'VALUE_UPDATED'
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VALUE_UPDATED" object:nil userInfo:dic];
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
