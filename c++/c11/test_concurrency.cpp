//
//  test_concurrency.cpp
//  testC11
//
//  Created by jianwang on 4/16/14.
//  Copyright (c) 2014 jianwang.com. All rights reserved.
//

#include "AJWLangTest.h"

#include <iostream>
#include <thread>
#include <future>
#include <chrono>
#include <random>
#include <exception>
#include <iostream>

using namespace std;

int doSomething (char c)
{
    std::default_random_engine dre( c );
    std::uniform_int_distribution<int> id(10, 1000);
    
    for (int i=0; i<10; ++i) {
        this_thread::sleep_for(chrono::milliseconds(id(dre)));
        cout.put(c).flush();
    }
    
    return c;
}

int func1()
{
    return doSomething('.');
}

int func2()
{
    return doSomething('+');
}

void test_concurrency1()
{
    std::cout<<"Starting func1 in background"
    <<" and func2() in foreground:" << std::endl;
    
    std::future<int> result1( std::async(func1));
    
    int result2 = func2();
    
    int result = result1.get() + result2;
    
    std::cout << "\n\nResult Of func1() + func2():" << result << endl;
    
    cout<< "Test Concurrency" << endl;
}

void test_concurrency2()
{
    std::async([] {
        cout << "Async in Lambda" << endl;
    });
}

void test_concurrency()
{
    test_concurrency1();
    
}

