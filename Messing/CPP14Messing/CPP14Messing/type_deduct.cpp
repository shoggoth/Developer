//
//  type_deduct.cpp
//  CPP14Messing
//
//  Created by Richard Henry on 04/02/2019.
//  Copyright © 2019 Dogstar Industries Ltd. All rights reserved.
//

#include "type_deduct.hpp"

#include <iostream>

template <typename T> void inc(T& param) {
    
    param++;
}

template <typename T> T inc2(T param) {
    
    return ++param;
}

template <typename T> T add(T param) { std::cout << __PRETTY_FUNCTION__ << "\n"; return param; }

template <typename T, typename... Args> T add(T first, Args... args) {
    
    std::cout << __PRETTY_FUNCTION__ << "\n";
    
    return first + add(args...);
}

void typeDeductMess() {
    
    int x = inc2(23);
    
    inc(x);
    
    std::cout << "x is now " << x << std::endl;
    
    long sum = add(1, 2, 3, 8, 7);
    
    std::string s1 = "x", s2 = "aa", s3 = "bb", s4 = "yy";
    std::string ssum = add(s1, s2, s3, s4);
}
