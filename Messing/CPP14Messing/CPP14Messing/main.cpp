//
//  main.cpp
//  CPP14Messing
//
//  Created by Richard Henry on 01/02/2019.
//  Copyright © 2019 Dogstar Industries Ltd. All rights reserved.
//

#include <iostream>

#include "summat.hpp"
#include "array.hpp"
#include "stack.hpp"

namespace Local {
    
    int twentyThree() { return 23; }
    
    class Nowt {
        
        public:
        Nowt() { std::cout << "Nowt null constructor" << std::endl; }
        ~Nowt() { std::cout << "Nowt null destructor" << std::endl; }
        
        inline int gibNumber() { return twentyThree(); }
    };
}

static void arrayMess() {
    
    int rawInts[] = { 1, 2, 3, 4, 5 };
    Summat rawSummats[] = { Summat(1) };
    
    DataStructures::Array<int> intArray(rawInts, 10);
    DataStructures::Array<Summat> summatArray(rawSummats, 1);

    intArray.print();
    summatArray.print();
}

static void stackMess() {
    
}

static int localMess() {
    
    Local::Nowt nowt;
    Local::Nowt *nowtDynamic = new Local::Nowt();
    
    Summat summat(42);
    Summat *summatDynamic = new Summat(43);
    
    auto autoInt = nowtDynamic->gibNumber();
    
    delete nowtDynamic;
    delete summatDynamic;
    return autoInt;
}

int main(int argc, const char * argv[]) {
    
    int autoInt = localMess();
    
    arrayMess();
    
    std::cout << "Hello, World!\n" << autoInt << std::endl;
    
    return 0;
}

