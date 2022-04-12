#!/usr/local/bin/python3
# Copyright 2022 MobiledgeX, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


import datetime
import time
import sys

tempfile = 'tempdeletethreads.txt'

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
bottom_html = '''     </ul></li></ul></li></ul></li></ul></ul>
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
create_html = '<li><span class="caret">Create Times</span><ul class="nested">\n'
delete_html = '<li><span class="caret">Delete Times</span><ul class="nested">\n'


tfilename = sys.argv[1]
tname = sys.argv[1]
ttype = sys.argv[1]

with open(tfilename, 'r') as infile:
    timingdate = infile.readline()

tname = tname.split('Cloudlet')
tname = tname[0]
tname = tname.split('automation')
tname = tname[1]
ttype = ttype.split('Timings')
ttype = ttype[len(ttype)-1].split('-')
ttype = ttype[0]
out_html = tname + ttype + ".html"
tdate = float(timingdate)
tdate = (datetime.datetime.fromtimestamp(tdate).strftime('%Y-%m-%d'))
out_html = tdate + out_html
date_html = '<li><span class="caret">' + tdate + '</span><ul class="nested">\n'
name_html = '<li><span class="caret">' + tname + ' ' + ttype +'</span><ul class="nested">\n'

with open(out_html, 'w') as outfile:
    outfile.write('')

with open(tempfile, 'w') as outfile:
    outfile.write('')

with open(out_html, 'a') as outfile:
    outfile.write(top_html)
    outfile.write(date_html)
    outfile.write(name_html)
    outfile.write(create_html)

with open(tempfile, 'a') as outfile:
    outfile.write(delete_html)
   
      
with open(tfilename, 'r') as infile:
    inline = infile.readline()
    while(inline != ''):
        if(inline.find(timingdate) != -1):
            inline = infile.readline()
        if((inline.find('Openstack') != -1) and (inline.find('Delete') == -1)):
            x = inline[0:2]
            x = x.strip()
            x = int(x)
            inline = inline.rstrip()
            with open(out_html, 'a') as outfile:
                outfile.write('<li><span class="caret">' + inline + '</span><ul class="nested">\n')
            for i in range(x):
                inline = infile.readline()
                inline = inline.rstrip()
                with open(out_html, 'a') as outfile:
                    outfile.write('<li>' + inline + '</li>\n')
            with open(out_html, 'a') as outfile:
                outfile.write('</ul></li>\n')

        inline = infile.readline()
        if((inline.find('Openstack') != -1) and (inline.find('Delete') != -1)):
            x = inline[7:9]
            x = x.strip()
            x = int(x)
            inline = inline.rstrip()
            with open(tempfile, 'a') as outfile:
                outfile.write('<li><span class="caret">' + inline + '</span><ul class="nested">\n')
            for i in range(x):
                inline = infile.readline()
                inline = inline.rstrip()
                with open(tempfile, 'a') as outfile:
                    outfile.write('<li>' + inline + '</li>\n')
            with open(tempfile, 'a') as outfile:    
                outfile.write('</ul></li>\n')
                
    inline = infile.readline()     
with open(out_html, 'a') as outfile:
    outfile.write('</ul></li>\n')

with open(tempfile, 'r') as infile:
    for line in infile:
        with open(out_html, 'a') as outfile:
            outfile.write(line)
with open(out_html, 'a') as outfile:
    outfile.write(bottom_html)

with open(tempfile, 'w') as outfile:
    outfile.write('')


    
