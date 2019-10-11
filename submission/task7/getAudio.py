import sys
import os
import subprocess

def foo(word, merged_file, lexicon, audioFolder):
	pron = []
	with open(lexicon, 'r') as f:
		for line in f:
			splitLine = line.split()
			if (word == splitLine[0]):
				pron = splitLine[1:]
				break
	files = {}
	phonelist = {}
	with open(merged_file, 'r') as f:
		for line in f:
			utt_id, channel, start_time, dur, phone = line.split()
			if utt_id not in files:
				files[utt_id] = []
				phonelist[utt_id] = []
			files[utt_id].append([float(start_time), float(dur)])
			phonelist[utt_id].append(phone)

	audioMeta = []
	# print("Pronounciation:", pron)

	# Formatting pron with BEIS
	if len(pron) == 1:
		pron[0] += "_S"
	elif len(pron) > 1:
		pron[0] += "_B"
		for i in range(1, len(pron)-1):
			pron[i] += "_I"
		pron[-1] += "_E"
	else:
		print("getAudio.py: Word not found, exiting!")
		exit(-1)

	for filename in files:
		for i in range(len(phonelist[filename]) - len(pron)):
			if phonelist[filename][i] == pron[0] and phonelist[filename][i:i+len(pron)] == pron:
				# print("Found!")
				# print("Current pron:", ' '.join(phonelist[filename][i:i+len(pron)]))
				start_time = files[filename][i][0]
				# print("Start Time:", start_time)
				duration = files[filename][i+len(pron)-1][0] + files[filename][i+len(pron)-1][1] - start_time
				audioMeta.append((filename, str(start_time), str(duration)))

	print("Found ", str(len(audioMeta)), "occurences!")
	for i, audio in enumerate(audioMeta):
		cmd = ['sox', os.path.join(audioFolder, audio[0].split('_')[0], audio[0] + '.wav'), 'word' + str(i+1) + '.wav', 'trim', audio[1], audio[2]]
		# print("Command:", cmd)
		subprocess.call(cmd)



if __name__ == '__main__':
	if len(sys.argv) != 5:
		print("usage: python3 getAudio.py <word> path/to/final_ali path/to/lexicon.txt path/to/wav_folder")
		exit(0)
	foo(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])