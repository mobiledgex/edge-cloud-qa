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

import os
import sys
import warnings

# opcode is not a virtualenv module, so we can use it to find the stdlib
# Important! To work on pypy, this must be a module that resides in the
# lib-python/modified-x.y.z directory
import opcode

dirname = os.path.dirname

distutils_path = os.path.join(os.path.dirname(opcode.__file__), "distutils")
if os.path.normpath(distutils_path) == os.path.dirname(os.path.normpath(__file__)):
    warnings.warn("The virtualenv distutils package at %s appears to be in the same location as the system distutils?")
else:
    __path__.insert(0, distutils_path)  # noqa: F821
    if sys.version_info < (3, 4):
        import imp

        real_distutils = imp.load_module("_virtualenv_distutils", None, distutils_path, ("", "", imp.PKG_DIRECTORY))
    else:
        import importlib.machinery

        distutils_path = os.path.join(distutils_path, "__init__.py")
        loader = importlib.machinery.SourceFileLoader("_virtualenv_distutils", distutils_path)
        if sys.version_info < (3, 5):
            import types

            real_distutils = types.ModuleType(loader.name)
        else:
            import importlib.util

            spec = importlib.util.spec_from_loader(loader.name, loader)
            real_distutils = importlib.util.module_from_spec(spec)
        loader.exec_module(real_distutils)

    # Copy the relevant attributes
    try:
        __revision__ = real_distutils.__revision__
    except AttributeError:
        pass
    __version__ = real_distutils.__version__

from distutils import dist, sysconfig  # isort:skip

try:
    basestring
except NameError:
    basestring = str

# patch build_ext (distutils doesn't know how to get the libs directory
# path on windows - it hardcodes the paths around the patched sys.prefix)

if sys.platform == "win32":
    from distutils.command.build_ext import build_ext as old_build_ext

    class build_ext(old_build_ext):
        def finalize_options(self):
            if self.library_dirs is None:
                self.library_dirs = []
            elif isinstance(self.library_dirs, basestring):
                self.library_dirs = self.library_dirs.split(os.pathsep)

            self.library_dirs.insert(0, os.path.join(sys.real_prefix, "Libs"))
            old_build_ext.finalize_options(self)

    from distutils.command import build_ext as build_ext_module

    build_ext_module.build_ext = build_ext

# distutils.dist patches:

old_find_config_files = dist.Distribution.find_config_files


def find_config_files(self):
    found = old_find_config_files(self)
    if os.name == "posix":
        user_filename = ".pydistutils.cfg"
    else:
        user_filename = "pydistutils.cfg"
    user_filename = os.path.join(sys.prefix, user_filename)
    if os.path.isfile(user_filename):
        for item in list(found):
            if item.endswith("pydistutils.cfg"):
                found.remove(item)
        found.append(user_filename)
    return found


dist.Distribution.find_config_files = find_config_files

# distutils.sysconfig patches:

old_get_python_inc = sysconfig.get_python_inc


def sysconfig_get_python_inc(plat_specific=0, prefix=None):
    if prefix is None:
        prefix = sys.real_prefix
    return old_get_python_inc(plat_specific, prefix)


sysconfig_get_python_inc.__doc__ = old_get_python_inc.__doc__
sysconfig.get_python_inc = sysconfig_get_python_inc

old_get_python_lib = sysconfig.get_python_lib


def sysconfig_get_python_lib(plat_specific=0, standard_lib=0, prefix=None):
    if standard_lib and prefix is None:
        prefix = sys.real_prefix
    return old_get_python_lib(plat_specific, standard_lib, prefix)


sysconfig_get_python_lib.__doc__ = old_get_python_lib.__doc__
sysconfig.get_python_lib = sysconfig_get_python_lib

old_get_config_vars = sysconfig.get_config_vars


def sysconfig_get_config_vars(*args):
    real_vars = old_get_config_vars(*args)
    if sys.platform == "win32":
        lib_dir = os.path.join(sys.real_prefix, "libs")
        if isinstance(real_vars, dict) and "LIBDIR" not in real_vars:
            real_vars["LIBDIR"] = lib_dir  # asked for all
        elif isinstance(real_vars, list) and "LIBDIR" in args:
            real_vars = real_vars + [lib_dir]  # asked for list
    return real_vars


sysconfig_get_config_vars.__doc__ = old_get_config_vars.__doc__
sysconfig.get_config_vars = sysconfig_get_config_vars
