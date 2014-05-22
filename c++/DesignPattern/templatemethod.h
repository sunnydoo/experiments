#ifndef __TEMPLATEMETHOD_H__
#define __TEMPLATEMETHOD_H__
#include <cstdlib>
#include <list>
#include <iostream>
#include <string>

using namespace std;

class AstClass
{
protected:
   virtual void AtomOperation1() = 0;
   virtual void AtomOperation2() = 0;

public:
   void TemplateMethod()
   {
      cout<<"In Abstract Class: TemplateMethod()"<<endl;
      AtomOperation1();
      AtomOperation2();
   }
};

class RealClass : public AstClass
{
public:
   void AtomOperation1()
   {
      cout << "Real Class Method 1" << endl;
   }
   void AtomOperation2()
   {
      cout << "Real Class Method 2" << endl;
   }

};

/******************************
How to use it

   RealClass *rc = new RealClass();
   rc->TemplateMethod();

*******************************/
#endif
