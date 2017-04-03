#ifdef __cplusplus
extern "C" {
#endif
#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

#define NEED_newCONSTSUB
#include "ppport.h"
#include "zstd.h"

struct Compressor {
  ZSTD_CCtx* cctx;
  ZSTD_CDict* dict;
};

typedef struct Compressor   *Compress__Zstd__Compressor;

MODULE = Compress::Zstd::Compressor  PACKAGE = Compress::Zstd::Compressor

PROTOTYPES: DISABLE

Compress::Zstd::Compressor
new(SV* class)
CODE:
  PERL_UNUSED_VAR(class);
  Newxz(RETVAL, 1, struct Compressor);
  RETVAL->cctx = ZSTD_createCCtx();
OUTPUT:
  RETVAL

void
DESTROY(Compress::Zstd::Compressor self)
CODE:
  if (self->dict)
    ZSTD_freeCDict(self->dict);
  ZSTD_freeCCtx(self->cctx);

void
set_dictionary(Compress::Zstd::Compressor self, SV* dictionary, int level = 1)
PREINIT:
  const char* dict;
  STRLEN dict_len;
CODE:
  if (!SvOK(dictionary)) {
    XSRETURN_UNDEF;
  }
  dict = SvPVbyte(dictionary, dict_len);
  self->dict = ZSTD_createCDict(dict, dict_len, level);

SV*
compress(Compress::Zstd::Compressor self, SV* source, int level = 1)
PREINIT:
  const char* src;
  STRLEN src_len;
  SV* dest;
  char* dst;
  size_t bound, ret;
CODE:
  if (!SvOK(source)) {
    XSRETURN_UNDEF;
  }
  src = SvPVbyte(source, src_len);
  bound = ZSTD_compressBound(src_len);
  dest = newSV(bound + 1);
  dst = SvPVX(dest);
  if (self->dict) {
    ret = ZSTD_compress_usingCDict(self->cctx, dst, bound + 1, src, src_len, self->dict);
  }
  else {
    ret = ZSTD_compressCCtx(self->cctx, dst, bound + 1, src, src_len, level);
  }
  if (ZSTD_isError(ret)) {
    croak("compress: %s", ZSTD_getErrorName(ret));
  }
  dst[ret] = '\0';
  SvCUR_set(dest, ret);
  SvPOK_on(dest);
  RETVAL = dest;
OUTPUT:
  RETVAL
