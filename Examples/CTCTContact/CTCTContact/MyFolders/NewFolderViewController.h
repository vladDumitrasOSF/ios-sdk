//
//  NewFolderViewController.h
//  CTCTContact
//
//  Created by A_Dumitras on 11/1/13.
//  Copyright (c) 2013 OSF Global. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewFolderViewController : UIViewController

@property (readwrite, nonatomic) BOOL updateFolder;
@property (strong, nonatomic) NSString *folderId;

@end