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

#ifndef Py_STRCMP_H
#define Py_STRCMP_H

#ifdef __cplusplus
extern "C" {
#endif

PyAPI_FUNC(int) PyOS_mystrnicmp(const char *, const char *, Py_ssize_t);
PyAPI_FUNC(int) PyOS_mystricmp(const char *, const char *);

#ifdef MS_WINDOWS
#define PyOS_strnicmp strnicmp
#define PyOS_stricmp stricmp
#else
#define PyOS_strnicmp PyOS_mystrnicmp
#define PyOS_stricmp PyOS_mystricmp
#endif

#ifdef __cplusplus
}
#endif

#endif /* !Py_STRCMP_H */
