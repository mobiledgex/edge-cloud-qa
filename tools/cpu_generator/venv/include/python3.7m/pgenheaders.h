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

#ifndef Py_PGENHEADERS_H
#define Py_PGENHEADERS_H
#ifdef __cplusplus
extern "C" {
#endif


/* Include files and extern declarations used by most of the parser. */

#include "Python.h"

PyAPI_FUNC(void) PySys_WriteStdout(const char *format, ...)
                        Py_GCC_ATTRIBUTE((format(printf, 1, 2)));
PyAPI_FUNC(void) PySys_WriteStderr(const char *format, ...)
                        Py_GCC_ATTRIBUTE((format(printf, 1, 2)));

#define addarc _Py_addarc
#define addbit _Py_addbit
#define adddfa _Py_adddfa
#define addfirstsets _Py_addfirstsets
#define addlabel _Py_addlabel
#define addstate _Py_addstate
#define delbitset _Py_delbitset
#define dumptree _Py_dumptree
#define findlabel _Py_findlabel
#define freegrammar _Py_freegrammar
#define mergebitset _Py_mergebitset
#define meta_grammar _Py_meta_grammar
#define newbitset _Py_newbitset
#define newgrammar _Py_newgrammar
#define pgen _Py_pgen
#define printgrammar _Py_printgrammar
#define printnonterminals _Py_printnonterminals
#define printtree _Py_printtree
#define samebitset _Py_samebitset
#define showtree _Py_showtree
#define tok_dump _Py_tok_dump
#define translatelabels _Py_translatelabels

#ifdef __cplusplus
}
#endif
#endif /* !Py_PGENHEADERS_H */
