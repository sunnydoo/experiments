/*

准备一组算法，并将每一个算法封装起来，使得它们可以互换

*/

#ifndef __VISITOR_H__
#define __VISITOR_H__
#include <cstdlib>
#include <list>
#include <iostream>
#include <string>

using namespace std;

class Strategy
{
public:
   virtual void AlgmInterface() = 0;
};

class RealStrategyA : public Strategy
{
public:
   void AlgmInterface()
   {
      cout<<"Called RealStrategyA AlgmInterface()" << endl;
   }
};

class RealStrategyB : public Strategy
{
public:
   void AlgmInterface()
   {
      cout<<"Called RealStrategyB AlgmInterface()" << endl;
   }
};

class RealStrategyC : public Strategy
{
public:
   void AlgmInterface()
   {
      cout<<"Called RealStrategyC AlgmInterface()" << endl;
   }
};

//the one which use algorithem
class Context
{
private:
   Strategy* s;

public:
   Context(Strategy* sg) : s(sg) {};
   void Calculate()
   {
      s->AlgmInterface();
   }
};

/***************************
How to use it?

//算法 
   RealStrategyA* a = new RealStrategyA();
   RealStrategyB* b = new RealStrategyB();
   RealStrategyC* c = new RealStrategyC();

//环境   
   Context* ca = new Context(a);
   Context* cb = new Context(b);
   Context* cc = new Context(c);
   
   ca->Calculate();
   cb->Calculate();
   cc->Calculate();


****************************/

#endif
