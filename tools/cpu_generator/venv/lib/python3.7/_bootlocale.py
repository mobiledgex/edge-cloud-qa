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

"""A minimal subset of the locale module used at interpreter startup
(imported by the _io module), in order to reduce startup time.

Don't import directly from third-party code; use the `locale` module instead!
"""

import sys
import _locale

if sys.platform.startswith("win"):
    def getpreferredencoding(do_setlocale=True):
        if sys.flags.utf8_mode:
            return 'UTF-8'
        return _locale._getdefaultlocale()[1]
else:
    try:
        _locale.CODESET
    except AttributeError:
        if hasattr(sys, 'getandroidapilevel'):
            # On Android langinfo.h and CODESET are missing, and UTF-8 is
            # always used in mbstowcs() and wcstombs().
            def getpreferredencoding(do_setlocale=True):
                return 'UTF-8'
        else:
            def getpreferredencoding(do_setlocale=True):
                if sys.flags.utf8_mode:
                    return 'UTF-8'
                # This path for legacy systems needs the more complex
                # getdefaultlocale() function, import the full locale module.
                import locale
                return locale.getpreferredencoding(do_setlocale)
    else:
        def getpreferredencoding(do_setlocale=True):
            assert not do_setlocale
            if sys.flags.utf8_mode:
                return 'UTF-8'
            result = _locale.nl_langinfo(_locale.CODESET)
            if not result and sys.platform == 'darwin':
                # nl_langinfo can return an empty string
                # when the setting has an invalid value.
                # Default to UTF-8 in that case because
                # UTF-8 is the default charset on OSX and
                # returning nothing will crash the
                # interpreter.
                result = 'UTF-8'
            return result
