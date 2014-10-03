//
//  test_auto.cpp
//  testC11
//
//  Created by jianwang on 4/16/14.
//  Copyright (c) 2014 jianwang.com. All rights reserved.
//

#include "AJWLangTest.h"
#include <vector>
#include <iostream>

using namespace std;

double f()
{
    return 1.2;
}

void test_auto()
{
    auto i = 42; // i has type int
    auto d = f(); // d has type double
    
    
    // error requires a initialiazer
    //
     //auto aVar;
    
    
    cout<< i << endl << d << endl;
    
    
}


void test_rangefor()
{
    cout<< "Range-for: without &, it operats on a local copy, it's a problem for heavy member in vector" << endl;

    std::vector<int> vect = {1, 2, 3, 4, 5};
    for ( auto elem : vect ) {
        elem *= 3;
    }
    
    for ( auto elem : vect ) {
        cout << elem << endl;
    }
    
    cout<< "Range-for: with &, it operats on the real element:" << endl;
    for ( auto& elem : vect ) {
        elem *= 3;
    }
    for ( auto elem : vect ) {
        cout << elem << endl;
    }

    
}