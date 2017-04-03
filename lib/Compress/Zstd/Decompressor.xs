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

struct Decompressor {
  ZSTD_DCtx* dctx;
  ZSTD_DDict* dict;
};

typedef struct Decompressor *Compress__Zstd__Decompressor;

MODULE = Compress::Zstd::Decompressor  PACKAGE = Compress::Zstd::Decompressor

PROTOTYPES: DISABLE

Compress::Zstd::Decompressor
new(SV* class)
CODE:
  PERL_UNUSED_VAR(class);
  Newxz(RETVAL, 1, struct Decompressor);
  RETVAL->dctx = ZSTD_createDCtx();
OUTPUT:
  RETVAL

void
DESTROY(Compress::Zstd::Decompressor self)
CODE:
  if (self->dict)
    ZSTD_freeDDict(self->dict);
  ZSTD_freeDCtx(self->dctx);

void
set_dictionary(Compress::Zstd::Decompressor self, SV* dictionary)
PREINIT:
  const char* dict;
  STRLEN dict_len;
CODE:
  if (!SvOK(dictionary)) {
    XSRETURN_UNDEF;
  }
  dict = SvPVbyte(dictionary, dict_len);
  self->dict = ZSTD_createDDict(dict, dict_len);

SV*
decompress(Compress::Zstd::Decompressor self, SV* source)
PREINIT:
  const char* src;
  STRLEN src_len;
  unsigned long long dest_len;
  SV* dest;
  char* dst;
  size_t ret;
CODE:
  if (!SvOK(source)) {
    XSRETURN_UNDEF;
  }
  src = SvPVbyte(source, src_len);
  dest_len = ZSTD_getDecompressedSize(src, src_len);
  if (dest_len == ULLONG_MAX) {
    XSRETURN_UNDEF;
  }
  dest = newSV(dest_len + 1);
  dst = SvPVX(dest);
  if (self->dict) {
    ret = ZSTD_decompress_usingDDict(self->dctx, dst, dest_len + 1, src, src_len, self->dict);
  }
  else {
    ret = ZSTD_decompressDCtx(self->dctx, dst, dest_len + 1, src, src_len);
  }
  if (ZSTD_isError(ret)) {
    croak("decompress: %s", ZSTD_getErrorName(ret));
  }
  dst[ret] = '\0';
  SvCUR_set(dest, ret);
  SvPOK_on(dest);
  RETVAL = dest;
OUTPUT:
  RETVAL
