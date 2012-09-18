//
//  TokenTableViewController.h
//  TokenFieldExample
//
//  Created by jac on 9/5/12.
//
//

#import <UIKit/UIKit.h>
#import "TITokenField.h"


@class TITokenTableViewController;

@protocol TITokenTableViewDataSource <NSObject>
@required



/**
* Provide a list of token filed prompt texts: "To:" "Cc:" ..
*/
-(NSString *)tokenFieldPromptAtRow:(NSUInteger) row;
-(NSUInteger) numberOfTokenRows;


/**
* E.g. a browse address book button.
*/
-(UIView *) accessoryViewForField:(TITokenField*) tokenField;


/**
* Other cells that ore not TITokenFields
**/

- (UITableViewCell *)tokenTableView:(TITokenTableViewController *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)tokenTableView:(TITokenTableViewController *)tableView numberOfRowsInSection:(NSInteger)section;

- (CGFloat)tokenTableView:(TITokenTableViewController *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;


@end




@protocol TITokenTableViewControllerDelegate <NSObject>

@optional
/**
* Called when a token field is selected
*/
-(void) tokenTableViewController:(TITokenTableViewController *) tokenTableViewController  didSelectTokenField:(TITokenField*) tokenField;

@end



@interface TITokenTableViewController : UITableViewController <TITokenFieldDelegate> {

    NSMutableArray * resultsArray;
    UITableView * resultsTable;
    UIPopoverController * popoverController;

    NSMutableDictionary * _tokenFields;


    TITokenField *_currentSelectedTokenField;


    CGFloat _keyboardHeight;

    BOOL _searchResultIsVisible;

    CGPoint _contentOffsetBeforeResultTable;


}


@property (nonatomic, assign) BOOL showAlreadyTokenized;
@property (nonatomic, copy) NSArray * sourceArray;

@property (nonatomic, weak) id<TITokenTableViewDataSource> tokenDataSource;
@property (nonatomic, weak) id<TITokenTableViewControllerDelegate> delegate;


-(void) updateContentSize;

@end
