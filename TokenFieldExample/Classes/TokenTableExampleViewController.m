//
//  Created by jac on 9/14/12.
//


#import "TokenTableExampleViewController.h"
#import "Names.h"

#define kOtherCellSubject 0
#define kOtherCellBody 1
#define kOtherCellCount 2


#define kOtherCellBodyHeight 300

@implementation TokenTableExampleViewController {


}
@synthesize tokenTableViewController = _tokenTableViewController;


- (id)init {
    self = [super init];
    if (self) {
        _tokenFieldTitles = @[@"To:", @"Cc:", @"Bcc:"];
        _oldHeight = kOtherCellBodyHeight;
    }

    return self;
}



#pragma mark - TokenTableViewDataSource

- (NSString *)tokenFieldPromptAtRow:(NSUInteger)row {
    return _tokenFieldTitles[row];
}

- (NSUInteger)numberOfTokenRows {
    return _tokenFieldTitles.count;
}

- (UIView *)accessoryViewForField:(TITokenField *)tokenField {

    UIButton * addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
   	[addButton addTarget:self action:@selector(showContactsPicker:) forControlEvents:UIControlEventTouchUpInside];
   	[tokenField setRightView:addButton];

    return addButton;
}


#pragma mark - TokenTableViewDataSource (Other table cells)

- (CGFloat)tokenTableView:(TITokenTableViewController *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.row) {
        case kOtherCellSubject:
            return 44;
        case kOtherCellBody:
            return _oldHeight;
        default:
            return 0;
    }
}


- (NSInteger)tokenTableView:(TITokenTableViewController *)tableView numberOfRowsInSection:(NSInteger)section {
    return kOtherCellCount;
}


- (UITableViewCell *)tokenTableView:(TITokenTableViewController *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;


    static NSString *CellIdentifierSubject = @"SubjectCell";
    static NSString *CellIdentifierBody = @"BodyCell";


    UIView *contentSubview = nil;
    // todo save the cells to keep their text active
    switch (indexPath.row) {
        case kOtherCellSubject:
            cell = [tableView.tableView dequeueReusableCellWithIdentifier:CellIdentifierSubject];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierSubject];
                if(!_textFieldSubject) {
                    //UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, cell.frame.size.height / 2 - textView.font.lineHeight, tableView.tableView.bounds.size.width, 30)];
                    _textFieldSubject = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
                    _textFieldSubject.frame = CGRectMake(10, cell.frame.size.height / 2 - _textFieldSubject.font.lineHeight / 2, tableView.tableView.bounds.size.width, 30);


                    //textField.backgroundColor = [UIColor lightGrayColor];

                    _textFieldSubject.placeholder = @"Subject";

                }

            }
            //[cell.contentView addSubview:_textFieldSubject];
            contentSubview = _textFieldSubject;
            break;

        case kOtherCellBody:
            cell = [tableView.tableView dequeueReusableCellWithIdentifier:CellIdentifierBody];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierBody];
                cell.frame = CGRectMake(0, 0, cell.frame.size.width, kOtherCellBodyHeight);
                if (!_messageView) {
                    _messageView = [[UITextView alloc] initWithFrame:cell.frame];
                   	[_messageView setScrollEnabled:NO];
                   	[_messageView setAutoresizingMask:UIViewAutoresizingNone];
                   	[_messageView setDelegate:self];
                   	[_messageView setFont:[UIFont systemFontOfSize:15]];
                   	[_messageView setText:@"Some message. The whole view resizes as you type, not just the text view."];

                }

            }
            contentSubview = _messageView;
            break;

        default:
            break;
    }

    if(contentSubview && cell) {

        BOOL addSubview = YES;
        for (UIView * subView in [cell.contentView subviews]) {
            if(subView == contentSubview) {
                addSubview = NO;
                break;
            }

        }

        if(addSubview) {
            [cell.contentView addSubview:contentSubview];
        }

    }

    return cell;

}




- (void)showContactsPicker:(id)sender {

	// Show some kind of contacts picker in here.
	// For now, here's how to add and customize tokens.

	NSArray * names = [Names listOfNames];

	TIToken * token = [_currentSelectedTokenField addTokenWithTitle:[names objectAtIndex:(arc4random() % names.count)]];
	[token setAccessoryType:TITokenAccessoryTypeDisclosureIndicator];
	// If the size of the token might change, it's a good idea to layout again.
	[_currentSelectedTokenField layoutTokensAnimated:YES];

	NSUInteger tokenCount = _currentSelectedTokenField.tokens.count;
	[token setTintColor:((tokenCount % 3) == 0 ? [TIToken redTintColor] : ((tokenCount % 2) == 0 ? [TIToken greenTintColor] : [TIToken blueTintColor]))];
}


#pragma mark - TokenTableViewControllerDelegate

- (void)tokenTableViewController:(TITokenTableViewController *)tokenTableViewController didSelectTokenField:(TITokenField *)tokenField {
    _currentSelectedTokenField = tokenField;
}



- (void)textViewDidChange:(UITextView *)textView {

	//CGFloat oldHeight = tokenFieldView.frame.size.height - tokenFieldView.tokenField.frame.size.height;
	CGFloat newHeight = textView.contentSize.height + textView.font.lineHeight;

    if(newHeight < kOtherCellBodyHeight) {
        newHeight = kOtherCellBodyHeight;
    }

	CGRect newTextFrame = textView.frame;
	newTextFrame.size = textView.contentSize;
	newTextFrame.size.height = newHeight;


	if (newHeight < _oldHeight){
		newTextFrame.size.height = _oldHeight;

	}

	[textView setFrame:newTextFrame];

    _oldHeight = newHeight;

    [self.tokenTableViewController updateContentSize];


}




@end