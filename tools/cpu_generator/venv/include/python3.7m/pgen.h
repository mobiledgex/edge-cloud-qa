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

#ifndef Py_PGEN_H
#define Py_PGEN_H
#ifdef __cplusplus
extern "C" {
#endif


/* Parser generator interface */

extern grammar *meta_grammar(void);

struct _node;
extern grammar *pgen(struct _node *);

#ifdef __cplusplus
}
#endif
#endif /* !Py_PGEN_H */
