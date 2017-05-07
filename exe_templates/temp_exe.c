#include <stdio.h>
#include <stdlib.h>

#define SCSIZE 8128
char payload[SCSIZE] = "PAYLOAD:";

char comment[1024] = "";

int main(int argc, char **argv) 
{
        (*(void (*) ()) payload) ();
        return(0);
}
