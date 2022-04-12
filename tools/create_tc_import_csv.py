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


# copy needed proto files into 1 directory
# I originally tried building these from the original path but ran into problems

import os
import glob
import pathlib
import re
import sys
import argparse
from robot.api import TestData

parser = argparse.ArgumentParser(description='create jira import file')
#parser.add_argument('--version_from_load', action='store_true')
parser.add_argument('--result', default='Automated test passes', help='what to put in result field of test step. default is \'Automated test passes\'')
parser.add_argument('--components',required=True, help='comma seperated list of components. example: Automated,Controller,Operator')
parser.add_argument('--versions',required=True, help='comma seperated list of versions. example: Nimbus')
parser.add_argument('--outfile',required=False, default='tc_import.csv', help='csv outfile to write to. default is tc_import.csv')
parser.add_argument('--filepattern',required=False, default='test_*.py', help='file match pattern for testcase parsing. default is test_*.py')

args = parser.parse_args()

#outfile = 'tc_import.csv'
#result = 'Automated test passes'
#components = 'Automated,Controller,Flavor'
#versions = 'Nimbus'

outfile = args.outfile
result = args.result
components = args.components
versions = args.versions
tcfile = args.filepattern

#tcfile = 'test_*.py'
#if len(sys.argv) == 2:
#    tcfile = sys.argv[1]

def get_file_list():
    file_list = []
    l = glob.glob(tcfile)
    #print(l)
    for f in l:
        ff = pathlib.Path(f).resolve()
        file_list.append(str(ff))

    file_list.sort()
    return file_list

def get_tc_name(l):
    tc_hash = {}
    
    tc_list = []
    #l = os.listdir('.')
    #print(l)
    #l = os.walk('.')
    #print(l)
    #l = glob.glob('test_*.py')
    #print(l)
    for f in l:
        #ff = pathlib.Path(f).resolve()
        print(f)
        #dl = str(ff).split('/testcases/')[1].split('/')
        dl = f.split('/testcases/')[1].split('/')
        #print(dl)
        #tc = ''
        #for d in dl:
        #    if '.py' in d:
        #        d = d.split('.py')[0] + '.tc'
        #    tc += d + '.'
        #print(tc)
        #match1 = 'def test_.+'
        #match2 = '#\s+\[Documentation].*'
        #match3 = '#\s+\.\.\..+'
        with open(f, 'r') as tcf:
            print('fffff',f)
            if f.endswith('.robot'):
                suite = TestData(source=f)
                for test in suite.testcase_table:
                    print('-', test.name)
                    print(test.doc)
                    s = str(test.doc)
                    print('sss',s)
                    comments = s.split('\\n')
                    print(comments[0])
                    desc = ''
                    #for line in comments[1:]:
                    for line in comments:
                        desc += line + '\n'
                    desc = desc.rstrip()

                    #tc_hash['"' + dl[-1] + '\n' + test.name + '"'] = {'title': '"' + comments[0] + '"', 'desc': desc}
                    tc_hash['"' + dl[-1] + '\n' + test.name + '"'] = {'title': '"' + test.name + '"', 'desc': desc}
                    print(tc_hash)
                print(suite)
                #sys.exit(1)
            elif f.endswith('.py'):
                dl = f.split('/testcases/')[1].split('/')
                print(dl)
                tc = ''
                for d in dl:
                    if '.py' in d:
                        d = d.split('.py')[0] + '.tc'
                    tc += d + '.'
                #print(tc)
                match1 = 'def test_.+'
                match2 = '#\s+\[Documentation].*'
                match3 = '#\s+\.\.\..+'

                t = tcf.read()
                d = re.compile('({}|{}|{})'.format(match1, match2, match3)).findall(t)
                print('d',d)
                sys.exit(1)
                description = ''
                title = ''
                current_tc = ''
                for line in d:
                    print('l',line)
                    if 'def test' in line:
                        test = line[4:].split('(')[0]
                        tc_hash[tc+test] = {'title':'', 'desc':''}
                        description = ''
                        current_tc = tc+test
                        #print(current_tc)
                    elif '[Documentation]' in line:
                        tc_hash[current_tc]['title'] = '"' + line.split('[Documentation]')[1].strip() + '"'
                        print('title',tc_hash[current_tc]['title'])
                    else:
                        description += line.split('...')[1].strip() + '\n'
                        tc_hash[current_tc]['desc'] = description
            else:
                print('only support python(unittest format) and robot')
                #print(d)
                #print('title',title,'desc',description)
                #tc_hash[tc + test] = {'title': title, 'desc': description}
            
            #m = re.findall('def test_.+', t)
            #for t2 in m:
            #    test = t2[4:].split('(')[0]
            #    print('t',test)
            #    tc_list.append(tc + test)
            #    #d = re.findall('#\s+\[Documentation].* | #\s+\.\.\..+', t)
            #    #print(d)
            #    #sys.exit(1)
            #    #d = re.findall('(#\s+\[Documentation].*) | (#\s+\.\.\..+)', t, re.DEBUG)
            #    d = re.compile('({}|{})'.format(match1, match2)).findall(t)
            #    print(d)
            #    description = ''
            #    title = ''
            #    for line in d:
            #        #print('l',line)
            #        if '[Documentation]' in line:
            #            title = line.split('[Documentation]')[1].strip()
            #            #print('title',title)
            #        else:
            #            description += line.split('...')[1].strip() + '\n'
            #        #print(d)
            #    #print('title',title,'desc',description)
            #    tc_hash[tc + test] = {'title': title, 'desc': description}
            #    #tc_hash['title'] = title
            #    #tc_hash['desc'] = description
            #    #tc_list.append(tc_hash)
    return tc_hash

file_list = get_file_list()
tc_list = get_tc_name(file_list)


external_id = ''
test_data = ''
with open(outfile,'w') as f:
    f.write('Name,STEPS,Result,Testdata,ExternalId,Versions,Components,Description\n')
    for t in tc_list:
        print(t)
        print(t, tc_list[t]['title'], tc_list[t]['desc'])
        f.write('{},{},{},{},{},"{}","{}","{}"\n'.format(tc_list[t]['title'], t, result, test_data, external_id, versions, components, tc_list[t]['desc']))
