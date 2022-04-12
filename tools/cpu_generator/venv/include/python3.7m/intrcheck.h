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


#ifndef Py_INTRCHECK_H
#define Py_INTRCHECK_H
#ifdef __cplusplus
extern "C" {
#endif

PyAPI_FUNC(int) PyOS_InterruptOccurred(void);
PyAPI_FUNC(void) PyOS_InitInterrupts(void);
#ifdef HAVE_FORK
#if !defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x03070000
PyAPI_FUNC(void) PyOS_BeforeFork(void);
PyAPI_FUNC(void) PyOS_AfterFork_Parent(void);
PyAPI_FUNC(void) PyOS_AfterFork_Child(void);
#endif
#endif
/* Deprecated, please use PyOS_AfterFork_Child() instead */
PyAPI_FUNC(void) PyOS_AfterFork(void) Py_DEPRECATED(3.7);

#ifndef Py_LIMITED_API
PyAPI_FUNC(int) _PyOS_IsMainThread(void);
PyAPI_FUNC(void) _PySignal_AfterFork(void);

#ifdef MS_WINDOWS
/* windows.h is not included by Python.h so use void* instead of HANDLE */
PyAPI_FUNC(void*) _PyOS_SigintEvent(void);
#endif
#endif /* !Py_LIMITED_API */

#ifdef __cplusplus
}
#endif
#endif /* !Py_INTRCHECK_H */
