/*
 Copyright 2016-present The Material Motion Authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "ObjectiveCExampleViewController.h"

#import <MaterialMotionStreams/MaterialMotionStreams-Swift.h>

@implementation ObjectiveCExampleViewController {
  MDMMotionRuntime *_runtime;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
//    self.transitionController.directorClass = [SimpleTransitionDirector class];
  }
  return self;
}

+ (NSArray<NSString *> *)catalogBreadcrumbs {
  return @[ @"Objective-C" ];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _runtime = [[MDMMotionRuntime alloc] initWithContainerView:self.view];

  UIView *square = [[UIView alloc] initWithFrame:CGRectMake(200, 200, 64, 64)];
  square.backgroundColor = [UIColor redColor];
  [self.view addSubview:square];

  [_runtime add:[MDMDraggable new] to:square];
}

@end
