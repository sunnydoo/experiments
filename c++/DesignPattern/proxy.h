#ifndef __PROXY_H__
#define __PROXY_H__
#include <cstdlib>
#include <iostream>
#include <string>

using namespace std;

class Subject
{
public:
   virtual void Request() = 0;
   virtual ~Subject() {};
};

class RealSubject : Subject
{
public:
   void Request()
   {
      cout << "Called RealSubject.Request()" << endl;
   }
};

class Proxy : public Subject
{
   RealSubject *ro;
   
public:
   Proxy() : ro(NULL)
   {
   }
   
   void PreRequest()
   {
      cout <<"PreRequest"<<endl;
   }
   void PostRequest()
   {
      cout <<"PostRequest"<<endl;
   }
   void Request()
   {
      if( ro == NULL )
         ro = new RealSubject();
         
      PreRequest();
      ro->Request();
      PostRequest();
   }
   
   ~Proxy()
   {
      if(ro != NULL)
         delete ro;
         
      ro = NULL;
   }
};

/*******************************************
  How to use it?
  
   Proxy *p = new Proxy();
   p->Request();

Proxy 与 Adapter 的区别

Adapter，当客户期望类库提供某些特定的借口，而目标类库不能提供的时候，使用Adapter
模式，将目标类库的接口通过封装，得到客户想要的接口

Proxy，当目标类库不方便被直接使用时，使用Proxy将目标类库封装起来，客户操作Proxy,就相当于
在操作目标类库一样
 
********************************************/


#endif
