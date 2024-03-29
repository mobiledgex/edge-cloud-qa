/*
 * Copyright 2022 MobiledgeX, Inc
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* Static DTrace probes interface */

#ifndef Py_DTRACE_H
#define Py_DTRACE_H
#ifdef __cplusplus
extern "C" {
#endif

#ifdef WITH_DTRACE

#include "pydtrace_probes.h"

/* pydtrace_probes.h, on systems with DTrace, is auto-generated to include
   `PyDTrace_{PROBE}` and `PyDTrace_{PROBE}_ENABLED()` macros for every probe
   defined in pydtrace_provider.d.

   Calling these functions must be guarded by a `PyDTrace_{PROBE}_ENABLED()`
   check to minimize performance impact when probing is off. For example:

       if (PyDTrace_FUNCTION_ENTRY_ENABLED())
           PyDTrace_FUNCTION_ENTRY(f);
*/

#else

/* Without DTrace, compile to nothing. */

static inline void PyDTrace_LINE(const char *arg0, const char *arg1, int arg2) {}
static inline void PyDTrace_FUNCTION_ENTRY(const char *arg0, const char *arg1, int arg2)  {}
static inline void PyDTrace_FUNCTION_RETURN(const char *arg0, const char *arg1, int arg2) {}
static inline void PyDTrace_GC_START(int arg0) {}
static inline void PyDTrace_GC_DONE(Py_ssize_t arg0) {}
static inline void PyDTrace_INSTANCE_NEW_START(int arg0) {}
static inline void PyDTrace_INSTANCE_NEW_DONE(int arg0) {}
static inline void PyDTrace_INSTANCE_DELETE_START(int arg0) {}
static inline void PyDTrace_INSTANCE_DELETE_DONE(int arg0) {}
static inline void PyDTrace_IMPORT_FIND_LOAD_START(const char *arg0) {}
static inline void PyDTrace_IMPORT_FIND_LOAD_DONE(const char *arg0, int arg1) {}

static inline int PyDTrace_LINE_ENABLED(void) { return 0; }
static inline int PyDTrace_FUNCTION_ENTRY_ENABLED(void) { return 0; }
static inline int PyDTrace_FUNCTION_RETURN_ENABLED(void) { return 0; }
static inline int PyDTrace_GC_START_ENABLED(void) { return 0; }
static inline int PyDTrace_GC_DONE_ENABLED(void) { return 0; }
static inline int PyDTrace_INSTANCE_NEW_START_ENABLED(void) { return 0; }
static inline int PyDTrace_INSTANCE_NEW_DONE_ENABLED(void) { return 0; }
static inline int PyDTrace_INSTANCE_DELETE_START_ENABLED(void) { return 0; }
static inline int PyDTrace_INSTANCE_DELETE_DONE_ENABLED(void) { return 0; }
static inline int PyDTrace_IMPORT_FIND_LOAD_START_ENABLED(void) { return 0; }
static inline int PyDTrace_IMPORT_FIND_LOAD_DONE_ENABLED(void) { return 0; }

#endif /* !WITH_DTRACE */

#ifdef __cplusplus
}
#endif
#endif /* !Py_DTRACE_H */
