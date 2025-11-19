#include <types.h>


extern void puts(char* str);


void kmain(void){

    puts("[done]\n");
    puts("Hello from C kernel main!\n");

    while(true);
    
}