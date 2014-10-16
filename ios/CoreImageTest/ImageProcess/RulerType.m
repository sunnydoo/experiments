//
//  FilterList.m
//  CoreImageTest
//
//  Created by Ding Ma on 3/3/14.
//  Copyright (c) 2014 Ding Ma. All rights reserved.
//

#import "RulerType.h"

@interface RulerType ()

@property (nonatomic, strong) NSMutableDictionary *rulerTypeList;
@property (nonatomic) float rulerMax, rulerMin, rulerStep;

@end

@implementation RulerType

- (id)init
{
    self = [super init];
    if (self) {
        // initialization
        self.rulerTypeList = [[NSMutableDictionary alloc] init];
        
        // init ruler info
        self.rulerMax = 50;
        self.rulerMin = -50;
        self.rulerStep = 100;
        
        // init ruler type list
        [self initRulerTypeList];
    }
    return self;
}

+ (RulerType *)sharedRulerType
{
    static RulerType *sharedRulerType;
    @synchronized(self){
        if (!sharedRulerType) {
            sharedRulerType = [[RulerType alloc] init];
        }
        return sharedRulerType;
    }
}

- (NSMutableDictionary *)getRulerTypeList
{
    return self.rulerTypeList;
}

- (float)getMax
{
    return self.rulerMax;
}

- (float)getMin
{
    return self.rulerMin;
}

- (float)getStep
{
    return self.rulerStep;
}

- (void)initRulerTypeList
{
    self.rulerTypeList = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *rulerDic = [[NSMutableDictionary alloc] init];
    
    [rulerDic setObject:@0.0f forKey:@"min"];
    [rulerDic setObject:@2.0f forKey:@"max"];
    [self.rulerTypeList setObject:[[NSMutableDictionary alloc] initWithDictionary:rulerDic] forKey:@"inputSaturation"];
    [rulerDic removeAllObjects];
    
    [rulerDic setObject:@0.5f forKey:@"min"];
    [rulerDic setObject:@1.5f forKey:@"max"];
    [self.rulerTypeList setObject:[[NSMutableDictionary alloc] initWithDictionary:rulerDic] forKey:@"inputContrast"];
    [rulerDic removeAllObjects];
    
    [rulerDic setObject:@-5.0f forKey:@"min"];
    [rulerDic setObject:@5.0f forKey:@"max"];
    [self.rulerTypeList setObject:[[NSMutableDictionary alloc] initWithDictionary:rulerDic] forKey:@"inputEV"];
    [rulerDic removeAllObjects];
    
    [rulerDic setObject:@-5.0f forKey:@"min"];
    [rulerDic setObject:@5.0f forKey:@"max"];
    [self.rulerTypeList setObject:[[NSMutableDictionary alloc] initWithDictionary:rulerDic] forKey:@"inputAmount"];
    [rulerDic removeAllObjects];
    
    [rulerDic setObject:@-2.0f forKey:@"min"];
    [rulerDic setObject:@2.0f forKey:@"max"];
    [self.rulerTypeList setObject:[[NSMutableDictionary alloc] initWithDictionary:rulerDic] forKey:@"inputSharpness"];
    [rulerDic removeAllObjects];
    
    [rulerDic setObject:@-1.0f forKey:@"min"];
    [rulerDic setObject:@1.0f forKey:@"max"];
    [self.rulerTypeList setObject:[[NSMutableDictionary alloc] initWithDictionary:rulerDic] forKey:@"inputNoiseLevel"];
    [rulerDic removeAllObjects];
    
    [rulerDic setObject:@-1.0f forKey:@"min"];
    [rulerDic setObject:@2.0f forKey:@"max"];
    [self.rulerTypeList setObject:[[NSMutableDictionary alloc] initWithDictionary:rulerDic] forKey:@"inputHighlightAmount"];
    [rulerDic removeAllObjects];
    
    [rulerDic setObject:@-1.0f forKey:@"min"];
    [rulerDic setObject:@1.0f forKey:@"max"];
    [self.rulerTypeList setObject:[[NSMutableDictionary alloc] initWithDictionary:rulerDic] forKey:@"inputShadowAmount"];
    [rulerDic removeAllObjects];
    
    [rulerDic setObject:@2000.0f forKey:@"min"];
    [rulerDic setObject:@25000.0f forKey:@"max"];
    [self.rulerTypeList setObject:[[NSMutableDictionary alloc] initWithDictionary:rulerDic] forKey:@"inputTemperature"];
    [rulerDic removeAllObjects];
    
    [rulerDic setObject:@50.0f forKey:@"min"];
    [rulerDic setObject:@900.0f forKey:@"max"];
    [self.rulerTypeList setObject:[[NSMutableDictionary alloc] initWithDictionary:rulerDic] forKey:@"inputTint"];
    [rulerDic removeAllObjects];
}

- (float)rulerValueToFilterValue:(NSString *)rulerType value:(float)value
{
    float max = [[[self.rulerTypeList objectForKey:rulerType] objectForKey:@"max"] floatValue];
    float min = [[[self.rulerTypeList objectForKey:rulerType] objectForKey:@"min"] floatValue];
    return (value - self.rulerMin) / (self.rulerMax - self.rulerMin) * (max - min) + min;
}

@end
