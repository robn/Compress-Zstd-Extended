#!perl

use strict;
use warnings;

use Test::More;
use Compress::Zstd::Extended;

my $src = 'Hello, World!';

my $c = Compress::Zstd::Compressor->new;
my $d = Compress::Zstd::Decompressor->new;

ok my $compressed = $c->compress($src);
isnt $src, $compressed;
ok my $decompressed = $d->decompress($compressed);
isnt $compressed, $decompressed;
is $decompressed, $src;

done_testing;
