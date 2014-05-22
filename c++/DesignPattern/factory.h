#ifndef FACTORY_H
#define FACTORY_H
#include <cstdlib>
#include <iostream>
#include <string>

using namespace std;

class Light 
{
public:
   static Light* Create(string LightType);
   virtual void TurnOn() = 0;
   virtual void TurnOff() = 0;
   virtual ~Light() {};
};

class BulbLight : public Light
{
public:
   void TurnOn() {
      cout << " Bulb Light is Turned on" << endl;      
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

class SimpleFactory
{
public:
   Light* Create(string LightType)
   {
      if(LightType.compare("Bulb") == 0)
         return new BulbLight();
      else if(LightType.compare("Tube") == 0 )
         return new TubeLight();
      else
         return NULL;
   }
   
};

//----How to use it? ------ 

// Light* l = Light::Create("Tube");
// l->TurnOn();
// l->TurnOff();
// delete l;

#endif
