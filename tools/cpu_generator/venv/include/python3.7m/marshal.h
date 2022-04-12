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


/* Interface for marshal.c */

#ifndef Py_MARSHAL_H
#define Py_MARSHAL_H
#ifdef __cplusplus
extern "C" {
#endif

#define Py_MARSHAL_VERSION 4

PyAPI_FUNC(void) PyMarshal_WriteLongToFile(long, FILE *, int);
PyAPI_FUNC(void) PyMarshal_WriteObjectToFile(PyObject *, FILE *, int);
PyAPI_FUNC(PyObject *) PyMarshal_WriteObjectToString(PyObject *, int);

#ifndef Py_LIMITED_API
PyAPI_FUNC(long) PyMarshal_ReadLongFromFile(FILE *);
PyAPI_FUNC(int) PyMarshal_ReadShortFromFile(FILE *);
PyAPI_FUNC(PyObject *) PyMarshal_ReadObjectFromFile(FILE *);
PyAPI_FUNC(PyObject *) PyMarshal_ReadLastObjectFromFile(FILE *);
#endif
PyAPI_FUNC(PyObject *) PyMarshal_ReadObjectFromString(const char *,
                                                      Py_ssize_t);

#ifdef __cplusplus
}
#endif
#endif /* !Py_MARSHAL_H */
