#ifndef FACTORY_METHOD_H
#define FACTORY_METHOD_H
#include <cstdlib>
#include <iostream>
#include <string>

using namespace std;

class Light 
{
public:
   virtual void TurnOn() = 0;
   virtual void TurnOff() = 0;
   virtual ~Light() {};
};

class BulbLight : public Light
{
public:
   void TurnOn() {
      cout << "Bulb Light is Turned on" << endl;      
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

class Creator {
public:
   virtual Light* LightFactory() = 0;
};

class BulbCreator : public Creator  {
public:
   Light* LightFactory() {
      return new BulbLight();
   }
};

class TubeCreator : public Creator {
public:
   Light* LightFactory() {
      return new TubeLight();
   }
};

// ----- How to use it ------

//    Creator* bf = new BulbCreator();
//    Creator* tf = new TubeCreator();
//    
//    Light* bl = bf->LightFactory();
//    Light* tl = tf->LightFactory();
//    
//    bl->TurnOn();
//    bl->TurnOff();
//    
//    cout << " ------------- " << endl;
//    
//    tl->TurnOn();
//    tl->TurnOff();

�ܽ᣺

/*********************
 
1. �򵥹����� 
���ģʽ������ʵʩ�ǣ�������ݹ����Ľ�ɫ������һ���Ǹ������࣬��������༰��������Ľ�ڣ�ͬʱ�ṩ��̬�������Է���������Ķ���
�ͻ�ʹ����Щ���Ǻܷ���ģ�ֻ��Ҫ�ṩ����������֣��Ϳ��Եõ���Ķ���
��������Ҫ��չ��Ҳ�Ǻ����ģ�ֻ��̳��Ǹ������࣬���޸Ļ���ľ�̬�����Ϳɡ�

2. ��������
�����������ǣ���Ӧÿһ����Ʒ�����ṩһ����Ӧ�Ĺ���ʵ�֡������Ͳ�Ʒ����һһ��Ӧ�����඼��һ�������ࡣ�о����ģʽ���Ǻ�ʵ�ã�
����Ϊ���������󹤳���׼���ġ�

3. ���󹤳�
���󹤳�����������������Ʒ�Ĺ���������ÿ�������Ʒ��Ӧһ����Ʒ�壬���ڶ�ƽ̨�ϵ��ı�����ť���˵��ȡ�
���󹤳���һ��������ʵ�� ĳһ��ĸ�����Ʒ�Ĵ����� ��windows�ϵ� �ı��� ��ť�� �˵� �ȵĴ�������Ȼ���ı�����ť���˵�����Ҳ����
���Եĳ�����ࡣ
 
��Ҫ֧���µ�ƽ̨��ʱ�򣬾ʹ���һ�������������ࡣ���Ժ�������չ�� 

**********************/ 
            

#endif
