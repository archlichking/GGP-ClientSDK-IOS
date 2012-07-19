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


#import "Kiwi.h"
#import "GreeTestHelpers.h"

#import "GreeJSInputViewController.h"

#pragma mark - GreeJSInputViewControllerTests

@interface GreeJSInputViewController(ExposePrivateAPIS)

@property (nonatomic, retain) NSDictionary* initialParams;
@property (nonatomic, retain) NSSet *previousOrientations;
@property (nonatomic, retain) NSArray *atLeastOneRequiredFields;
@property (nonatomic, retain) NSArray *requiredFields;

- (void)setupTextLimit:(NSDictionary *)params;
- (void)createCallbackParams:(NSDictionary *)params;
- (void)showImagePicker:(UIButton *)sender;
- (void)showImagePickerSelected:(UIButton *)sender;
- (void)showImageTypeSelector:(BOOL)selected withTag:(NSInteger)tag;
- (void)setImage:(UIImage *)image atIndex:(NSInteger)index;
- (void)removeImageAtIndex:(NSInteger)index;
- (void)setPlaceholder:(NSString *)placeholder color:(UIColor *)color;
- (void)showPlaceholder;
- (void)hidePlaceholder;
- (void)onUIKeyboardWillShowNotification:(NSNotification *)notification;
- (void)setupValidation:(NSDictionary*)params;
- (BOOL)validate;
- (NSArray*)parseAtLeastOneRequiredFieldsForParams:(NSDictionary*)params;
- (BOOL)isFieldRequired:(NSString*)fieldName forParams:(NSDictionary*)params;
- (BOOL)validateField:(NSString*)fieldName;
- (BOOL)validateTextField;
- (BOOL)validatePhotoField;
- (int)textLength;

@end

SPEC_BEGIN(GreeJSInputViewControllerTests)

describe(@"GreeJSInputViewController", ^{
  __block GreeJSInputViewController *viewController;
  beforeEach(^{
    NSDictionary *params = [NSDictionary mock];
    [[params should] receive:@selector(copy) andReturn:nil];
    viewController = [[GreeJSInputViewController alloc] initWithParams:params];
  });
  afterEach(^{
    [viewController release];
  });
  context(@"when initializing", ^{
    it(@"should initialize with params", ^{
    });
    
    it(@"should setup textLimit", ^{
    });
    it(@"should setup validation", ^{
    });
    it(@"should create callback params", ^{
    });
  });
  
  context(@"when call shouldAutorotateToInterfaceOrientation:", ^{
    context(@"when manually rotate", ^{
      it(@"should return GreePlatform interfaceOrientation value and an arg equality", ^{
        GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
        [[platform should] receive:@selector(manuallyRotate) andReturn:theValue(YES)];
        
        // some diffrent values
        UIInterfaceOrientation arg = UIInterfaceOrientationPortrait;
        [[platform should] receive:@selector(interfaceOrientation) andReturn:theValue(UIInterfaceOrientationLandscapeLeft)];
        
        [[theValue([viewController shouldAutorotateToInterfaceOrientation:arg]) should] beNo];
      });
    });
    
    context(@"when not manually rotate", ^{
      it(@"should return YES", ^{
        GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
        [[platform should] receive:@selector(manuallyRotate) andReturn:theValue(NO)];
        
        // some value
        UIInterfaceOrientation arg = UIInterfaceOrientationPortrait;
        
        [[platform shouldNot] receive:@selector(interfaceOrientation)];
        
        [[theValue([viewController shouldAutorotateToInterfaceOrientation:arg]) should] beYes];
      });
    });
  });
  
  context(@"when view will appear", ^{
    it(@"should add observers", ^{
      [[[NSNotificationCenter defaultCenter] should] receive:@selector(addObserver:selector:name:object:) withCountAtLeast:2];
      BOOL someBool = false;
      [viewController viewWillAppear:someBool];
      [NSNotificationCenter clearStubs];
    });
  });
  
  context(@"when view disappear", ^{
    it(@"should remove observers", ^{
      [[[NSNotificationCenter defaultCenter] should] receive:@selector(removeObserver:)];
      BOOL someBool = false;
      [viewController viewWillDisappear:someBool];
      [NSNotificationCenter clearStubs];
    });
  });
  
  context(@"when call data", ^{
    it(@"should return a text and iamges", ^{
      viewController.textView = [UITextView mock];
      [[viewController.textView should] receive:@selector(text) andReturn:@"Foo"];
      viewController.toolbar = nil;
      NSDictionary *dic = [viewController data];
      [[[dic valueForKey:@"text"] should] equal:@"Foo"];
    });
  });
  
  context(@"when call callBack", ^{
    it(@"should return a text and iamges", ^{
      viewController.textView = [UITextView mock];
      [[viewController.textView should] receive:@selector(text) andReturn:@"Foo"];
      viewController.toolbar = nil;
      NSDictionary *dic = [viewController data];
      [[[dic valueForKey:@"text"] should] equal:@"Foo"];
    });
  });
  
  context(@"when call textLength", ^{
    it(@"should return text length count Surrogate Pairs and Emoji as 1 character", ^{
      viewController.textView = [UITextView mock];
      [[viewController.textView should] receive:@selector(text) andReturn:@"Foo"];
      [[theValue([viewController textLength]) should] equal:theValue(3)];
      
      viewController.textView = [UITextView mock];
      [[viewController.textView should] receive:@selector(text) andReturn:@"あいう"];
      [[theValue([viewController textLength]) should] equal:theValue(3)];
      
      viewController.textView = [UITextView mock];
      [[viewController.textView should] receive:@selector(text) andReturn:@"あいう\nえお"];
      [[theValue([viewController textLength]) should] equal:theValue(6)];
      
      viewController.textView = [UITextView mock];
      [[viewController.textView should] receive:@selector(text) andReturn:@"𡈽方𥧄𪚲"];
      [[theValue([viewController textLength]) should] equal:theValue(4)];
      
      viewController.textView = [UITextView mock];
      [[viewController.textView should] receive:@selector(text) andReturn:@"⛄⛪0⃣4⃣🇯🇵🇺🇸"];
      [[theValue([viewController textLength]) should] equal:theValue(6)];
    });
  });
  
});

SPEC_END
