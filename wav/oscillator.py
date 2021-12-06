# objective : create an oscillator for different tones and export in mif
# list of tones and freqs: C4 (261.646 Hz), D4 (293.67 Hz), E4 (329.628 Hz), F4 (349.228 Hz), G4 (391.995 Hz), A4 (440 Hz), B4 (493.883 Hz)
import numpy as np

# tunable parameters
sample_time = 0.01 # total time to generate sine wave (seconds)
sample_freq = 44100 # sampling frequency (Hz)
note_dict = {'C4':261.646, 'D4':293.67, 'E4':329.628, 'F4':349.228, 'G4':391.995, 'A4':440, 'B4':493.883}
note_freq = 261.646 # note/sine wave frequency (Hz)
sample_bit = 16 # number of sampled bits
max_value = 2**(sample_bit-1) # maximum allowed number for the bits
max_hex = 'f'*(sample_bit//4) # max bits for hex representation
# print(max_hex)
# function to create discrete sine wave samples
def create_sine_sample(wave_freq, sample_freq, sample_time):
    time = np.linspace(0, sample_time, int(sample_time*sample_freq)) # sampled time
    sine_wave = np.sin(2*np.pi*wave_freq*time) # sampled sine wave
    sampled_wave = np.zeros(len(sine_wave))
    sampled_hex = []
    for i in range(len(sine_wave)):
        if sine_wave[i] >= 0:
            data = int((max_value-1)*sine_wave[i])
            sampled_wave[i] = data
            sampled_hex.append(('0'*(4-len(hex(data)[2:])) + hex(data)[2:]).upper())
        else:
            data = int(max_value*sine_wave[i])
            sampled_wave[i] = data
            sampled_hex.append(hex(int(max_hex, 16)+data+1)[2:].upper())
    return sampled_hex

for note in note_dict:
    filename = note + '.mif'
    hex_sample = create_sine_sample(note_dict[note], sample_freq, sample_time)
    with open(filename, 'w') as f:
        f.write('DEPTH = ')
        f.write(str(len(hex_sample)))
        f.write(';\n')
        f.write('WIDTH = 16;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n')
        i = 0
        for data in hex_sample:
            f.write(hex(i)[2:].upper())
            f.write(' : ')
            f.write(data)
            f.write(';\n')
            i += 1
        f.write('END;')
# print(sampled_hex[:100])
