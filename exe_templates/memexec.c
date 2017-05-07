/* In memory execution example */
/*
Author: Amit Malik
http://www.securityxploded.com
Compile in Dev C++
*/

#include 
#include 
#include 

#define DEREF_32( name )*(DWORD *)(name)

int main()
{
     char file[20];
     HANDLE handle;
     PVOID vpointer;
     HINSTANCE laddress;
     LPSTR libname;
     DWORD size;
     DWORD EntryAddr;
     int state;
     DWORD byteread;
     PIMAGE_NT_HEADERS nt;
     PIMAGE_SECTION_HEADER section;
     DWORD dwValueA;
     DWORD dwValueB;
     DWORD dwValueC;
     DWORD dwValueD; 

     printf("Enter file name: ");
     scanf("%s",&file);

          
           
     // read the file
     printf("Reading file..\n");
     handle = CreateFile(file,GENERIC_READ,0,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
     
     // get the file size
     size = GetFileSize(handle,NULL);
     
     // Allocate the space 
     vpointer = VirtualAlloc(NULL,size,MEM_COMMIT,PAGE_READWRITE);
     
     // read file on the allocated space
     state = ReadFile(handle,vpointer,size,&byteread,NULL);
     CloseHandle(handle);
     printf("You can delete the file now!\n");
     system("pause");
     
     // read NT header of the file
     nt = PIMAGE_NT_HEADERS(PCHAR(vpointer) + PIMAGE_DOS_HEADER(vpointer)->e_lfanew);
     handle = GetCurrentProcess();
     
     // get VA of entry point
     EntryAddr = nt->OptionalHeader.ImageBase + nt->OptionalHeader.AddressOfEntryPoint;
     
     // Allocate the space with Imagebase as a desired address allocation request
     PVOID memalloc = VirtualAllocEx(
                                     handle, 
                                     PVOID(nt->OptionalHeader.ImageBase), 
                                     nt->OptionalHeader.SizeOfImage, 
                                     MEM_RESERVE | MEM_COMMIT, 
                                     PAGE_EXECUTE_READWRITE
                                     );
    
     // Write headers on the allocated space
     WriteProcessMemory(handle, 
     memalloc, 
     vpointer, 
     nt->OptionalHeader.SizeOfHeaders, 
     0
     );
     
     
     // write sections on the allocated space
     section = IMAGE_FIRST_SECTION(nt);
     for (ULONG i = 0; i < nt->FileHeader.NumberOfSections; i++) 
     {
         WriteProcessMemory(
                           handle, 
                           PCHAR(memalloc) + section[i].VirtualAddress, 
                           PCHAR(vpointer) + section[i].PointerToRawData, 
                           section[i].SizeOfRawData, 
                           0
                           );
     }
     
     // read import dirctory    
     dwValueB = (DWORD) &(nt->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT]);
     
     // get the VA 
     dwValueC = (DWORD)(nt->OptionalHeader.ImageBase) + 
                          ((PIMAGE_DATA_DIRECTORY)dwValueB)->VirtualAddress;
     
     
     while(((PIMAGE_IMPORT_DESCRIPTOR)dwValueC)->Name)
     {
            // get DLL name
            libname = (LPSTR)(nt->OptionalHeader.ImageBase + 
                              ((PIMAGE_IMPORT_DESCRIPTOR)dwValueC)->Name);
                              
            // Load dll
            laddress = LoadLibrary(libname);
            
            // get first thunk, it will become our IAT
            dwValueA = nt->OptionalHeader.ImageBase + 
                                  ((PIMAGE_IMPORT_DESCRIPTOR)dwValueC)->FirstThunk;
            
            // resolve function addresses
            while(DEREF_32(dwValueA))
            {
                dwValueD = nt->OptionalHeader.ImageBase + DEREF_32(dwValueA);
                // get function name 
                LPSTR Fname = (LPSTR)((PIMAGE_IMPORT_BY_NAME)dwValueD)->Name;
                // get function addresses
                DEREF_32(dwValueA) = (DWORD)GetProcAddress(laddress,Fname);
                dwValueA += 4;
            }

            dwValueC += sizeof( IMAGE_IMPORT_DESCRIPTOR );

     }
   
   
     // call the entry point :: here we assume that everything is ok.
     ((void(*)(void))EntryAddr)();
           
}
           
