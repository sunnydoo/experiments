/*
�ֽз���-����(Publish/Subscribe), ģ��-��ͼ��Model/View)ģʽ��
Դ-����(Source/Listener)ģʽ 
*/
#ifndef __OBSERVER_H__
#define __OBSERVER_H__
#include <cstdlib>
#include <list>
#include <iostream>
#include <string>

using namespace std;

class Observer
{
public:
   virtual void Update() = 0; 
};

class Subject
{
private:
   list<Observer*> obsrs;
   list<Observer*>::iterator it;
  
public:
   void Attach(Observer *ob)
   {
      obsrs.push_back(ob); 
   };
   
   void Notify()
   {
      for(it=obsrs.begin(); it != obsrs.end(); it++)
      {
         (*it)->Update();
      }  
   }
   
   virtual int State() = 0;
   virtual void Change(int) = 0;
};

class RealObserver : public Observer
{
private:
   Subject *sub;
   int k;
public:
   RealObserver(Subject* s, int i=0):sub(s), k(i) {}
   void Update()
   {
      cout <<"Observer:" << k ;
      cout <<"  -- Report Subject State" << sub->State() << endl;
   }
};

class RealSubject : public Subject
{
private:
   int d;
public:
   RealSubject(int i = 0) : d(i) {}
   void Change(int a)
   {
      d = a;
   }
   int State()
   {
      return d;
   }
};




#endif
