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


#ifndef Py_BITSET_H
#define Py_BITSET_H
#ifdef __cplusplus
extern "C" {
#endif

/* Bitset interface */

#define BYTE            char

typedef BYTE *bitset;

bitset newbitset(int nbits);
void delbitset(bitset bs);
#define testbit(ss, ibit) (((ss)[BIT2BYTE(ibit)] & BIT2MASK(ibit)) != 0)
int addbit(bitset bs, int ibit); /* Returns 0 if already set */
int samebitset(bitset bs1, bitset bs2, int nbits);
void mergebitset(bitset bs1, bitset bs2, int nbits);

#define BITSPERBYTE     (8*sizeof(BYTE))
#define NBYTES(nbits)   (((nbits) + BITSPERBYTE - 1) / BITSPERBYTE)

#define BIT2BYTE(ibit)  ((ibit) / BITSPERBYTE)
#define BIT2SHIFT(ibit) ((ibit) % BITSPERBYTE)
#define BIT2MASK(ibit)  (1 << BIT2SHIFT(ibit))
#define BYTE2BIT(ibyte) ((ibyte) * BITSPERBYTE)

#ifdef __cplusplus
}
#endif
#endif /* !Py_BITSET_H */
