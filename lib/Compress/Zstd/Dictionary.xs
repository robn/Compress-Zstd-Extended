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
#include "zdict.h"

#define DICT_SIZE (128*1024) /* 128K */

MODULE = Compress::Zstd::Dictionary  PACKAGE = Compress::Zstd::Dictionary

PROTOTYPES: DISABLE

SV*
from_buffer(SV* class, SV* samples, AV* sizes)
PREINIT:
  size_t num_sizes;
  void* samp_buf;
  size_t* samp_sizes;
  SV** size;
  SV* dict;
  char* dict_buf;
  size_t ret;
CODE:
  num_sizes = av_top_index(sizes) + 1;
  if (num_sizes == 0) {
    XSRETURN_UNDEF;
  }
  /* XXX make sure the total of sizes is not past the end of samples */
  samp_buf = SvPVX(samples);
  Newxz(samp_sizes, num_sizes, size_t);
  for (int i = 0; i < num_sizes; i++) {
    size = av_fetch(sizes, i, 0);
    if (!(size && *size && SvOK(*size))) {
      croak("from_buffer: sizes list must only contain numeric values");
    }
    samp_sizes[i] = SvIVx(*size);
  }
  dict = newSV(DICT_SIZE);
  dict_buf = SvPVX(dict);
  ret = ZDICT_trainFromBuffer(dict_buf, DICT_SIZE, samp_buf, samp_sizes, num_sizes);
  Safefree(samp_sizes);
  if (ZDICT_isError(ret)) {
    croak("from_buffer: %s", ZDICT_getErrorName(ret));
  }
  SvCUR_set(dict, ret);
  SvPOK_on(dict);
  RETVAL = dict;
OUTPUT:
  RETVAL
