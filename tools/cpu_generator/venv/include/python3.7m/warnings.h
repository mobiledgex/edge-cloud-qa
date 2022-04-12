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

#ifndef Py_WARNINGS_H
#define Py_WARNINGS_H
#ifdef __cplusplus
extern "C" {
#endif

#ifndef Py_LIMITED_API
PyAPI_FUNC(PyObject*) _PyWarnings_Init(void);
#endif

PyAPI_FUNC(int) PyErr_WarnEx(
    PyObject *category,
    const char *message,        /* UTF-8 encoded string */
    Py_ssize_t stack_level);
PyAPI_FUNC(int) PyErr_WarnFormat(
    PyObject *category,
    Py_ssize_t stack_level,
    const char *format,         /* ASCII-encoded string  */
    ...);

#if !defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x03060000
/* Emit a ResourceWarning warning */
PyAPI_FUNC(int) PyErr_ResourceWarning(
    PyObject *source,
    Py_ssize_t stack_level,
    const char *format,         /* ASCII-encoded string  */
    ...);
#endif
#ifndef Py_LIMITED_API
PyAPI_FUNC(int) PyErr_WarnExplicitObject(
    PyObject *category,
    PyObject *message,
    PyObject *filename,
    int lineno,
    PyObject *module,
    PyObject *registry);
#endif
PyAPI_FUNC(int) PyErr_WarnExplicit(
    PyObject *category,
    const char *message,        /* UTF-8 encoded string */
    const char *filename,       /* decoded from the filesystem encoding */
    int lineno,
    const char *module,         /* UTF-8 encoded string */
    PyObject *registry);

#ifndef Py_LIMITED_API
PyAPI_FUNC(int)
PyErr_WarnExplicitFormat(PyObject *category,
                         const char *filename, int lineno,
                         const char *module, PyObject *registry,
                         const char *format, ...);
#endif

/* DEPRECATED: Use PyErr_WarnEx() instead. */
#ifndef Py_LIMITED_API
#define PyErr_Warn(category, msg) PyErr_WarnEx(category, msg, 1)
#endif

#ifndef Py_LIMITED_API
void _PyErr_WarnUnawaitedCoroutine(PyObject *coro);
#endif

#ifdef __cplusplus
}
#endif
#endif /* !Py_WARNINGS_H */

