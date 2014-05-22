#ifndef FACTORY_METHOD_H
#define FACTORY_METHOD_H
#include <cstdlib>
#include <iostream>
#include <string>

using namespace std;

class Light 
{
public:
   virtual void TurnOn() = 0;
   virtual void TurnOff() = 0;
   virtual ~Light() {};
};

class BulbLight : public Light
{
public:
   void TurnOn() {
      cout << "Bulb Light is Turned on" << endl;      
   }      
   
   void TurnOff() {
      cout << "Bulb Light is Turned off" << endl;
   }
   
   ~BulbLight()
   {
      cout << "Delete BulbLight" << endl;
   }
};

class TubeLight : public Light
{
public:
   void TurnOn() {
      cout << "Tube Light is Turned on" << endl;      
   }      
   
   void TurnOff() {
      cout << "Tube Light is Turned off" << endl;
   }
   
   ~TubeLight()
   {
      cout << "Delete TubeLight" << endl;
   }
};

class Creator {
public:
   virtual Light* LightFactory() = 0;
};

class BulbCreator : public Creator  {
public:
   Light* LightFactory() {
      return new BulbLight();
   }
};

class TubeCreator : public Creator {
public:
   Light* LightFactory() {
      return new TubeLight();
   }
};

// ----- How to use it ------

//    Creator* bf = new BulbCreator();
//    Creator* tf = new TubeCreator();
//    
//    Light* bl = bf->LightFactory();
//    Light* tl = tf->LightFactory();
//    
//    bl->TurnOn();
//    bl->TurnOff();
//    
//    cout << " ------------- " << endl;
//    
//    tl->TurnOn();
//    tl->TurnOff();

总结：

/*********************
 
1. 简单工厂： 
这个模式常见的实施是，基类扮演工厂的角色。基类一般是个抽象类，定义出该类及其派生类的借口，同时提供静态方法，以返回派生类的对象。
客户使用这些类是很方便的，只需要提供派生类的名字，就可以得到类的对象。
类库设计者要扩展类也是很灵活的，只需继承那个抽象类，并修改基类的静态方法就可。

2. 工厂方法
工厂方法就是，对应每一个产品，都提供一个对应的工厂实现。工厂和产品基本一一对应，基类都是一个抽象类。感觉这个模式不是很实用，
像是为了引出抽象工厂而准备的。

3. 抽象工厂
抽象工厂包括创建多个抽象产品的工厂方法，每个抽象产品对应一个产品族，如在多平台上的文本，按钮，菜单等。
抽象工厂的一个派生类实现 某一类的各个产品的创建， 如windows上的 文本， 按钮， 菜单 等的创建；当然，文本，按钮，菜单本身也属于
各自的抽象基类。
 
当要支持新的平台的时候，就创建一个工厂的派生类。可以很灵活的扩展。 

**********************/ 
            

#endif
