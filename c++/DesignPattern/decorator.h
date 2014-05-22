//Also called "wrapper"

#ifndef PROTOTYPE_H
#define PROTOTYPE_H
#include <cstdlib>
#include <iostream>
#include <string>

using namespace std;

class Component 
{
public:
   virtual void Operation() = 0;
};

class RealComp : public Component 
{
public:
   void Operation() 
   {
      cout << "RealComp Operation()" << endl;  
   }
};

class Decorator : public Component
{
private:
   Component *comp;
   
public:
   void SetComp(Component* comp)
   {
      this->comp = comp;
   }
   
   void Operation()
   {
      if(comp != NULL)
         comp->Operation();
   }
};


class RealDecoratorA : public Decorator
{
public:
   void Operation()
   {
      Decorator::Operation();
      cout << "RealDecoratorA Operation()" << endl;
   }
};

class RealDecoratorB : public Decorator
{
public:
   void Operation()
   {
      Decorator::Operation();
      cout << "\n-------------------------" << endl;
      cout << "---- from seperator -----\n" <<endl;  
   }
};

class RealDecoratorC : public Decorator
{
public:
   void Operation()
   {
      Decorator::Operation();
      cout << "RealDecoratorC++++++ Operation()" << endl;
   }
};


/***************************************

注意，一定要先将 RealComp 对象 SetComp 上 
   Component *rc = new RealComp();
   Decorator *rda = new RealDecoratorA();
   Decorator *rdb = new RealDecoratorB();   
   Decorator* rdc = new RealDecoratorC();
   
   rdb->SetComp(rc);
   rdb->Operation();

   rda->SetComp(rc);
   rdb->SetComp(rda);
   rdb->Operation();

   rdc->SetComp(rda);
   rdb->SetComp(rdc);
   rdb->Operation();

****************************************/

#endif
