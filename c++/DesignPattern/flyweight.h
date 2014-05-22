#ifndef __FLYWEIGHT_H__
#define __FLYWEIGHT_H__
#include <cstdlib>
#include <iostream>
#include <string>
#include <list>

Flyweight 享元模式的作用就是，减少对象的创建/销毁频率。

实现步骤： 
设置一个对象工厂，管理一个对象池pool, 当有请求需要创建新对象的时候
首先查看pool里是否有需要的对象存在，如果不存在就创建一个新的对象，并保存在pool里，
然后将该对象返回给客户；如果对象已经存在，就直接返回，不需要再创建。

常见的 线程池，应该就是 Flyweight 模式的实现，可能会更高级，更复杂。 
 

#endif
