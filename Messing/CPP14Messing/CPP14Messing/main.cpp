//
//  main.cpp
//  CPP14Messing
//
//  Created by Richard Henry on 01/02/2019.
//  Copyright © 2019 Dogstar Industries Ltd. All rights reserved.
//

#include <iostream>

namespace MyNameSpace {
    
    int twentyThree() { return 23; }
    
    class Nowt {
        
        public:
        Nowt() { std::cout << "Nowt null constructor" << std::endl; }
        ~Nowt() { std::cout << "Nowt null destructor" << std::endl; }
        
        inline int gibNumber() { return twentyThree(); }
    };
}

int main(int argc, const char * argv[]) {
    
    MyNameSpace::Nowt nowt;
    MyNameSpace::Nowt *nowtDynamic = new MyNameSpace::Nowt();

    auto autoInt = nowtDynamic->gibNumber();
    
    delete nowtDynamic;
    
    std::cout << "Hello, World!\n" << autoInt << std::endl;
    
    return 0;
}
