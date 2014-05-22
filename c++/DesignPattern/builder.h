#ifndef BUILDER_H
#define BUILDER_H
#include <cstdlib>
#include <iostream>
#include <string>
#include <list>

using namespace std;
class Product
{
private: 
   list<string> mylist;
   list<string>::iterator it;
public:
   void Add(string str)
   {
      mylist.push_back(str);
   }
   
   void show()
   {
      cout << "Product Parts -------" << endl;
      int k = mylist.size();
      for(it=mylist.begin(); it!=mylist.end();it++)
         cout << *it << endl;
   }
};

class Builder
{
public:
   virtual void BuildPartA() = 0;
   virtual void BuildPartB() = 0;
   virtual Product* GetInst() = 0;
};

class RealBuilder1 : public Builder
{
private:
   Product* prod;

public:
   void BuildPartA()
   {
      prod = new Product();
      prod->Add("Part A");
   }
   
   void BuildPartB()
   {
      prod->Add("Part B");
   }
   
   Product* GetInst()
   {
      return prod;
   }
};

class RealBuilder2 : public Builder
{
private:
   Product* prod;

public:
   void BuildPartA()
   {
      prod = new Product();
      prod->Add("Part X");
   }
   
   void BuildPartB()
   {
      prod->Add("Part Y");
   }
   
   Product* GetInst()
   {
      return prod;
   }
};


class Director
{
public:
   void Contruct(Builder* builder)
   {
      builder->BuildPartA();
      builder->BuildPartB();
   }
};


/*********************************
How to use it?

   Director *dirt = new Director();
   
   Builder *b1 = new RealBuilder1();
   Builder *b2 = new RealBuilder2();
   
   dirt->Contruct(b1);
   Product *p1 = b1->GetInst();
   p1->show();
   
   dirt->Contruct(b2);
   Product *p2 = b2->GetInst();
   p2->show();

**********************************/
#endif
