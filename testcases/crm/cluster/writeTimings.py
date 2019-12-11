#!/usr/local/bin/python3

import datetime
import time
import sys

infile = ''
top_html = '''
<!DOCTYPE html>
<html>
<head>
<meta name='viewport' content='width=device-width, initial-scale=1'>
<style>
ul, #myUL {
  list-style-type: none;
}

#myUL {
  margin: 0;
  padding: 0;
}

.caret {
  cursor: pointer;
  -webkit-user-select: none; /* Safari 3.1+ */
  -moz-user-select: none; /* Firefox 2+ */
  -ms-user-select: none; /* IE 10+ */
  user-select: none;
}

.caret::before {
  content: '>';
  color: red;
  display: inline-block;
  margin-right: 6px;
}

.caret-down::before {
  -ms-transform: rotate(90deg); /* IE 9 */
  -webkit-transform: rotate(90deg); /* Safari */'
  transform: rotate(90deg);
  color: green;
}

.nested {
  display: none;
}

.active {
  display: block;
}
</style>
</head>
<body>
<ul id="myUL">
<li><span class="caret">Cluster Instance Timings</span><ul class="nested">
'''
bottom_html = '''     </ul>
</ul>
<script>
var toggler = document.getElementsByClassName("caret");
var i;

for (i = 0; i < toggler.length; i++) {
  toggler[i].addEventListener("click", function() {
    this.parentElement.querySelector(".nested").classList.toggle("active");
    this.classList.toggle("caret-down");
  });
}
</script>
</body>
</html>
'''

ulClose_html = '</ul></li>\n'
create_html = '<li><span class="caret">Create Times</span><ul class="nested">\n'
delete_html = '<li><span class="caret">Delete Times</span><ul class="nested">\n'
firsttest_html = ''
secondtest_html = ''
thirdtest_html = ''
fourthtest_html = ''
fifthtest_html = ''
sixthtest_html = ''
firstthreads_html = ''
secondthreads_html = ''
thirdthreads_html = ''
fourththreads_html = ''
fifththreads_html = ''
sixththreads_html = ''
firstdelete_html = ''
seconddelete_html = ''
thirddelete_html = ''
fourthdelete_html = ''
fifthdelete_html = ''
sixthdelete_html = ''
firstthread = ''
secondthreads = ''
thirdthreads = ''
fourththreads = ''
fifththreads = ''
sixththreads = ''


def get_test_threads(filename, threadnum, position):
    test_thread = ''
    i = 0
    while i < threadnum:
        with open(filename, 'r') as infile:
            infile.seek(position,0)
            line = infile.readline()
            if line.startswith('Cluster'):
                line = '<li>' + line + '</li>'
                test_thread = test_thread + line
                position = infile.tell()
                i = i + 1
            else:
                i = 15
            #print(test_thread)
    if i == 15:
        test_thread = ''
    return (position, test_thread)


tfilename = sys.argv[1]
tname = sys.argv[1]
ttype = sys.argv[1]
#print(sys.argv[1])
tname = tname.split('Cloudlet')
tname = tname[0]
tname = tname.split('automation')
tname = tname[1]
ttype = ttype.split('Timings')
#print(ttype)
ttype = ttype[1].split('-')
#print(ttype)
ttype = ttype[0]
#print(ttype)
out_html = tname + ttype + ".html"

with open(tfilename, 'r') as infile:
    timingdate = infile.readline()
    rposition = infile.tell()

tdate = float(timingdate)
tdate = (datetime.datetime.fromtimestamp(tdate).strftime('%Y-%m-%d'))
out_html = tdate + out_html
#print(out_html)
date_html = '<li><span class="caret">' + tdate + '</span><ul class="nested">\n'
name_html = '<li><span class="caret">' + tname + ' ' + ttype +'</span><ul class="nested">\n'

with open(tfilename, 'r') as infile:
    infile.seek(rposition,0)
    inLine = infile.readline()
    rposition = infile.tell()

