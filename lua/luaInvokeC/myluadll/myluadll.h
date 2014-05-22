// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the MYLUADLL_EXPORTS
// symbol defined on the command line. This symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// MYLUADLL_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#ifndef _MYLUADLL_INCLUDE_
#define _MYLUADLL_INCLUDE_


#ifdef MYLUADLL_EXPORTS
#define MYLUADLL_API __declspec(dllexport) 
#else
#define MYLUADLL_API __declspec(dllimport) 
#endif

#include "lua.hpp"
MYLUADLL_API int luaopen_mylib(lua_State* L);
//MYLUADLL_API int lua_sin(lua_State* L);



#endif //_MYLUADLL_INCLUDE_
