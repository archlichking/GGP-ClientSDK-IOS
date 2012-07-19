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
#import "AddressBook/AddressBook.h"
#import "GreeJSGetContactListCommand.h"
#import "JSONKit.h"
//NOTE: running these tests will result in your address book being replaced with test data!

#pragma mark - GreeJSGetContactListCommandTest

//this holds all the boilerplate.  In the end, you care about resultArray.
#define testFrameworkInternal()\
ABAddressBookSave(modifiedBookRef, nil);\
GreeJSGetContactListCommand* command = [[GreeJSGetContactListCommand alloc] init];\
[command stub:@selector(environment)];\
NSDictionary* returnValue = [NSMutableDictionary dictionary];\
[command execute:returnValue];\
[[returnValue should] beNonNil];\
[[theValue(returnValue.count) should] equal:theValue(1)];\
NSString* resultString = [returnValue objectForKey:@"result"];\
GreeJSONDecoder* decoder = [GreeJSONDecoder decoder];\
const unsigned char*resultChars = (const unsigned char*)[ resultString UTF8String];\
NSArray* resultArray = [decoder objectWithUTF8String:resultChars length:[resultString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];



SPEC_BEGIN(GreeJSGetContactListCommandTest)
describe(@"JSGetContactList", ^{
  __block ABAddressBookRef modifiedBookRef;
  beforeEach(^{    
    //clear the book
    modifiedBookRef = ABAddressBookCreate();
    NSArray*contactArray = (NSArray*) ABAddressBookCopyArrayOfAllPeople(modifiedBookRef);
    for(int i=0; i<contactArray.count; ++i) {
      ABRecordRef record = (ABRecordRef)[contactArray objectAtIndex:i];
      ABAddressBookRemoveRecord(modifiedBookRef, record, nil);
    }
  });
  afterEach(^{
    CFRelease(modifiedBookRef);
  });
  it(@"should work with empty set", ^{
    //set the data
    testFrameworkInternal();
    //check the result
    [[resultString should] equal:@"[]"];
    [[resultArray should] beEmpty];
  });
  
  it(@"should read first/last names", ^{
    ABRecordRef person = ABPersonCreate();
    ABRecordSetValue(person, kABPersonFirstNameProperty, @"Bob", nil);
    ABRecordSetValue(person, kABPersonLastNameProperty, @"Smith", nil);
    ABAddressBookAddRecord(modifiedBookRef, person, nil);
    CFRelease(person);
    testFrameworkInternal();
    NSDictionary* bob = [resultArray objectAtIndex:0];
    [[[bob objectForKey:@"firstName"] should] equal:@"Bob"];
    [[[bob objectForKey:@"lastName"] should] equal:@"Smith"];
  });
  
  it(@"should retreive emails and return them in an array", ^{
    ABRecordRef person = ABPersonCreate();
    ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(email, @"mail.me@example.com", (CFStringRef) @"main", nil);
    ABRecordSetValue(person, kABPersonEmailProperty, email, nil);
    ABAddressBookAddRecord(modifiedBookRef, person, nil);
    CFRelease(person);
    CFRelease(email);
    testFrameworkInternal();
    NSDictionary* bob = [resultArray objectAtIndex:0];
    [[[bob objectForKey:@"emails"] should] equal:[NSArray arrayWithObject:@"mail.me@example.com"]];
  });
  
  it(@"should return all registered emails", ^{
    ABRecordRef person = ABPersonCreate();
    ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(email, @"mail.me@example.com", (CFStringRef) @"main", nil);
    ABMultiValueAddValueAndLabel(email, @"doppelganger@example.com", (CFStringRef) @"extra", nil);
    ABRecordSetValue(person, kABPersonEmailProperty, email, nil);
    ABAddressBookAddRecord(modifiedBookRef, person, nil);
    CFRelease(person);
    CFRelease(email);
    testFrameworkInternal();
    NSDictionary* bob = [resultArray objectAtIndex:0];
    [[[bob objectForKey:@"emails"] should] equal:[NSArray arrayWithObjects:@"mail.me@example.com", @"doppelganger@example.com", nil]];
  });  
  
  it(@"should read phone numbers", ^{
    ABRecordRef person = ABPersonCreate();
    ABMutableMultiValueRef phone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(phone, @"555-1212", kABHomeLabel, nil);
    ABMultiValueAddValueAndLabel(phone, @"555-5555", kABPersonPhoneMobileLabel, nil);
    ABMultiValueAddValueAndLabel(phone, @"867-5309", (CFStringRef)@"jenny", nil);
    ABRecordSetValue(person, kABPersonPhoneProperty, phone, nil);
    ABAddressBookAddRecord(modifiedBookRef, person, nil);
    CFRelease(person);
    CFRelease(phone);
    testFrameworkInternal();
    NSDictionary* bob = [resultArray objectAtIndex:0];
    [[[bob objectForKey:@"homePhoneNumber"] should] equal:@"555-1212"];
    [[[bob objectForKey:@"mobilePhoneNumber"] should] equal:@"555-5555"];
  });
  
  it(@"should handle everything", ^{
    ABRecordRef person = ABPersonCreate();
    ABRecordSetValue(person, kABPersonFirstNameProperty, @"Bob", nil);
    ABRecordSetValue(person, kABPersonLastNameProperty, @"Smith", nil);
    ABMutableMultiValueRef phone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(phone, @"555-1212", kABHomeLabel, nil);
    ABMultiValueAddValueAndLabel(phone, @"555-5555", kABPersonPhoneMobileLabel, nil);
    ABRecordSetValue(person, kABPersonPhoneProperty, phone, nil);
    ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(email, @"mail.me@example.com", (CFStringRef) @"main", nil);
    ABRecordSetValue(person, kABPersonEmailProperty, email, nil);
    ABAddressBookAddRecord(modifiedBookRef, person, nil);
    CFRelease(person);
    CFRelease(phone);
    CFRelease(email);
    testFrameworkInternal();
    NSDictionary* bob = [resultArray objectAtIndex:0];
    [[[bob objectForKey:@"firstName"] should] equal:@"Bob"];
    [[[bob objectForKey:@"lastName"] should] equal:@"Smith"];
    [[[bob objectForKey:@"emails"] should] equal:[NSArray arrayWithObject:@"mail.me@example.com"]];
    [[[bob objectForKey:@"homePhoneNumber"] should] equal:@"555-1212"];
    [[[bob objectForKey:@"mobilePhoneNumber"] should] equal:@"555-5555"];
  });
  
  it(@"should read multiple records", ^{
    ABRecordRef person = ABPersonCreate();
    ABRecordSetValue(person, kABPersonFirstNameProperty, @"Bob", nil);
    ABAddressBookAddRecord(modifiedBookRef, person, nil);    
    ABRecordRef person2 = ABPersonCreate();
    ABRecordSetValue(person2, kABPersonFirstNameProperty, @"Alice", nil);
    ABAddressBookAddRecord(modifiedBookRef, person2, nil);
    ABRecordRef person3 = ABPersonCreate();
    ABRecordSetValue(person3, kABPersonFirstNameProperty, @"Carl", nil);
    ABAddressBookAddRecord(modifiedBookRef, person3, nil);
    CFRelease(person);
    CFRelease(person2);
    testFrameworkInternal();
    [[theValue(resultArray.count) should] equal:theValue(3)];
    
    NSArray* kvc = [resultArray valueForKey:@"firstName"];
    [[kvc should] containObjects:@"Alice", @"Bob", @"Carl", nil];
    
    
  });
  
  
});

SPEC_END
