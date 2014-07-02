//  Created by ProbablyInteractive.
//  Copyright 2009 Probably Interactive. All rights reserved.

#import <Foundation/Foundation.h>
#import "lua.h"

#define WAX_VERSION 0.93

void wax_init(); // 初始化执行环境

void wax_run(char* initScript);

lua_State *wax_currentLuaState();

void luaopen_wax(lua_State *L);
