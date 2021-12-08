# objective : create an oscillator for different tones and export in mif
# list of tones and freqs: C4 (261.646 Hz), D4 (293.67 Hz), E4 (329.628 Hz), F4 (349.228 Hz), G4 (391.995 Hz), A4 (440 Hz), B4 (493.883 Hz)
import numpy as np

# tunable parameters
sample_time = 0.01 # total time to generate sine wave (seconds)
sample_freq = 44100 # sampling frequency (Hz)
note_dict = {'C4':261.646, 'D4':293.67, 'E4':329.628, 'F4':349.228, 'G4':391.995, 'A4':440, 'B4':493.883, 'C5':523.251}
note_freq = 261.646 # note/sine wave frequency (Hz)
sample_bit = 16 # number of sampled bits
max_value = 2**(sample_bit-1) # maximum allowed number for the bits
max_hex = 'f'*(sample_bit//4) # max bits for hex representation
# print(max_hex)
# function to create discrete sine wave samples for 1 period
def create_sine_sample(sample_bit, wave_freq, sample_freq):
    time = np.linspace(0, 1/wave_freq, int(sample_freq/wave_freq)) # sampled time
    sine_wave = np.sin(2*np.pi*wave_freq*time) # sampled sine wave
    sampled_hex = []
    for i in range(len(sine_wave)):
        data = int((max_value-1)*sine_wave[i])
        if data >= 0:
            sampled_hex.append(('0'*((sample_bit//4)-len(hex(data)[2:])) + hex(data)[2:]).upper())
        elif data == -1:
            sampled_hex.append('F'*((sample_bit//4)-1)+'E') # use FFFF for terminating each note
        else:
            sampled_hex.append(hex(int(max_hex, 16)+data+1)[2:].upper())
    return sampled_hex

# This part is for generating each note separately.
# for note in note_dict:
#     filename = 'short_' + note + '.mif'
#     hex_sample = create_sine_sample(sample_bit, note_dict[note], sample_freq, sample_time)
#     with open(filename, 'w') as f:
#         # f.write('DEPTH = '+str(len(hex_sample))+';\n')
#         f.write('DEPTH = 512;\n')
#         f.write('WIDTH = '+str(sample_bit)+';\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n')
#         i = 0
#         for data in hex_sample:
#             f.write(hex(i)[2:].upper())
#             f.write(' : ')
#             f.write(data)
#             f.write(';\n')
#             i += 1
#         f.write('['+hex(i)[2:].upper()+'..'+hex(511)[2:].upper()+'] : 0000;\n')
#         f.write('END;')
# print(sampled_hex[:100])

# This part is for generating hex samples of 1 period with 8 notes per file
# Use 256 locations for each note -- use FFFF to terminate the note
with open('octave.mif', 'w') as f:
    f.write('DEPTH = 2048;\nWIDTH = '+str(sample_bit)+';\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n')
    note_count = 0
    for note in note_dict:
        hex_count = note_count*256
        hex_sample = create_sine_sample(sample_bit, note_dict[note], sample_freq)
        for i in range(len(hex_sample)):
            f.write(hex(hex_count+i)[2:].upper())
            f.write(' : ')
            f.write(hex_sample[i]+';\n')
        f.write(hex(hex_count+len(hex_sample))[2:].upper()+' : FFFF;\n') # terminating location
        f.write('['+hex(hex_count+len(hex_sample)+1)[2:].upper()+'..'+hex(hex_count+255)[2:].upper()+'] : 0000;\n')
        note_count += 1
    f.write('END;')

