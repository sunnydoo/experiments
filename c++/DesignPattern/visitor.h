/*
提供将 <数据结构> 和施加于 <数据结构上的方法> 分开 
Element 保存数据
Visitor 实现算法
该模式实现将某一算法施加于某类未知数据结构的能力 
*/
#ifndef __VISITOR_H__
#define __VISITOR_H__
#include <cstdlib>
#include <list>
#include <iostream>
#include <string>

using namespace std;

class Visitor;
class Element
{
public:
   virtual int Id() = 0;
   virtual void Accept(Visitor*) = 0;
};

class Visitor
{
public:
   virtual void Visit(Element*) = 0;
};

class RealVisitor1 : public Visitor
{
private:
   int k;
public:
   explicit RealVisitor1(int i=1) : k(i) {};
   void Visit(Element* a)
   {
      cout << k << "[visitor] visited " << a->Id() << endl;
   }
};

class RealVisitor2 : public Visitor
{
private:
   int k;
public:
   explicit RealVisitor2(int i=2) : k(i) {};
   void Visit(Element* a)
   {
      cout << k << "[visitor] visited " << a->Id() << endl;
   }
};

class RealElemA : public Element
{
private:
   int id;
public:
   RealElemA(int a = 101) : id(a) {}
   int Id()
   {
      return id;
   }
   
   void Accept(Visitor* v)
   {
      v->Visit(this);
   }
};

class RealElemB : public Element
{
private:
   int id;
public:
   RealElemB(int a = 102) : id(a) {}
   int Id()
   {
      return id;
   }
   
   void Accept(Visitor* v)
   {
      v->Visit(this);
   }
};

class ObjList
{
private:
   list<Element*> elist;
public:
   void Attach(Element* e)
   {
      elist.push_back(e);
   }
   
   void Accept(Visitor* v)
   {
      list<Element*>::iterator itr;
      for(itr = elist.begin(); itr != elist.end(); itr++)
      {
         (*itr)->Accept(v);
      }
   }
};

/*---------------------
How to use it?

   ObjList* ol = new ObjList();
   RealElemA* rma = new RealElemA();
   RealElemB* rmb = new RealElemB();
   ol->Attach(rma);
   ol->Attach(rmb);
   
   RealVisitor1 *rv1 = new RealVisitor1();
   RealVisitor2 *rv2 = new RealVisitor2();
   
   ol->Accept(rv1);
   ol->Accept(rv2);
   
   delete(rma);
   delete(rmb);
   delete(rv1);
   delete(rv2);
   
-----------------------*/

#endif
