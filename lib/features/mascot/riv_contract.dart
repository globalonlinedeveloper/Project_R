/// Build-time `.riv` asset contract (R-L18 / C24). The real Rive mascot must be
/// a PURE-VECTOR `.riv`: a valid header, within the size budget, and with NO
/// embedded raster images (PNG/JPEG) — bitmaps bloat the download and break the
/// cheap-phone perf budget (R-N1/R-N8). Pure Dart so it runs as a test gate; it
/// guards the asset the moment the owner drops a real mascot rig into
/// `assets/rive/`.
class RivCheck {
  const RivCheck({required this.ok, required this.reason});
  final bool ok;
  final String reason;
  static const RivCheck pass = RivCheck(ok: true, reason: 'ok');
}

/// 256 KB budget for a single vector rig (placeholder bound; tune at real-asset time).
const int kRivMaxBytes = 256 * 1024;

RivCheck validateRivBytes(List<int> bytes, {int maxBytes = kRivMaxBytes}) {
  if (bytes.length < 4) {
    return const RivCheck(ok: false, reason: 'too small to be a .riv');
  }
  final magic = String.fromCharCodes(bytes.sublist(0, 4));
  if (magic != 'RIVE') {
    return RivCheck(ok: false, reason: 'missing RIVE header (got "$magic")');
  }
  if (bytes.length > maxBytes) {
    return RivCheck(
        ok: false, reason: 'over budget: ${bytes.length} > $maxBytes bytes');
  }
  if (_containsRaster(bytes)) {
    return const RivCheck(
        ok: false,
        reason: 'embedded raster (PNG/JPEG) not allowed — vector only');
  }
  return RivCheck.pass;
}

bool _containsRaster(List<int> b) {
  for (var i = 0; i + 3 < b.length; i++) {
    // PNG: 89 50 4E 47
    if (b[i] == 0x89 && b[i + 1] == 0x50 && b[i + 2] == 0x4E && b[i + 3] == 0x47) {
      return true;
    }
    // JPEG: FF D8 FF
    if (b[i] == 0xFF && b[i + 1] == 0xD8 && b[i + 2] == 0xFF) return true;
  }
  return false;
}
