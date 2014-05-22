#ifndef __CHAINOFRESP_H__
#define __CHAINOFRESP_H__
#include <cstdlib>
#include <iostream>
#include <string>

using namespace std;

class Handler
{
protected:
   Handler *next;

public:
   void SetNext(Handler* next)
   {
      this->next = next;
   }
   
   virtual void HandleRequest(int req) = 0;
};

class RealHandler1 : public Handler
{

public:
   void HandleRequest(int req)
   {
      if(req < 0)
      {
         cout << "Less than 0, I take care" << endl;
      }
      else if(next != NULL)
      {
         next->HandleRequest(req);
      }

   }
};

class RealHandler2 : public Handler
{

public:
   void HandleRequest(int req)
   {
      if(req > 0 && req < 10)
      {
         cout << "Less than 10, My turn" << endl;
      }
      else if(next != NULL)
      {
         next->HandleRequest(req);
      }

   }
};

class RealHandler3 : public Handler
{
public:
   void HandleRequest(int req)
   {
      if(req > 10)
      {
         cout << "Larger than 10, I will do it" << endl;
      }
      else if(next != NULL)
      {
         next->HandleRequest(req);
      }
   }  
};


/****************************
How to use it

   RealHandler1 *rh1 = new RealHandler1();
   RealHandler2 *rh2 = new RealHandler2();
   RealHandler3 *rh3 = new RealHandler3();
   
   rh1->SetNext(rh2);
   rh2->SetNext(rh3);
   
   int Reqs[] = {-1, 3, 4, 12, 8, 30, 41, -14};
   
   for(int i=0; i<8; i++)
   {
      rh1->HandleRequest(Reqs[i]);
   }
   
   delete rh1;
   delete rh2;
   delete rh3;


******************************/


#endif
