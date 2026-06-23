// Driver for the on-device perf bench (integration_test/perf_bench_test.dart).
//
// `integrationDriver()` collects the test's `binding.reportData` from the
// device and (via the default `writeResponseData` callback) writes it to
// build/integration_response_data.json — the cold-start, frame-timing
// summaries (build + raster), and mascot memory captured by the bench. CI
// uploads that file as the `device-perf-bench` artifact.
//
// Run by: flutter drive --driver=test_driver/perf_driver.dart \
//   --target=integration_test/perf_bench_test.dart --profile

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
