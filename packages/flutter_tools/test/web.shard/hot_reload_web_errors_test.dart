// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@Tags(<String>['flutter-test-driver'])
library;

import 'dart:io';

import '../integration.shard/test_data/hot_reload_errors_common.dart';
import '../src/common.dart';

void main() {
  testAll(
    chrome: true,
    additionalCommandArgs: <String>[
      '--extra-front-end-options=--dartdevc-canary,--dartdevc-module-format=ddc',
    ],
    // TODO(srujzs): Remove this custom message once we have the delta inspector emitting the same
    // string as the VM.
    constClassFieldRemovalErrorMessage: 'Const class cannot remove fields',
    // https://github.com/flutter/flutter/issues/162567
    skip: Platform.isWindows,
  );
}
