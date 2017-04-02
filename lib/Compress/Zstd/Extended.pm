package Compress::Zstd::Extended;

# ABSTRACT: Extended Perl interface to the Zstd compression library

use 5.008001;
use strict;
use warnings;

use XSLoader;
XSLoader::load(__PACKAGE__, $Compress::Zstd::Extended::VERSION);

1;
