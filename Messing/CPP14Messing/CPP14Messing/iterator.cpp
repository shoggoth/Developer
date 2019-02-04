//
//  iterator.cpp
//  CPP14Messing
//
//  Created by Richard Henry on 04/02/2019.
//  Copyright © 2019 Dogstar Industries Ltd. All rights reserved.
//

#include "iterator.hpp"

#include <iostream>
#include <vector>

void iteratorMess() {
    
    std::vector<int> intVector = { 0, 1, 2, 3, 4, 5, 23 };
    
    for (auto i : intVector) { std::cout << i << ", "; }
}
