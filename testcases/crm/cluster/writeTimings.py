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
  <li><span class="caret">App Instance Timings</span>
    <ul class="nested">    
    </ul>
  </li>
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
whileflag = True

def get_test_head(filename, position):
    with open(filename, 'r') as infile:
        infile.seek(position,0)
        test_head = infile.readline()
        position = infile.tell()
    return (position, test_head)


def get_numlines(test_text):
    #print("getNumlines: " + test_text)
    if not test_text.startswith('Cluster'):
        numlines = test_text.split('Openstack')
        numlines = numlines[0]
        numlines = int(numlines)
        #print ('returned number: ' + str(numlines))
    else:
        numlines = 11
    return numlines


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
tname = tname.split('Cloudlet')
tname = tname[0]
tname = tname.split('automation')
tname = tname[1]
ttype = ttype.split('Timings')
#print(ttype)
ttype = ttype[1].split('-')
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

rposition, firsttest = get_test_head(tfilename, rposition)
#print('1 Test Head:' + firsttest)
if not firsttest.startswith('Test'):
    firsttest_html = '<li><span class="caret">' + firsttest + '</span><ul class="nested">'
    numlines = get_numlines(firsttest)
    rposition, firstthreads_html = get_test_threads(tfilename, numlines, rposition)
    rposition, firstdelete = get_test_head(tfilename, rposition)
    firstdelete_html = '<li><span class="caret">' + firstdelete + '</span><ul class="nested">'
    rposition, firstthreads = get_test_threads(tfilename, numlines, rposition)
else:
    firsttest_html = '<li>' + firsttest + '</li>'
    
rposition, secondtest = get_test_head(tfilename, rposition)
#print('2 Test Head:' + secondtest)
if not secondtest.startswith('Test'):
    secondtest_html = '<li><span class="caret">' + secondtest + '</span><ul class="nested">'
    numlines = get_numlines(secondtest)
    rposition, secondthreads_html = get_test_threads(tfilename, numlines, rposition)
    rposition, seconddelete = get_test_head(tfilename, rposition)
    seconddelete_html = '<li><span class="caret">' + seconddelete + '</span><ul class="nested">'
    rposition, secondthreads = get_test_threads(tfilename, numlines, rposition)
else:
    secondtest_html = '<li>' + secondtest + '</li>'
    
rposition, thirdtest = get_test_head(tfilename, rposition)
#print('3 Test Head:' + thirdtest)
if not thirdtest.startswith('Test'):
    thirdtest_html = '<li><span class="caret">' + thirdtest + '</span><ul class="nested">'
    #print(thirdtest)
    numlines = get_numlines(thirdtest)
    rposition, thirdthreads_html = get_test_threads(tfilename, numlines, rposition)
    rposition, thirddelete = get_test_head(tfilename, rposition)
    thirddelete_html = '<li><span class="caret">' + thirddelete + '</span><ul class="nested">'
    rposition, thirdthreads = get_test_threads(tfilename, numlines, rposition)
else:
    thirdtest_html = '<li>' + thirdtest + '</li>'
    
rposition, fourthtest = get_test_head(tfilename, rposition)
if not fourthtest.startswith('Test'):
    fourthtest_html = '<li><span class="caret">' + fourthtest + '</span><ul class="nested">'
    numlines = get_numlines(fourthtest)
    rposition, fourththreads_html = get_test_threads(tfilename, numlines, rposition)
    rposition, fourthdelete = get_test_head(tfilename, rposition)
    fourthdelete_html = '<li><span class="caret">' + fourthdelete + '</span><ul class="nested">'
    rposition, fourththreads = get_test_threads(tfilename, numlines, rposition)
else:
    fourthtest_html = '<li>' + fourthtest + '</li>'
    
rposition, fifthtest = get_test_head(tfilename, rposition)
if not fifthtest.startswith('Test'):
    fifthtest_html = '<li><span class="caret">' + fifthtest + '</span><ul class="nested">'
    numlines = get_numlines(fifthtest)
    rposition, fifththreads_html = get_test_threads(tfilename, numlines, rposition)
    rposition, fifthdelete = get_test_head(tfilename, rposition)
    fifthdelete_html = '<li><span class="caret">' + fifthdelete + '</span><ul class="nested">'
    rposition, fifththreads = get_test_threads(tfilename, numlines, rposition)
else:
    fifthtest_html = '<li>' + fifthtest + '</li>'
    
rposition, sixthtest = get_test_head(tfilename, rposition)
if not sixthtest.startswith('Test'):
    sixthtest_html = '<li><span class="caret">' + sixthtest + '</span><ul class="nested">'
    numlines = get_numlines(sixthtest)
    rposition, sixththreads_html = get_test_threads(tfilename, numlines, rposition)
    rposition, sixthdelete = get_test_head(tfilename, rposition)
    sixthdelete_html = '<li><span class="caret">' + sixthdelete + '</span><ul class="nested">'
    rposition, sixththreads = get_test_threads(tfilename, numlines, rposition)
else:
    sixthtest_html = '<li>' + sixthtest + '</li>'
    
    
with open(out_html, 'w') as outfile:
    outfile.write(top_html)
    outfile.write(date_html)
    outfile.write(name_html)
    outfile.write(create_html)
    outfile.write(firsttest_html)
    if not firsttest.startswith('Test'):
        outfile.write(firstthreads_html)
        outfile.write(ulClose_html)
    outfile.write(secondtest_html)
    if not secondtest.startswith('Test'):
        outfile.write(secondthreads_html)
        outfile.write(ulClose_html)
    outfile.write(thirdtest_html)
    if not thirdtest.startswith('Test'):
        outfile.write(thirdthreads_html)
        outfile.write(ulClose_html)
    outfile.write(fourthtest_html)
    if not fourthtest.startswith('Test'):
        outfile.write(fourththreads_html)
        outfile.write(ulClose_html)
    outfile.write(fifthtest_html)
    if not fifthtest.startswith('Test'):
        outfile.write(fifththreads_html)
        outfile.write(ulClose_html)
    outfile.write(sixthtest_html)
    if not sixthtest.startswith('Test'):
        outfile.write(sixththreads_html)
        outfile.write(ulClose_html)
        
    outfile.write(ulClose_html)


    outfile.write(delete_html)
    if firsttest.startswith('Test'):
        outfile.write(firsttest_html)
    else:
        outfile.write(firstdelete_html)
        outfile.write(firstthreads)
        outfile.write(ulClose_html)
    if secondtest.startswith('Test'):
        outfile.write(secondtest_html)
    else:
        outfile.write(seconddelete_html)
        outfile.write(secondthreads)
        outfile.write(ulClose_html)
    if thirdtest.startswith('Test'):
        outfile.write(thirdtest_html)
    else:
        outfile.write(thirddelete_html)
        outfile.write(thirdthreads)
        outfile.write(ulClose_html)
    if fourthtest.startswith('Test'):
        outfile.write(fourthtest_html)
    else:
        outfile.write(fourthdelete_html)
        outfile.write(fourththreads)
        outfile.write(ulClose_html)
    if fifthtest.startswith('Test'):
        outfile.write(fifthtest_html)
    else:
        outfile.write(fifthdelete_html)
        outfile.write(fifththreads)
        outfile.write(ulClose_html)
    if sixthtest.startswith('Test'):
        outfile.write(sixthtest_html)
    else:
        outfile.write(sixthdelete_html)
        outfile.write(sixththreads)
        outfile.write(ulClose_html)
        
    outfile.write(ulClose_html)
    outfile.write(ulClose_html)
    outfile.write(ulClose_html)
    outfile.write(bottom_html)