while inLine != '' :
    if inLine[0].isdigit():
        if inLine[1].isdigit():
            ten = inLine[0] + inLine[1]
            numlines = int(ten)
        else:
            numlines = int(inLine[0])
        if numlines == 1:
            firsttest_html = '<li><span class="caret">' + inLine + '</span><ul class="nested">'
            rposition, firstthread_html = get_test_threads(tfilename, numlines, rposition)
        if numlines == 2:
            secondtest_html = '<li><span class="caret">' + inLine + '</span><ul class="nested">'
            rposition, secondthreads_html = get_test_threads(tfilename, numlines, rposition)
        if numlines == 3:
            thirdtest_html = '<li><span class="caret">' + inLine + '</span><ul class="nested">'
            rposition, thirdthreads_html = get_test_threads(tfilename, numlines, rposition)
        if numlines == 4:
            fourthtest_html = '<li><span class="caret">' + inLine + '</span><ul class="nested">'
            rposition, fourththreads_html = get_test_threads(tfilename, numlines, rposition)
        if numlines == 5:
            fifthtest_html = '<li><span class="caret">' + inLine + '</span><ul class="nested">'
            rposition, fifththreads_html = get_test_threads(tfilename, numlines, rposition)
        if numlines == 10:
            sixthtest_html = '<li><span class="caret">' + inLine + '</span><ul class="nested">'
            rposition, sixththreads_html = get_test_threads(tfilename, numlines, rposition)
            
    if inLine.startswith('Test'):
        if inLine[5].isdigit():
            if inLine[6].isdigit():
                two = inLine[5] + inLine[6]
                failedline = int(two)
            else:                
                failedline = int(inLine[5])
        if failedline == 1:
            firsttest_html = '<li>' + inLine + '</li>'
            firstdelete_html = '<li>' + inLine + '</li>'
        if failedline == 2:
            secondtest_html = '<li>' + inLine + '</li>'
            seconddelete_html = '<li>' + inLine + '</li>'
        if failedline == 3:
            thirdtest_html = '<li>' + inLine + '</li>'
            thirddelete_html = '<li>' + inLine + '</li>'
        if failedline == 4:
            fourthtest_html = '<li>' + inLine + '</li>'
            fourthdelete_html = '<li>' + inLine + '</li>'
        if failedline == 5:
            fifthtest_html = '<li>' + inLine + '</li>'
            fifthdelete_html = '<li>' + inLine + '</li>'
        if failedline == 10:
            sixthtest_html = '<li>' + inLine + '</li>'
            sixthdelete_html = '<li>' + inLine + '</li>'

    if inLine.startswith('Delete'):
        if inLine[7].isdigit():
            if inLine[8].isdigit():
                do = inLine[7] + inLine[8]
                numlines = int(do)
            else:
                numlines = int(inLine[7])
        if numlines == 1:
            firstdelete_html = '<li><span class="caret">' + inLine + '</span><ul class="nested">'
            rposition, firstthread = get_test_threads(tfilename, numlines, rposition)
        if numlines == 2:
            seconddelete_html = '<li><span class="caret">' + inLine + '</span><ul class="nested">'
            rposition, secondthreads = get_test_threads(tfilename, numlines, rposition)
        if numlines == 3:
            thirddelete_html = '<li><span class="caret">' + inLine + '</span><ul class="nested">'
            rposition, thirdthreads = get_test_threads(tfilename, numlines, rposition)
        if numlines == 4:
            fourthdelete_html = '<li><span class="caret">' + inLine + '</span><ul class="nested">'
            rposition, fourththreads = get_test_threads(tfilename, numlines, rposition)
        if numlines == 5:
            fifthdelete_html = '<li><span class="caret">' + inLine + '</span><ul class="nested">'
            rposition, fifththreads = get_test_threads(tfilename, numlines, rposition)
        if numlines == 10:
            sixthdelete_html = '<li><span class="caret">' + inLine + '</span><ul class="nested">'
            rposition, sixththreads = get_test_threads(tfilename, numlines, rposition)
   
    with open(tfilename, 'r') as infile:
        infile.seek(rposition,0)
        inLine = infile.readline()
        rposition = infile.tell()
    
    
with open(out_html, 'w') as outfile:
    outfile.write(top_html)
    outfile.write(date_html)
    outfile.write(name_html)
    outfile.write(create_html)
    outfile.write(firsttest_html)
    if not firsttest_html.startswith('<li>Test'):
        outfile.write(firstthread_html)
        outfile.write(ulClose_html)
    outfile.write(secondtest_html)
    if not secondtest_html.startswith('<li>Test'):
        outfile.write(secondthreads_html)
        outfile.write(ulClose_html)
    outfile.write(thirdtest_html)
    if not thirdtest_html.startswith('<li>Test'):
        outfile.write(thirdthreads_html)
        outfile.write(ulClose_html)
    outfile.write(fourthtest_html)
    if not fourthtest_html.startswith('<li>Test'):
        outfile.write(fourththreads_html)
        outfile.write(ulClose_html)
    outfile.write(fifthtest_html)
    if not fifthtest_html.startswith('<li>Test'):
        outfile.write(fifththreads_html)
        outfile.write(ulClose_html)
    outfile.write(sixthtest_html)
    if not sixthtest_html.startswith('<li>Test'):
        outfile.write(sixththreads_html)
        outfile.write(ulClose_html)
        
    outfile.write(ulClose_html)


    outfile.write(delete_html)
    if firsttest_html.startswith('<li>Test'):
        outfile.write(firsttest_html)
    else:
        outfile.write(firstdelete_html)
        outfile.write(firstthread)
        outfile.write(ulClose_html)
    if secondtest_html.startswith('<li>Test'):
        outfile.write(secondtest_html)
    else:
        outfile.write(seconddelete_html)
        outfile.write(secondthreads)
        outfile.write(ulClose_html)
    if thirdtest_html.startswith('<li>Test'):
        outfile.write(thirdtest_html)
    else:
        outfile.write(thirddelete_html)
        outfile.write(thirdthreads)
        outfile.write(ulClose_html)
    if fourthtest_html.startswith('<li>Test'):
        outfile.write(fourthtest_html)
    else:
        outfile.write(fourthdelete_html)
        outfile.write(fourththreads)
        outfile.write(ulClose_html)
    if fifthtest_html.startswith('<li>Test'):
        outfile.write(fifthtest_html)
    else:
        outfile.write(fifthdelete_html)
        outfile.write(fifththreads)
        outfile.write(ulClose_html)
    if sixthtest_html.startswith('<li>Test'):
        outfile.write(sixthtest_html)
    else:
        outfile.write(sixthdelete_html)
        outfile.write(sixththreads)
        outfile.write(ulClose_html)
        
    outfile.write(ulClose_html)
    outfile.write(ulClose_html)
    outfile.write(ulClose_html)
    outfile.write(bottom_html)



