/**
又叫 Action 模式， 或者Transaction 模式 
*/
#ifndef __COMMAND_H__
#define __COMMAND_H__
#include <cstdlib>
#include <iostream>
#include <string>

using namespace std;

class Receiver
{
public:
   void Action()
   {
      cout << "Called Receier.Action()" << endl;
   }
};

class Command
{
protected:
   Receiver *rcv;
   
public:
   Command(Receiver *rcv)
   {
      this->rcv = rcv;
   }
   
   virtual void Execute() = 0;
};

class RealCmd : public Command
{
public:
   RealCmd(Receiver *rcv) : Command(rcv) {}
   void Execute()
   {
      rcv->Action();
   }
};

class Invoker
{
private:
   Command* cmd;

public:
   void SetCmd(Command* cmd)
   {
      this->cmd = cmd;
   }
   
   void ExecuteCmd()
   {
      cmd->Execute();
   }
};


#endif
