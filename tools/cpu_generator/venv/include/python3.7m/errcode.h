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

#ifndef Py_ERRCODE_H
#define Py_ERRCODE_H
#ifdef __cplusplus
extern "C" {
#endif


/* Error codes passed around between file input, tokenizer, parser and
   interpreter.  This is necessary so we can turn them into Python
   exceptions at a higher level.  Note that some errors have a
   slightly different meaning when passed from the tokenizer to the
   parser than when passed from the parser to the interpreter; e.g.
   the parser only returns E_EOF when it hits EOF immediately, and it
   never returns E_OK. */

#define E_OK            10      /* No error */
#define E_EOF           11      /* End Of File */
#define E_INTR          12      /* Interrupted */
#define E_TOKEN         13      /* Bad token */
#define E_SYNTAX        14      /* Syntax error */
#define E_NOMEM         15      /* Ran out of memory */
#define E_DONE          16      /* Parsing complete */
#define E_ERROR         17      /* Execution error */
#define E_TABSPACE      18      /* Inconsistent mixing of tabs and spaces */
#define E_OVERFLOW      19      /* Node had too many children */
#define E_TOODEEP       20      /* Too many indentation levels */
#define E_DEDENT        21      /* No matching outer block for dedent */
#define E_DECODE        22      /* Error in decoding into Unicode */
#define E_EOFS          23      /* EOF in triple-quoted string */
#define E_EOLS          24      /* EOL in single-quoted string */
#define E_LINECONT      25      /* Unexpected characters after a line continuation */
#define E_IDENTIFIER    26      /* Invalid characters in identifier */
#define E_BADSINGLE     27      /* Ill-formed single statement input */

#ifdef __cplusplus
}
#endif
#endif /* !Py_ERRCODE_H */
