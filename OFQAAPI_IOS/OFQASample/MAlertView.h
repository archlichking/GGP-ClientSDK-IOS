// MAlertView.h
//
#import <Foundation/Foundation.h>

@interface  MAlertView:UIAlertView {
    UITextField  *passwdField;
    NSInteger  textFieldCount;
}

- (void)addTextField:(UITextField *)aTextField placeHolder:(NSString *)placeHolder;

@end
