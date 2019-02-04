//
//  move_semantics.cpp
//  CPP14Messing
//
//  Created by Richard Henry on 04/02/2019.
//  Copyright © 2019 Dogstar Industries Ltd. All rights reserved.
//

#include "move_semantics.hpp"

#include <cstring>
#include <iostream>
#include <algorithm>

class string {
    
    char        *data;
    
public:
    explicit string(const char * p) {
        
        const auto size = strlen(p) + 1;
        
        data = new char[size];
        memcpy(data, p, size);
    }
    
    ~string() { delete[] data; }
    
    // Copy constructor
    string(const string &that) {
        
        const auto size = strlen(that.data) + 1;
        
        data = new char[size];
        memcpy(data, that.data, size);
    }
    
    // Move constructor
    string(string &&that) {
        
        data = that.data;
        that.data = nullptr;
    }
    
    // Operator overloads
    string operator+(string const &that) {
        
        return string(strcat(data, that.data));
    }
    
    string &operator=(string that) {
        
        std::swap(data, that.data);
        
        return *this;
    }
    
    // Debug
    void print() { std::cout << data << std::endl; }
};

static string some_function_returning_a_string() {
   
    return string("returned from func");
}

void moveSemanticMess() {
    
    string x("hello, x"), y("hello y");
    
    string a(x); a.print();
    string b(x + y); b.print();
    string c(some_function_returning_a_string()); c.print();
}
