//
//  FilterList.h
//  CoreImageTest
//
//  Created by Ding Ma on 3/3/14.
//  Copyright (c) 2014 Ding Ma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RulerType : NSObject

+ (RulerType *)sharedRulerType;
- (NSMutableDictionary *)getRulerTypeList;
- (float)getMax;
- (float)getMin;
- (float)getStep;
- (float)rulerValueToFilterValue:(NSString *)rulerType value:(float)value;

@end
