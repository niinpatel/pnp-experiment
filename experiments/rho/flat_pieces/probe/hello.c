#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
int main(){ uint64_t x=0xF0F0; printf("pop %d sqrt %f\n", __builtin_popcountll(x), sqrt(2.0)); return 0; }
