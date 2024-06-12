// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ButtonFactory.h"

@interface PlatformButton: NSObject//<FlutterPlatformView>

@property (strong, nonatomic) NSButton *button;
@property (assign, nonatomic) int counter;

@end

@implementation PlatformButton

- (instancetype)init
{
  self = [super init];
  if (self) {
    _counter = 0;
    _button = [NSButton buttonWithTitle:@"Initial Button Title" target:self action:@selector(buttonTapped)];
  }
  return self;
}

- (NSView *)view {
  return self.button;
}

- (void)buttonTapped {
  self.counter += 1;
  NSString *title = [NSString stringWithFormat:@"Button Tapped %d", self.counter];
  self.button.title = title;
}

@end

@implementation ButtonFactory
- (nonnull NSView*)createWithViewIdentifier:(int64_t)viewId arguments:(nullable id)args {
  return [[PlatformButton alloc] init].view;
}
//- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args {
//  return [[PlatformButton alloc] init];
//}


@end
