/// Off-web (mobile/desktop/VM tests) remote-text fetch: honestly unavailable.
/// The content ladder degrades to the bundled asset — never a broken boot.
Future<String?> fetchRemoteText(Uri url,
        {Duration timeout = const Duration(seconds: 4)}) async =>
    null;
