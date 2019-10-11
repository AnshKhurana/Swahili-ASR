import sys

def convertIdToPhones(m_align, phonesFile):
	phoneLabeling = {}
	with open(phonesFile, 'r') as pf:
		for line in pf:
			phone, pid = line.split()
			phoneLabeling[pid] = phone

	m_align_cols = []
	edited_lines = []
	with open(m_align, 'r') as mf:
		for line in mf:
			cols = line.split()
			cols[4] = phoneLabeling[cols[4]]
			edited_lines.append(' '.join(cols))

	print('\n'.join(edited_lines))
	
if __name__ == '__main__':
	if len(sys.argv) != 3:
		print("usage: python3 id2phone.py path/to/merged_alignments path/to/phones.txt")
		exit(0)
	convertIdToPhones(sys.argv[1], sys.argv[2])
