import itertools
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("password", help="Filename where permutations will be saved!!")
args = parser.parse_args()
f = open(args.password, "w")

saved = []

print "Press Ctrl + C to end!!\n"
while True:
	try:
                        passes = raw_input(">")
	      saved.append(passes)
	except KeyboardInterrupt:
		break

for i in range(1,20): #you can change the range to vary the minimum and maximum combinations
	res = itertools.permutations(saved, i)
	for j in res:
		f.write(''.join(j) + "\n")


f.close()

raw_input("Press any key to exit....")
