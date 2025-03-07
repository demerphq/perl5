/* -*- mode: C; buffer-read-only: t -*-
   !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
   This file is built by regen/genpacksizetables.pl from its data.
   Any changes made here will be lost!
 */

#if TYPE_IS_SHRIEKING != 0x100
   ++++shriek offset should be 256
#endif

typedef U8 packprops_t;
#if 'J'-'I' == 1
/* ASCII */
STATIC const packprops_t packprops[512] = {
    /* normal */
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0,
    /* C */ sizeof(unsigned char),
#if defined(HAS_LONG_DOUBLE)
    /* D */ LONG_DOUBLESIZE,
#else
    0,
#endif
    0,
    /* F */ NVSIZE,
    0, 0,
    /* I */ sizeof(unsigned int),
    /* J */ UVSIZE,
    0,
    /* L */ SIZE32,
    0,
    /* N */ SIZE32,
    0, 0,
#if IVSIZE >= 8
    /* Q */ sizeof(Uquad_t),
#else
    0,
#endif
    0,
    /* S */ SIZE16,
    0,
    /* U */ sizeof(char) | PACK_SIZE_UNPREDICTABLE,
    /* V */ SIZE32,
    /* W */ sizeof(unsigned char) | PACK_SIZE_UNPREDICTABLE,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* c */ sizeof(char),
    /* d */ sizeof(double),
    0,
    /* f */ sizeof(float),
    0, 0,
    /* i */ sizeof(int),
    /* j */ IVSIZE,
    0,
    /* l */ SIZE32,
    0,
    /* n */ SIZE16,
    0,
    /* p */ sizeof(char *) | PACK_SIZE_CANNOT_CSUM,
#if IVSIZE >= 8
    /* q */ sizeof(Quad_t),
#else
    0,
#endif
    0,
    /* s */ SIZE16,
    0, 0,
    /* v */ SIZE16,
    /* w */ sizeof(char) | PACK_SIZE_UNPREDICTABLE | PACK_SIZE_CANNOT_CSUM,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    /* shrieking */
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* I */ sizeof(unsigned int),
    0, 0,
    /* L */ sizeof(unsigned long),
    0,
    /* N */ SIZE32,
    0, 0, 0, 0,
    /* S */ sizeof(unsigned short),
    0, 0,
    /* V */ SIZE32,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0,
    /* i */ sizeof(int),
    0, 0,
    /* l */ sizeof(long),
    0,
    /* n */ SIZE16,
    0, 0, 0, 0,
    /* s */ sizeof(short),
    0, 0,
    /* v */ SIZE16,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0
};
#else
/* EBCDIC (or bust) */
STATIC const packprops_t packprops[512] = {
    /* normal */
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0,
    /* c */ sizeof(char),
    /* d */ sizeof(double),
    0,
    /* f */ sizeof(float),
    0, 0,
    /* i */ sizeof(int),
    0, 0, 0, 0, 0, 0, 0,
    /* j */ IVSIZE,
    0,
    /* l */ SIZE32,
    0,
    /* n */ SIZE16,
    0,
    /* p */ sizeof(char *) | PACK_SIZE_CANNOT_CSUM,
#if IVSIZE >= 8
    /* q */ sizeof(Quad_t),
#else
    0,
#endif
    0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* s */ SIZE16,
    0, 0,
    /* v */ SIZE16,
    /* w */ sizeof(char) | PACK_SIZE_UNPREDICTABLE | PACK_SIZE_CANNOT_CSUM,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* C */ sizeof(unsigned char),
#if defined(HAS_LONG_DOUBLE)
    /* D */ LONG_DOUBLESIZE,
#else
    0,
#endif
    0,
    /* F */ NVSIZE,
    0, 0,
    /* I */ sizeof(unsigned int),
    0, 0, 0, 0, 0, 0, 0,
    /* J */ UVSIZE,
    0,
    /* L */ SIZE32,
    0,
    /* N */ SIZE32,
    0, 0,
#if IVSIZE >= 8
    /* Q */ sizeof(Uquad_t),
#else
    0,
#endif
    0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* S */ SIZE16,
    0,
    /* U */ sizeof(char) | PACK_SIZE_UNPREDICTABLE,
    /* V */ SIZE32,
    /* W */ sizeof(unsigned char) | PACK_SIZE_UNPREDICTABLE,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* shrieking */
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* i */ sizeof(int),
    0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* l */ sizeof(long),
    0,
    /* n */ SIZE16,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* s */ sizeof(short),
    0, 0,
    /* v */ SIZE16,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0,
    /* I */ sizeof(unsigned int),
    0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* L */ sizeof(unsigned long),
    0,
    /* N */ SIZE32,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* S */ sizeof(unsigned short),
    0, 0,
    /* V */ SIZE32,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};
#endif

/* ex: set ro ft=C: */
