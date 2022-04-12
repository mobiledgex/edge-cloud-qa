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


/* Named tuple object interface */

#ifndef Py_STRUCTSEQ_H
#define Py_STRUCTSEQ_H
#ifdef __cplusplus
extern "C" {
#endif

typedef struct PyStructSequence_Field {
    const char *name;
    const char *doc;
} PyStructSequence_Field;

typedef struct PyStructSequence_Desc {
    const char *name;
    const char *doc;
    struct PyStructSequence_Field *fields;
    int n_in_sequence;
} PyStructSequence_Desc;

extern char* PyStructSequence_UnnamedField;

#ifndef Py_LIMITED_API
PyAPI_FUNC(void) PyStructSequence_InitType(PyTypeObject *type,
                                           PyStructSequence_Desc *desc);
PyAPI_FUNC(int) PyStructSequence_InitType2(PyTypeObject *type,
                                           PyStructSequence_Desc *desc);
#endif
PyAPI_FUNC(PyTypeObject*) PyStructSequence_NewType(PyStructSequence_Desc *desc);

PyAPI_FUNC(PyObject *) PyStructSequence_New(PyTypeObject* type);

#ifndef Py_LIMITED_API
typedef PyTupleObject PyStructSequence;

/* Macro, *only* to be used to fill in brand new objects */
#define PyStructSequence_SET_ITEM(op, i, v) PyTuple_SET_ITEM(op, i, v)

#define PyStructSequence_GET_ITEM(op, i) PyTuple_GET_ITEM(op, i)
#endif

PyAPI_FUNC(void) PyStructSequence_SetItem(PyObject*, Py_ssize_t, PyObject*);
PyAPI_FUNC(PyObject*) PyStructSequence_GetItem(PyObject*, Py_ssize_t);

#ifdef __cplusplus
}
#endif
#endif /* !Py_STRUCTSEQ_H */
