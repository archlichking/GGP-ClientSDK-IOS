//
// Copyright 2012 GREE, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <UIKit/UIKit.h>
#import "Kiwi.h"
#import "GreeRotator.h"

@interface GreeRotatorContainerView : UIView
@end

@interface GreeRotator (ExposedPrivateMethods)
+ (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)interfaceOrientation;
+ (CGRect)boundsForOrientation:(UIInterfaceOrientation)interfaceOrientation rect:(CGRect)rect;
+ (CGPoint)centerForOrientation:(UIInterfaceOrientation)interfaceOrientation bounds:(CGRect)bounds;
- (NSDictionary*)rotatingViewsDictionary;
@end

@class GreeRotatorContainerView;

#pragma mark - GreeRotatorTests

SPEC_BEGIN(GreeRotatorTests)

describe(@"GreeRotator", ^{
  it(@"should initialize with default to default values",^{
    GreeRotator *rotator = [[GreeRotator alloc] init];
    [rotator shouldNotBeNil];
    [[rotator performSelector:@selector(rotatingViewsDictionary)] shouldNotBeNil];
    [rotator release];
  });
  
  it(@"should keep track of a rotating subview", ^{  
    GreeRotatorContainerView *containerView = [GreeRotatorContainerView nullMock];
    [containerView stub:@selector(initWithFrame:) andReturn:containerView];
    [[containerView should] receive:@selector(addSubview:)];
    [GreeRotatorContainerView stub:@selector(alloc) andReturn:containerView];
  
    GreeRotator *rotator = [[GreeRotator alloc] init];
    
    UIView *subview = [UIView nullMock];
    UIView *superview = [UIView nullMock];
    
    [rotator beginRotatingSubview:subview insideOfView:superview relativeToInterfaceOrientation:UIInterfaceOrientationPortrait];
    
    NSDictionary *rotatingViewsDictionary = [rotator rotatingViewsDictionary];
    [[theValue([rotatingViewsDictionary count]) should] equal:theValue(1)];
    [[[rotatingViewsDictionary objectForKey:[NSValue valueWithNonretainedObject:subview]] should] beIdenticalTo:containerView];
    [rotator release];
  });

  it(@"should rotate its subviews", ^{  
    GreeRotatorContainerView *containerView = [GreeRotatorContainerView nullMock];
    [containerView stub:@selector(initWithFrame:) andReturn:containerView];
    [GreeRotatorContainerView stub:@selector(alloc) andReturn:containerView];
  
    GreeRotator *rotator = [[GreeRotator alloc] init];
    
    UIView *subview = [UIView nullMock];
    UIView *superview = [UIView nullMock];
    
    [rotator beginRotatingSubview:subview insideOfView:superview relativeToInterfaceOrientation:UIInterfaceOrientationPortrait];
    
    [[containerView should] receive:@selector(setTransform:)];
    [[containerView should] receive:@selector(setBounds:)];
    [[containerView should] receive:@selector(setCenter:)];
    [rotator rotateViewsToInterfaceOrientation:UIInterfaceOrientationLandscapeRight animated:NO duration:0.0f];
  });

  it(@"should support animating its rotation", ^{  
    [[UIView should] receive:@selector(animateWithDuration:animations:)];
  
    GreeRotatorContainerView *containerView = [GreeRotatorContainerView nullMock];
    [containerView stub:@selector(initWithFrame:) andReturn:containerView];
    [GreeRotatorContainerView stub:@selector(alloc) andReturn:containerView];
  
    GreeRotator *rotator = [[GreeRotator alloc] init];
    
    UIView *subview = [UIView nullMock];
    UIView *superview = [UIView nullMock];
    
    [rotator beginRotatingSubview:subview insideOfView:superview relativeToInterfaceOrientation:UIInterfaceOrientationPortrait];
    [rotator rotateViewsToInterfaceOrientation:UIInterfaceOrientationLandscapeRight animated:YES duration:0.0f];
  });

  it(@"should be able to stop rotating its subview", ^{  
    GreeRotatorContainerView *containerView = [GreeRotatorContainerView nullMock];
    [containerView stub:@selector(initWithFrame:) andReturn:containerView];
    [[containerView should] receive:@selector(addSubview:)];
    [GreeRotatorContainerView stub:@selector(alloc) andReturn:containerView];
  
    GreeRotator *rotator = [[GreeRotator alloc] init];
    
    UIView *subview = [UIView nullMock];
    [[subview should] receive:@selector(removeFromSuperview)];
    UIView *superview = [UIView nullMock];
        
    [rotator beginRotatingSubview:subview insideOfView:superview relativeToInterfaceOrientation:UIInterfaceOrientationPortrait];
    
    NSDictionary *rotatingViewsDictionary = [rotator rotatingViewsDictionary];
    [[theValue([rotatingViewsDictionary count]) should] equal:theValue(1)];
    [[[rotatingViewsDictionary objectForKey:[NSValue valueWithNonretainedObject:subview]] should] beIdenticalTo:containerView];
    
    [rotator endRotatingSubview:subview];
    
    rotatingViewsDictionary = [rotator rotatingViewsDictionary];
    [[theValue([rotatingViewsDictionary count]) should] equal:theValue(0)];
    [[rotatingViewsDictionary objectForKey:[NSValue valueWithNonretainedObject:subview]] shouldBeNil];
    
    [rotator release];
  });
  
  context(@"when calculating the rotation",^{
    it(@"should return the correct rotation transform for the given rotation",^{
      CGAffineTransform portraitTransform = CGAffineTransformIdentity;
      CGAffineTransform landscapeRightTransform = CGAffineTransformMakeRotation(M_PI_2);
      CGAffineTransform portraitUpsideDownTransform = CGAffineTransformMakeRotation(M_PI);
      CGAffineTransform landscapeLeftTransform = CGAffineTransformMakeRotation(3*M_PI_2);
      
      [[theValue((BOOL)CGAffineTransformEqualToTransform(
          [GreeRotator transformForOrientation:UIInterfaceOrientationPortrait],
          portraitTransform
        )) should] beYes];

      
      [[theValue((BOOL)CGAffineTransformEqualToTransform(
          [GreeRotator transformForOrientation:UIInterfaceOrientationLandscapeRight],
          landscapeRightTransform
        )) should] beYes];
            
      [[theValue((BOOL)CGAffineTransformEqualToTransform(
          [GreeRotator transformForOrientation:UIInterfaceOrientationPortraitUpsideDown],
          portraitUpsideDownTransform
        )) should] beYes];      

      [[theValue((BOOL)CGAffineTransformEqualToTransform(
          [GreeRotator transformForOrientation:UIInterfaceOrientationLandscapeLeft],
          landscapeLeftTransform
        )) should] beYes];
    });

    it(@"should swap the width and height of the superview's frame if the rotation is landscape",^{
      CGRect superviewBounds = CGRectMake(0.0f, 0.0f, 100.0f, 200.0f);
      
      CGRect portraitBounds = [GreeRotator boundsForOrientation:UIInterfaceOrientationPortrait rect:superviewBounds];
      [[theValue(portraitBounds.size.width) should] equal:theValue(superviewBounds.size.width)];
      [[theValue(portraitBounds.size.height) should] equal:theValue(superviewBounds.size.height)];
      
      CGRect portraitUpsideDownBounds = [GreeRotator boundsForOrientation:UIInterfaceOrientationPortraitUpsideDown rect:superviewBounds];
      [[theValue(portraitUpsideDownBounds.size.width) should] equal:theValue(superviewBounds.size.width)];
      [[theValue(portraitUpsideDownBounds.size.height) should] equal:theValue(superviewBounds.size.height)];

      CGRect landscapeLeftBounds = [GreeRotator boundsForOrientation:UIInterfaceOrientationLandscapeLeft rect:superviewBounds];
      [[theValue(landscapeLeftBounds.size.width) should] equal:theValue(superviewBounds.size.height)];
      [[theValue(landscapeLeftBounds.size.height) should] equal:theValue(superviewBounds.size.width)];
      
      CGRect landscapeRightBounds = [GreeRotator boundsForOrientation:UIInterfaceOrientationLandscapeRight rect:superviewBounds];
      [[theValue(landscapeRightBounds.size.width) should] equal:theValue(superviewBounds.size.height)];
      [[theValue(landscapeRightBounds.size.height) should] equal:theValue(superviewBounds.size.width)];
    });

    it(@"should return the center position, adjusted for the rotation",^{
      CGRect superviewBounds = CGRectMake(0.0f, 0.0f, 100.0f, 200.0f);
      
      CGPoint portraitCenter = [GreeRotator centerForOrientation:UIInterfaceOrientationPortrait bounds:superviewBounds];
      [[theValue(portraitCenter.x) should] equal:superviewBounds.size.width/2.0f withDelta:0.01f];
      [[theValue(portraitCenter.y) should] equal:superviewBounds.size.height/2.0f withDelta:0.01f];
      
      CGPoint portraitUpsideDownCenter = [GreeRotator centerForOrientation:UIInterfaceOrientationPortraitUpsideDown bounds:superviewBounds];
      [[theValue(portraitUpsideDownCenter.x) should] equal:superviewBounds.size.width/2.0f withDelta:0.01f];
      [[theValue(portraitUpsideDownCenter.y) should] equal:superviewBounds.size.height/2.0f withDelta:0.01f];
      
      CGPoint landscapeLeftCenter = [GreeRotator centerForOrientation:UIInterfaceOrientationLandscapeLeft bounds:superviewBounds];
      [[theValue(landscapeLeftCenter.x) should] equal:superviewBounds.size.height/2.0f withDelta:0.01f];
      [[theValue(landscapeLeftCenter.y) should] equal:superviewBounds.size.width/2.0f withDelta:0.01f];
      
      CGPoint landscapeRightCenter = [GreeRotator centerForOrientation:UIInterfaceOrientationPortrait bounds:superviewBounds];
      [[theValue(landscapeRightCenter.x) should] equal:superviewBounds.size.width/2.0f withDelta:0.01f];
      [[theValue(landscapeRightCenter.y) should] equal:superviewBounds.size.height/2.0f withDelta:0.01f];

    });
  });
});
SPEC_END
