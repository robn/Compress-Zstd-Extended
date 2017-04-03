#!perl

use strict;
use warnings;

use Test::More;
use Compress::Zstd::Extended;

my $src = do { local $/; <DATA> };
my @lines = split '\n', $src;

my @sizes = map { length($_) + 1 } @lines;

my $dict = Compress::Zstd::Dictionary->from_buffer($src, \@sizes);
isnt $dict, undef;

my $c = Compress::Zstd::Compressor->new;
$c->set_dictionary($dict);
my $d = Compress::Zstd::Decompressor->new;
$d->set_dictionary($dict);

for my $line (@lines) {
  ok my $compressed = $c->compress($line);
  isnt $line, $compressed;

  ok my $decompressed = $d->decompress($compressed);
  isnt $compressed, $decompressed;
  is $decompressed, $line;
}

done_testing;

__DATA__
Apr  3 16:34:17 lena com.apple.xpc.launchd[1] (com.apple.imfoundation.IMRemoteURLConnectionAgent): Unknown key for integer: _DirtyJetsamMemoryLimit
Apr  3 16:34:17 lena syslogd[51]: ASL Sender Statistics
Apr  3 16:34:17 lena com.apple.xpc.launchd[1] (com.apple.imfoundation.IMRemoteURLConnectionAgent): Unknown key for integer: _DirtyJetsamMemoryLimit
Apr  3 16:34:18 lena com.apple.xpc.launchd[1] (com.apple.xpc.launchd.domain.pid.IDECacheDeleteAppExtension.77834): Path not allowed in target domain: type = pid, path = /Applications/Xcode.app/Contents/SharedFrameworks/LLDB.framework/Versions/A/XPCServices/RootDebuggingXPCService.xpc error = 147: The specified service did not ship in the requestor's bundle, origin = /Applications/Xcode.app/Contents/PlugIns/IDECacheDeleteAppExtension.appex
Apr  3 16:34:38 lena com.apple.xpc.launchd[1] (com.apple.imfoundation.IMRemoteURLConnectionAgent): Unknown key for integer: _DirtyJetsamMemoryLimit
Apr  3 16:34:38 --- last message repeated 1 time ---
Apr  3 16:34:38 lena com.apple.xpc.launchd[1] (com.apple.xpc.launchd.domain.pid.IDECacheDeleteAppExtension.77840): Path not allowed in target domain: type = pid, path = /Applications/Xcode.app/Contents/SharedFrameworks/LLDB.framework/Versions/A/XPCServices/RootDebuggingXPCService.xpc error = 147: The specified service did not ship in the requestor's bundle, origin = /Applications/Xcode.app/Contents/PlugIns/IDECacheDeleteAppExtension.appex
Apr  3 16:36:22 lena CrashPlan menu bar[1635]: Asked to change 'isConnected' status for GUID 788534906020137955, but I couldn't find any computer with that GUID.
Apr  3 16:36:44 lena login[79200]: USER_PROCESS: 79200 ttys006
Apr  3 16:39:06 lena com.apple.xpc.launchd[1] (com.apple.imfoundation.IMRemoteURLConnectionAgent): Unknown key for integer: _DirtyJetsamMemoryLimit
Apr  3 16:41:05 lena login[81096]: USER_PROCESS: 81096 ttys009
Apr  3 16:41:10 lena login[81145]: USER_PROCESS: 81145 ttys011
Apr  3 16:41:17 lena com.apple.xpc.launchd[1] (com.apple.mdworker.shared.03000000-0000-0000-0000-000000000000): Service only ran for 9 seconds. Pushing respawn out by 1 seconds.
Apr  3 16:41:35 lena CrashPlan menu bar[1635]: Asked to change 'isConnected' status for GUID 788534906020137955, but I couldn't find any computer with that GUID.
Apr  3 16:41:54 lena login[81145]: DEAD_PROCESS: 81145 ttys011
