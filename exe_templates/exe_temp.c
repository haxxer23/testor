#include <stdio.h>
#include <windows.h>
//only for x64
//Beep
char shellcode[] = "\x54\x58\x2d\xd3\x24\xff\xff\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x5c\x25\x00\x00\x00\x00\x25\x00\x00\x00\x00\x2d\x00\x00\x00\xb0\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x00\x00\xd3\x4f\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x7d\xd2\x2c\x00\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x56\x57\x0f\x4a\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x2d\xd6\xf0\x65\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x00\x00\xd3\x4f\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x4d\xd2\x2c\x00\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x86\x96\x98\xe9\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x2d\x97\x67\xc6\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x00\x00\xd3\x4f\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xa2\xd2\x2c\x00\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x31\x2b\xe9\x3e\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x2d\x02\x17\x71\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x00\x00\xd3\x4f\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xc0\xd2\x2c\x00\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x13\xab\x89\xb2\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x2d\x82\x76\xfd\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x00\x00\xd3\x4f\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x1c\xd2\x2c\x00\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xb7\xef\x2d\xf4\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x2d\x3e\xd2\xbb\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x00\x00\xd3\x4f\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x8f\xd2\x2c\x00\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x44\xfe\x4b\x37\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x2d\x2f\xb4\x78\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x00\x00\xd3\x4f\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x5a\xd2\x2c\x00\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x79\x6d\x86\xb4\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x2d\xc0\x79\xfb\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x00\x00\xd3\x4f\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xa9\xd2\x2c\x00\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x2a\x65\x8a\x78\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x2d\xc8\x75\x37\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x00\x00\xd3\x4f\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x0d\xd2\x2c\x00\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xc6\x43\xac\xfe\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x2d\xea\x53\xb1\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x00\x00\xd3\x4f\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x79\xd2\x2c\x00\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x5a\x2e\x5f\xed\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x2d\xff\xa0\xc2\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x00\x00\xd3\x4f\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x79\xd2\x2c\x00\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x5a\xfb\xdc\xc0\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x2d\x32\x23\xef\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x00\x00\xd3\x4f\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x0e\xd2\x2c\x00\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xc5\x38\xc8\x62\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x2d\xf5\x37\x4d\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x00\x00\xd3\x4f\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x54\xd2\x2c\x00\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x7f\x36\xf1\xe3\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x2d\xf7\x0e\xcc\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x00\x00\xd3\x4f\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x92\xd2\x2c\x00\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x41\x93\x24\xa8\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x2d\x9a\xdb\x07\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x00\x00\xd3\x4f\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x5e\xd2\x2c\x00\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x75\xb8\xd8\x0d\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x2d\x75\x27\xa2\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x