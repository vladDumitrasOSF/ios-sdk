//
//  CollectionsViewController.m
//  CTCTContact
//
//  Created by A_Dumitras on 10/14/13.
//  Copyright (c) 2013 OSF Global. All rights reserved.
//

#import "CollectionsViewController.h"

#import "ContactsCollection.h"
#import "LoadingView.h"
#import "CTCTGlobal.h"
#import "ResultSet.h"

@interface CollectionsViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    NSString *status;
    NSArray *resultsArray;
    
    LoadingView *loadingView;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *statusLable;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation CollectionsViewController
- (IBAction)removed:(id)sender
{
    status = @"REMOVED";
    [self startCall];
}
- (IBAction)optout:(id)sender
{
     status = @"OPTOUT";
     [self startCall];
}
- (IBAction)unconfirmed:(id)sender
{
     status = @"UNCONFIRMED";
     [self startCall];
}
- (IBAction)active:(id)sender
{
     status = @"ACTIVE";
    [self startCall];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.textField.delegate = self;
    
    resultsArray = [[NSArray alloc]init];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(CloseKeys)];
    [self.view addGestureRecognizer:tap];
    
    loadingView = [[LoadingView alloc]initWithFrame:self.view.frame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setStatusLable:nil];
    [self setTextField:nil];
    [super viewDidUnload];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return resultsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell == nil)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    Contact *cont = resultsArray[indexPath.row];
    
    cell.textLabel.text =[NSString stringWithFormat:@"%@ %@",cont.firstName,cont.lastName];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Collection Results";
}

- (void)startCall
{
   self.statusLable.text = status;
    [loadingView showLoadingInView:self.view];
    dispatch_queue_t callService = dispatch_queue_create("callService", nil);
    dispatch_async(callService, ^{
        
        HttpResponse *response = [ContactsCollection contactsWithAccessToken:[CTCTGlobal shared].token andStatus:status withAlimitOf:self.textField.text];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [loadingView hideLoading];
            ResultSet *set = response.data;
            resultsArray = set.results;
            
            if(resultsArray.count == 0)
                [[[UIAlertView alloc]initWithTitle:@"" message:@"No Results match this criteria" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            
            [self.tableView reloadData];           
        });
    });
    dispatch_release(callService);
}

- (void)CloseKeys
{
    [self.view endEditing:YES];
}
@end
