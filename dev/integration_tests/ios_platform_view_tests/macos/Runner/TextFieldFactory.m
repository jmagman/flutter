// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "TextFieldFactory.h"

@interface PlatformTextField: NSObject//<FlutterPlatformView>

@property (strong, nonatomic) NSTextField *textField;

@end

@implementation PlatformTextField

- (instancetype)init
{
  self = [super init];
  if (self) {
    _textField = [NSTextField textFieldWithString:@"Platform Text Field"];
//    _textField.text = @"Platform Text Field";
  }
  return self;
}

- (NSView *)view {
  return self.textField;
}

@end

@implementation TextFieldFactory

- (nonnull NSView*)createWithViewIdentifier:(int64_t)viewId arguments:(nullable id)args {
  return [[PlatformTextField alloc] init].view;
}

//- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args {
//  return [[PlatformTextField alloc] init];
//}

@end
