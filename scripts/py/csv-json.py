import csv
import io
import json
import sys
import os

def convert(csvFile):
    lines=[]
    with open(csvFile, newline='') as f:
        reader = csv.reader(f)
        cols = reader.__next__()
        for row in reader:
            item = dict(zip(cols[1:], row[1:len(cols)]))
            lines.append(json.dumps(item))

    filename = os.path.splitext(csvFile)[0]
    outputFile =  filename + '.json'
    jsonOutFile = io.open(outputFile, 'w', encoding="utf-8")
    output='[' + ','.join(lines) + ']'
    jsonOutFile.writelines(output)
    jsonOutFile.close()


csvFile = sys.argv.pop()
valid = os.path.isfile(csvFile)

if(valid):
    print('convert file ' + csvFile + '...')
    convert(csvFile)
    print('done')
else:
    print(csvFile + ' is not valid file')