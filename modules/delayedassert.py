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

import inspect
import os.path

_failed_expectations = []

def expect(expr, msg = None):
    #print(str(expr))
    #if '==' in str(expr):
    #    print('splitting')
    #    (got, expected) = expr.split('==')
    #    msg = msg + ' expected=' + str(v2) + ' got=' + str(v1)
    if not expr:
        _log_failure(msg)

def expect_equal(v1, v2, msg = ''):
    if v1 != v2:
        msg = msg + ' expected=' + str(v2) + ' got=' + str(v1)
        _log_failure(msg)

def assert_expectations():
    if _failed_expectations:
        assert False, _report_failures()

def _log_failure(msg = None):
    (filename, line, funcname, contextlist) = inspect.stack()[2][1:5]
    filename = os.path.basename(filename)
    context = contextlist[0]
    _failed_expectations.append('file "%s", line %s, in %s()%s\n%s' % (filename, line, funcname, (('\n%s' % msg) if msg else ''), context))

def _report_failures():
    global _failed_expectations
    if _failed_expectations:
        (filename, line, funcname) = inspect.stack()[2][1:4]
        report = [
            '\n\nassert_expectations() called from',
            '""%s" line %s, in %s()\n' % (os.path.basename(filename), line, funcname),
            'Failed Expectations:%s\n' % len(_failed_expectations)]
        for i, failure in enumerate(_failed_expectations, start=1):
            report.append('%d: %s' % (i, failure))
        _failed_expectations = []
    return('\n'.join(report))
