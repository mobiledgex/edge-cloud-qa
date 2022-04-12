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


/* Grammar interface */

#ifndef Py_GRAMMAR_H
#define Py_GRAMMAR_H
#ifdef __cplusplus
extern "C" {
#endif

#include "bitset.h" /* Sigh... */

/* A label of an arc */

typedef struct {
    int          lb_type;
    char        *lb_str;
} label;

#define EMPTY 0         /* Label number 0 is by definition the empty label */

/* A list of labels */

typedef struct {
    int          ll_nlabels;
    label       *ll_label;
} labellist;

/* An arc from one state to another */

typedef struct {
    short       a_lbl;          /* Label of this arc */
    short       a_arrow;        /* State where this arc goes to */
} arc;

/* A state in a DFA */

typedef struct {
    int          s_narcs;
    arc         *s_arc;         /* Array of arcs */

    /* Optional accelerators */
    int          s_lower;       /* Lowest label index */
    int          s_upper;       /* Highest label index */
    int         *s_accel;       /* Accelerator */
    int          s_accept;      /* Nonzero for accepting state */
} state;

/* A DFA */

typedef struct {
    int          d_type;        /* Non-terminal this represents */
    char        *d_name;        /* For printing */
    int          d_initial;     /* Initial state */
    int          d_nstates;
    state       *d_state;       /* Array of states */
    bitset       d_first;
} dfa;

/* A grammar */

typedef struct {
    int          g_ndfas;
    dfa         *g_dfa;         /* Array of DFAs */
    labellist    g_ll;
    int          g_start;       /* Start symbol of the grammar */
    int          g_accel;       /* Set if accelerators present */
} grammar;

/* FUNCTIONS */

grammar *newgrammar(int start);
void freegrammar(grammar *g);
dfa *adddfa(grammar *g, int type, const char *name);
int addstate(dfa *d);
void addarc(dfa *d, int from, int to, int lbl);
dfa *PyGrammar_FindDFA(grammar *g, int type);

int addlabel(labellist *ll, int type, const char *str);
int findlabel(labellist *ll, int type, const char *str);
const char *PyGrammar_LabelRepr(label *lb);
void translatelabels(grammar *g);

void addfirstsets(grammar *g);

void PyGrammar_AddAccelerators(grammar *g);
void PyGrammar_RemoveAccelerators(grammar *);

void printgrammar(grammar *g, FILE *fp);
void printnonterminals(grammar *g, FILE *fp);

#ifdef __cplusplus
}
#endif
#endif /* !Py_GRAMMAR_H */
