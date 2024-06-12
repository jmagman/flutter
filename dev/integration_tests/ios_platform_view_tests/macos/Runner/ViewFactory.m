// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ViewFactory.h"

@interface PlatformView: NSObject//<FlutterPlatformView>

@property (strong, nonatomic) NSView *platformView;

@end

@implementation PlatformView

- (instancetype)init
{
  self = [super init];
  if (self) {
    _platformView = [[NSView alloc] init];
//    _platformView.backgroundColor = [NSColor blueColor];
  }
  return self;
}

- (NSView *)view {
  return self.platformView;
}

@end


@implementation ViewFactory

- (nonnull NSView*)createWithViewIdentifier:(int64_t)viewId arguments:(nullable id)args {
  return [[PlatformView alloc] init].view;
}

@end
