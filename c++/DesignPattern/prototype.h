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
ԭ��ģʽ����˵����Ϊ�ഴ��һ�� clone ������������Ϳ��Ե�����������������ʵ�� 

****************************/


#endif
