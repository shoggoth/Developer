//
//  CPPMessingLib.cpp
//  CPPMessingLib
//
//  Created by Richard Henry on 31/01/2019.
//  Copyright © 2019 Dogstar Industries Ltd. All rights reserved.
//

#include <iostream>
#include "CPPMessingLib.hpp"
#include "CPPMessingLibPriv.hpp"

void CPPMessingLib::HelloWorld(const char * s)
{
    CPPMessingLibPriv *theObj = new CPPMessingLibPriv;
    theObj->HelloWorldPriv(s);
    delete theObj;
};

void CPPMessingLibPriv::HelloWorldPriv(const char * s) 
{
    std::cout << s << std::endl;
};

