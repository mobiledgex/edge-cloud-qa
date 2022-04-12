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

#ifndef Py_INTERNAL_WARNINGS_H
#define Py_INTERNAL_WARNINGS_H
#ifdef __cplusplus
extern "C" {
#endif

#include "object.h"

struct _warnings_runtime_state {
    /* Both 'filters' and 'onceregistry' can be set in warnings.py;
       get_warnings_attr() will reset these variables accordingly. */
    PyObject *filters;  /* List */
    PyObject *once_registry;  /* Dict */
    PyObject *default_action; /* String */
    long filters_version;
};

#ifdef __cplusplus
}
#endif
#endif /* !Py_INTERNAL_WARNINGS_H */
