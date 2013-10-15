//
//  ViewController.h
//  CTCTContact
//
//  Created by Sergiu Grigoriev on 3/28/13.
//  Copyright (c) 2013 OSF Global. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ContactsCollection.h"
#import "LoadingView.h"
#import "CTCTGlobal.h"

@interface MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, readwrite) BOOL wasAdded;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)onSearch:(id)sender;

@end
