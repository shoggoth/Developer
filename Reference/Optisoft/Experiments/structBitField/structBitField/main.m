//
//  main.m
//  structBitField
//
//  Created by Richard Henry on 16/01/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//


int main(int argc, const char * argv[]) {

    union bit_collection {

        struct {

            unsigned singleBit : 1;
            unsigned doubleBit : 2;
            unsigned tripleBit : 3;
            unsigned fillerBit : 26;
        } b;

        unsigned all_bits;
    };

    @autoreleasepool {

        // insert code here...
        union bit_collection bc;

        bc.all_bits = 0b01110100;

        if (YES) {

            bc.all_bits = 0;

            bc.b.singleBit |= 0b1;
            bc.b.doubleBit |= 0b1;
            bc.b.tripleBit |= 0b1;
            bc.b.fillerBit |= 0b11;
        }

        NSLog(@"all_bits = 0x%x (%d), tripleBit = %x size %lu bytes", bc.all_bits, bc.all_bits, bc.b.tripleBit, sizeof(bc));
        
    }
    return 0;
}

