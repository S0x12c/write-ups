#include <stdio.h>

extern int asm0(int a, int b);

int main()
{
    int a = 0xc9;
    int b = 0xb0;
    printf("Result: %x\n", asm0(a, b));
    return 0;
}
