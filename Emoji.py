from emoji import UNICODE_EMOJI
import sys

if(len(sys.argv)<2):
    raise Exception("Pass the file you want to convert as an input: python3 Emoji.py code.txt")

def is_emoji(s):
    return s in UNICODE_EMOJI

try:
    with open(sys.argv[1], "r") as code_in:
        with open("out.ji", "w") as code_out:
            code_out.write("U+1F30C int printf(char U+00A9 *format, ...);")
            data = code_in.read() 
            for i in data:
                if(is_emoji(i)):
                    if(ord(i) == 128424):
                        code_out.write("printf")
                    elif(ord(i) == 128290):
                        code_out.write("int")
                    else:
                        code_out.write('U+{:X}'.format(ord(i)))
                else:
                    code_out.write(i)
except:
    raise Exception("Error opening code file")
            