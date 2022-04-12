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

#ifndef Py_STRHEX_H
#define Py_STRHEX_H

#ifdef __cplusplus
extern "C" {
#endif

#ifndef Py_LIMITED_API
/* Returns a str() containing the hex representation of argbuf. */
PyAPI_FUNC(PyObject*) _Py_strhex(const char* argbuf, const Py_ssize_t arglen);
/* Returns a bytes() containing the ASCII hex representation of argbuf. */
PyAPI_FUNC(PyObject*) _Py_strhex_bytes(const char* argbuf, const Py_ssize_t arglen);
#endif /* !Py_LIMITED_API */

#ifdef __cplusplus
}
#endif

#endif /* !Py_STRHEX_H */
