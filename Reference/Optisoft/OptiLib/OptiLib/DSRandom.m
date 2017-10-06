//
//  DSRandom.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSRandom.h"
#import "DSTime.h"

static const float kDSFloatMaxULong = ULONG_MAX;

static void mt_srand(unsigned seed);
static unsigned long mt_rand();

@implementation DSRandom

+ (void)initialize {
    
    mt_srand((unsigned)[DSTimer nanoTime]);
}

+ (unsigned long)random {
    
    return mt_rand();
}

+ (unsigned long)randomUintBetween:(unsigned int)low and:(unsigned int)high {
    
    assert(high > low);
    
    return low + mt_rand() % (high - low);
}

+ (int)randomIntBetween:(int)low and:(int)high {
    
    assert(high > low);
    
    return (int)(low + mt_rand() % (high - low));
}

+ (float)randomFloat {
    
    return mt_rand() / kDSFloatMaxULong;
}

+ (float)randomFloatBetween:(float)low and:(float)high {
    
    assert(high > low);
    
    return low + mt_rand() / kDSFloatMaxULong * (high - low);
}

@end

#pragma mark - Mersenne twister

#define MT_LEN 624
#include <stdlib.h>

int mt_index;
unsigned long mt_buffer[MT_LEN];

static void mt_srand(unsigned seed) {
    
    srand(seed);
    
    for (int i = 0; i < MT_LEN; i++) mt_buffer[i] = rand();
    
    mt_index = 0;
}

#define MT_IA           397
#define MT_IB           (MT_LEN - MT_IA)
#define UPPER_MASK      0x80000000
#define LOWER_MASK      0x7FFFFFFF
#define MATRIX_A        0x9908B0DF
#define TWIST(b,i,j)    ((b)[i] & UPPER_MASK) | ((b)[j] & LOWER_MASK)
#define MAGIC(s)        (((s)&1)*MATRIX_A)

static unsigned long mt_rand() {
    
    unsigned long   *b = mt_buffer;
    int             idx = mt_index, i;
    unsigned long   s;
    
    if (idx == MT_LEN * sizeof(unsigned long)) {
        
        idx = i = 0;
        
        for (; i < MT_IB; i++) {
            
            s = TWIST(b, i, i+1);
            b[i] = b[i + MT_IA] ^ (s >> 1) ^ MAGIC(s);
        }
        
        for (; i < MT_LEN-1; i++) {
            
            s = TWIST(b, i, i+1);
            b[i] = b[i - MT_IB] ^ (s >> 1) ^ MAGIC(s);
        }
        
        s = TWIST(b, MT_LEN-1, 0);
        b[MT_LEN-1] = b[MT_IA-1] ^ (s >> 1) ^ MAGIC(s);
    }
    
    mt_index = idx + sizeof(unsigned long);
    
    return *(unsigned long *)((unsigned char *)b + idx);
}


