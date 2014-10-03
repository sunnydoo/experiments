//
//  test_lambda.cpp
//  testC11
//
//  Created by jianwang on 4/24/14.
//  Copyright (c) 2014 jianwang.com. All rights reserved.
//

#include "AJWLangTest.h"
#include <vector>
#include <iostream>
using namespace std;

// use lambda directly
void test_lambda1()
{
    [] {
        std::cout << "hello lambda" << std::endl;
    }();
    
}

// assign to a variable.
void test_lambda2()
{
    //int id = 100;
    auto l = [] {
        std::cout << "hello lambda"  << std::endl;
    };
    
    l();
}

//// mutable in lambda
//void test_lambda3()
//{
//    int id = 0;
//    
//    // id is captured when lambda is created, with mutable,
//    // a local copy of id is created, like a static variable
//    auto f = [id] (int k, int kk) -> double {
//        std::cout << "id: " << id << std::endl;
//        ++id;
//        
//        return 1.5;
//    };
//    
//    id = 42;
//    
//    f();
//    f();
//    f();
//    std::cout << id << std::endl;
//}


// passed by value and passed by reference.
// passed by value:  the value is captured by lambda when the lambda is created.

void test_lambda4()
{
    int x=0;
    int y=42;
    auto qqq = [x, &y]{
        std::cout << "x: " << x << std::endl;
        std::cout << "y: " << y << std::endl;
        ++y; // OK
    };
    x = y = 77;
    qqq();
    qqq();
    std::cout << "final y: " << y << std::endl;
    
}

void test_lambda()
{
    test_lambda4();
}

