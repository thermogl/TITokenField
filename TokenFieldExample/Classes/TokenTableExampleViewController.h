//
//  Created by jac on 9/14/12.
//


#import <Foundation/Foundation.h>
#import "TITokenTableViewController.h"


@interface TokenTableExampleViewController : TITokenTableViewController <TITokenTableViewDataSource, TITokenTableViewControllerDelegate, UITextViewDelegate> {


    NSArray *_tokenFieldTitles;
    UITextView * _messageView;
    UITextField *_textFieldSubject;

    CGFloat _oldHeight;


}

@property(nonatomic, strong) TITokenTableViewController *tokenTableViewController;

@end