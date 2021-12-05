from os.path import dirname, join as pjoin
from scipy.io import wavfile
# import matplotlib.pyplot as plt
import numpy as np

# print(dirname(__file__))
wavname = 'sample_piano, guide.wav'
wavpath = pjoin(dirname(__file__), wavname)
samplerate, data = wavfile.read(wavpath)
print('Sample rate:', samplerate)
length = len(data)/samplerate
startsample = 1.63
endsample = 1.64

# print(data[int(startsample*samplerate):int(endsample*samplerate)])
maxvalue = 'f'*4 # 16 bits of binary = 4 bits of hexadecimal
hexdata = []
for i in data[int(startsample*samplerate):int(endsample*samplerate)]:
    if i >= 0:
        hexdata.append(('0'*(4-len(hex(i)[2:])) + hex(i)[2:]).upper())
    else:
        hexdata.append((hex(int(maxvalue, 16)-int(str(-i),16)+1)[2:]).upper())
# print(hexdata)

with open('wav.mif', 'w') as f:
    f.write('DEPTH = ')
    f.write(str(len(hexdata)))
    f.write(';\n')
    f.write('WIDTH = 16;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n')
    i = 0
    for data in hexdata:
        f.write(hex(i)[2:].upper())
        f.write(' : ')
        f.write(data)
        f.write(';\n')
        i += 1
    f.write('END;')

# x = 'f'*4
# print(hex(int(x,16)-int('2',16)+1))

# time = np.linspace(0., length, len(data))
# plt.plot(time, data)