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

Proxy �� Adapter ������

Adapter�����ͻ���������ṩĳЩ�ض��Ľ�ڣ���Ŀ����ⲻ���ṩ��ʱ��ʹ��Adapter
ģʽ����Ŀ�����Ľӿ�ͨ����װ���õ��ͻ���Ҫ�Ľӿ�

Proxy����Ŀ����ⲻ���㱻ֱ��ʹ��ʱ��ʹ��Proxy��Ŀ������װ�������ͻ�����Proxy,���൱��
�ڲ���Ŀ�����һ��
 
********************************************/


#endif
