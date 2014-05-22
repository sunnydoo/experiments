#ifndef SINGLETON_H
#define SINGLETON_H
#include <cstdlib>
#include <iostream>
#include <string>

using namespace std;

class Singleton
{
private:
   static Singleton* ins;
   
protected:
   Singleton() { }
   
public:
   static Singleton* Instance()
   {
      if(ins == NULL)
      {
         cout << "Create new object" << endl;
         ins = new Singleton();
      }
      else 
      {
         cout << "Use existing one" << endl;
      }
         
      return ins;
   };
   

   ~Singleton()
   {
      if(ins != NULL)
         delete ins;
   };

};

// Please Note: 
// static member must be initiated outside.
// member fields should be initiated in parameter list.

Singleton* Singleton::ins = NULL; 

#endif
