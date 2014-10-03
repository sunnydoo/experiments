//
//  test_block.cpp
//  testC11
//
//  Created by jianwang on 4/24/14.
//  Copyright (c) 2014 jianwang.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "AJWLangTest.h"

//Ok, C++11 has auto - automatic type deduction, but ObjectC does not.
//so block must be declared exactly as function pointer, with a ^

void test_block1()
{
    void (^simpleBlock)(void) = ^{
        NSLog(@"This is a block");
    };
    
    simpleBlock();
}

//passed by value and passed by reference

//by default,  the variables in outer scope are passed by value, that is, copied to lambdas.
//and are captured when the block are created, same as C++11.

void test_block2()
{
    int anInteger = 42;
    
    void (^testBlock)(void) = ^{
        NSLog(@"Integer is: %i", anInteger);
    };
    
    anInteger = 84;

    testBlock();
    
}

//with __block,  the variable storage is shared between outer scope and inside block.
//same as passed by reference in C++11.
void test_block3()
{
    __block int anInteger = 42;

    void (^testBlock)(void) = ^{
        NSLog(@"Integer is: %i", anInteger);
    };
    
    anInteger = 84;
    
    testBlock();
}


void test_block()
{
    //test_block1();
    
    //test_block2();
    test_block3();
    
}

void test_block_concurrency()
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSLog(@"Block for asynchronous execution");
    });
    
    NSLog(@"sync execution in main");


}
