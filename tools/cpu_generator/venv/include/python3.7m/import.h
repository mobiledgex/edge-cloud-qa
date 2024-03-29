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


/* Module definition and import interface */

#ifndef Py_IMPORT_H
#define Py_IMPORT_H
#ifdef __cplusplus
extern "C" {
#endif

#ifndef Py_LIMITED_API
PyAPI_FUNC(_PyInitError) _PyImportZip_Init(void);

PyMODINIT_FUNC PyInit__imp(void);
#endif /* !Py_LIMITED_API */
PyAPI_FUNC(long) PyImport_GetMagicNumber(void);
PyAPI_FUNC(const char *) PyImport_GetMagicTag(void);
PyAPI_FUNC(PyObject *) PyImport_ExecCodeModule(
    const char *name,           /* UTF-8 encoded string */
    PyObject *co
    );
PyAPI_FUNC(PyObject *) PyImport_ExecCodeModuleEx(
    const char *name,           /* UTF-8 encoded string */
    PyObject *co,
    const char *pathname        /* decoded from the filesystem encoding */
    );
PyAPI_FUNC(PyObject *) PyImport_ExecCodeModuleWithPathnames(
    const char *name,           /* UTF-8 encoded string */
    PyObject *co,
    const char *pathname,       /* decoded from the filesystem encoding */
    const char *cpathname       /* decoded from the filesystem encoding */
    );
#if !defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x03030000
PyAPI_FUNC(PyObject *) PyImport_ExecCodeModuleObject(
    PyObject *name,
    PyObject *co,
    PyObject *pathname,
    PyObject *cpathname
    );
#endif
PyAPI_FUNC(PyObject *) PyImport_GetModuleDict(void);
#if !defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x03070000
PyAPI_FUNC(PyObject *) PyImport_GetModule(PyObject *name);
#endif
#ifndef Py_LIMITED_API
PyAPI_FUNC(int) _PyImport_IsInitialized(PyInterpreterState *);
PyAPI_FUNC(PyObject *) _PyImport_GetModuleId(struct _Py_Identifier *name);
PyAPI_FUNC(PyObject *) _PyImport_AddModuleObject(PyObject *name,
                                                 PyObject *modules);
PyAPI_FUNC(int) _PyImport_SetModule(PyObject *name, PyObject *module);
PyAPI_FUNC(int) _PyImport_SetModuleString(const char *name, PyObject* module);
#endif
#if !defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x03030000
PyAPI_FUNC(PyObject *) PyImport_AddModuleObject(
    PyObject *name
    );
#endif
PyAPI_FUNC(PyObject *) PyImport_AddModule(
    const char *name            /* UTF-8 encoded string */
    );
PyAPI_FUNC(PyObject *) PyImport_ImportModule(
    const char *name            /* UTF-8 encoded string */
    );
PyAPI_FUNC(PyObject *) PyImport_ImportModuleNoBlock(
    const char *name            /* UTF-8 encoded string */
    );
PyAPI_FUNC(PyObject *) PyImport_ImportModuleLevel(
    const char *name,           /* UTF-8 encoded string */
    PyObject *globals,
    PyObject *locals,
    PyObject *fromlist,
    int level
    );
#if !defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x03050000
PyAPI_FUNC(PyObject *) PyImport_ImportModuleLevelObject(
    PyObject *name,
    PyObject *globals,
    PyObject *locals,
    PyObject *fromlist,
    int level
    );
#endif

#define PyImport_ImportModuleEx(n, g, l, f) \
    PyImport_ImportModuleLevel(n, g, l, f, 0)

PyAPI_FUNC(PyObject *) PyImport_GetImporter(PyObject *path);
PyAPI_FUNC(PyObject *) PyImport_Import(PyObject *name);
PyAPI_FUNC(PyObject *) PyImport_ReloadModule(PyObject *m);
PyAPI_FUNC(void) PyImport_Cleanup(void);
#if !defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x03030000
PyAPI_FUNC(int) PyImport_ImportFrozenModuleObject(
    PyObject *name
    );
#endif
PyAPI_FUNC(int) PyImport_ImportFrozenModule(
    const char *name            /* UTF-8 encoded string */
    );

#ifndef Py_LIMITED_API
PyAPI_FUNC(void) _PyImport_AcquireLock(void);
PyAPI_FUNC(int) _PyImport_ReleaseLock(void);

PyAPI_FUNC(void) _PyImport_ReInitLock(void);

PyAPI_FUNC(PyObject *) _PyImport_FindBuiltin(
    const char *name,            /* UTF-8 encoded string */
    PyObject *modules
    );
PyAPI_FUNC(PyObject *) _PyImport_FindExtensionObject(PyObject *, PyObject *);
PyAPI_FUNC(PyObject *) _PyImport_FindExtensionObjectEx(PyObject *, PyObject *,
                                                       PyObject *);
PyAPI_FUNC(int) _PyImport_FixupBuiltin(
    PyObject *mod,
    const char *name,            /* UTF-8 encoded string */
    PyObject *modules
    );
PyAPI_FUNC(int) _PyImport_FixupExtensionObject(PyObject*, PyObject *,
                                               PyObject *, PyObject *);

struct _inittab {
    const char *name;           /* ASCII encoded string */
    PyObject* (*initfunc)(void);
};
PyAPI_DATA(struct _inittab *) PyImport_Inittab;
PyAPI_FUNC(int) PyImport_ExtendInittab(struct _inittab *newtab);
#endif /* Py_LIMITED_API */

PyAPI_DATA(PyTypeObject) PyNullImporter_Type;

PyAPI_FUNC(int) PyImport_AppendInittab(
    const char *name,           /* ASCII encoded string */
    PyObject* (*initfunc)(void)
    );

#ifndef Py_LIMITED_API
struct _frozen {
    const char *name;                 /* ASCII encoded string */
    const unsigned char *code;
    int size;
};

/* Embedding apps may change this pointer to point to their favorite
   collection of frozen modules: */

PyAPI_DATA(const struct _frozen *) PyImport_FrozenModules;
#endif

#ifdef __cplusplus
}
#endif
#endif /* !Py_IMPORT_H */
