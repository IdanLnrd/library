# convert csv file to json file
# input: command line args - path/to/file

import csv
import io
import json
import sys
import os

csvFile=sys.argv.pop()
valid = os.path.isfile(csvFile)

def convert():
    lines=[]
    with open(csvFile, newline='') as f:
        reader = csv.reader(f)
        cols = list(map(lambda c: c.replace(" ", "_"), reader.__next__()))
        for row in reader:
            item = dict(zip(cols[1:], row[1:len(cols)]))
            lines.append(json.dumps(item))

    outputFile = csvFile + '.json'
    jsonOutFile = io.open(outputFile, 'w', encoding="utf-8")
    output='[' + ','.join(lines) + ']'
    jsonOutFile.writelines(output)
    jsonOutFile.close()


if(valid):
    print('convert file ' + csvFile + '...')
    convert()
    print('done')
else:
    print(csvFile + ' is not valid file')