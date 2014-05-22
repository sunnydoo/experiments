// myluadll.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include "myluadll.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

static int lua_hello(lua_State* L)
{
	printf("hello, welcome to my first lua's C lib\n");
	return 1;
}

static int lua_sin(lua_State* L)
{
	double d = luaL_checknumber(L, 1);
	lua_pushnumber(L, sin(d));
	return 1;
}

static const struct luaL_reg mylib[] = 
{
	{"hello", lua_hello},
	{"mysin", lua_sin},
	{NULL, NULL}
};


// This is an example of an exported function.
MYLUADLL_API int luaopen_mylib(lua_State* L)
{
	luaL_register(L, "myluadll", mylib);
	//luaL_openlib(L, "myluadll", mylib, 0);
	return 1;
}
