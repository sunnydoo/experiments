#ifndef PROTOTYPE_H
#define PROTOTYPE_H
#include <cstdlib>
#include <iostream>
#include <string>

class Prototype
{
private:
   string id;

public:
   Prototype(string id)
   {
      this->id = id
   }
   
   string Id() {
      return id;
   }
   
   virtual Prototype Clone() = 0;
};


class RealPrototype1 : public Prototype
{
public:
   RealPrototype1(string id):Prototype(id) {}
   Prototype Clone()
   {
   }
}


/***************************
原型模式，简单说就是为类创建一个 clone 方法，这样类就可以调用这个方法创建类的实例 

****************************/


#endif
