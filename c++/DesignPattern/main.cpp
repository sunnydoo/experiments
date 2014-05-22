#include <iostream>
#include <windows.h>
//#include <tchar.h>
using namespace std;

int main ()
{

   PROCESS_INFORMATION   procInfo;
   STARTUPINFO           startup;
   
  ZeroMemory( &startup, sizeof(startup) );
  startup.cb = sizeof(startup);
  ZeroMemory( &procInfo, sizeof(procInfo) ); 
     
   startup.dwFlags    = STARTF_USESTDHANDLES;
   startup.hStdOutput = GetStdHandle(STD_OUTPUT_HANDLE);
   startup.hStdError  = GetStdHandle(STD_OUTPUT_HANDLE);
   
   LPTSTR szCmdline1 = TEXT("\"C:\\Program Files\\WinZip\\wzunzip.exe\" -o -d d:\\abc.zip d:\\star\\");
   LPTSTR szCmdline2 = TEXT("\"C:\\Program Files\\WinRAR\\RAR.exe\" x -y d:\\ssl.rar *.* d:\\star\\\\\\");
   LPTSTR szCmdline3 = TEXT("D:\\7z.exe x d:\\abc.zip -od:\\star -y");


   LPTSTR szCmdline = szCmdline2; 
 //system(szCmdline);   //Succeed 

   //Fail, but bStatus is nonzero, which means correct.
   //Copy the command to cmd.exe, it executes successfully. 
   BOOL bStatus = CreateProcess(NULL,
                          szCmdline,
                          NULL,
                          NULL,
                          TRUE,         /* inherit handles */
                          DETACHED_PROCESS,
                          NULL,         /* inherit parents environment */
                          NULL,
                          &startup,
                          &procInfo);

                       
   if(bStatus == 0)
   {
      DWORD dw = GetLastError();
      cout << "Failed: Error code" << dw << endl;
   }
   else
   {
      cout << "Succeed.. " << endl;
   }

    // Wait until child process exits.
    WaitForSingleObject( procInfo.hProcess, INFINITE );

    // Close process and thread handles. 
    CloseHandle( procInfo.hProcess );
    CloseHandle( procInfo.hThread );


  system("PAUSE");
  return 0;
}
