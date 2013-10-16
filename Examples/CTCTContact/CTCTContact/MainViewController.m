//
//  ViewController.m
//  CTCTContact
//
//  Created by Sergiu Grigoriev on 3/28/13.
//  Copyright (c) 2013 OSF Global. All rights reserved.
//

#import "MainViewController.h"
#import "CTCTLoginViewController.h"
#import "ContactsCollection.h"
#import "LoadingView.h"
#import "ContactViewController.h"
#import "CTCTGlobal.h"
#import "VerifiedEmailAddresses.h"

#import "ActivityService.h"
#import "CollectionsViewController.h"

@interface MainViewController () <CTCTLoginDelegate, UIActionSheetDelegate, UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>
{
    NSMutableArray *filesArray;
    NSString       *selectedFile;
    
    CollectionsViewController *contCol;
}

@property (nonatomic, strong) NSArray               *contacts;
@property (nonatomic, strong) LoadingView           *loadingView;
@property (nonatomic, strong) ContactViewController *contactVC;
@property (nonatomic, readwrite) BOOL               addContact;

// upload view
@property (strong, nonatomic) IBOutlet UIView     *uploadView;
@property (weak, nonatomic) IBOutlet UIPickerView *filePicker;
@property (weak, nonatomic) IBOutlet UIButton     *addRemoveButton;
@property (weak, nonatomic) IBOutlet UITextField  *listTextField;

@end

@implementation MainViewController

@synthesize wasAdded = _wasAdded;
@synthesize emailTextField = _emailTextField;
@synthesize tableView = _tableView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Contacts";
    self.loadingView = [[LoadingView alloc] initWithFrame:self.view.frame];
        
    self.contactVC = [[ContactViewController alloc] initWithNibName:@"ContactViewController" bundle:nil];
    self.contactVC.mainViewController = self;
    self.addContact = NO;
    
    self.filePicker.delegate = self;
    self.filePicker.dataSource = self;
     filesArray = [[NSMutableArray alloc] init];
    
    self.listTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSError *error;
    filesArray = [[NSMutableArray alloc] init];
    NSString *documentsPath= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSArray* files= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    
     [filesArray addObject:@"select a file"];
    for (NSString* file in files) {
        [filesArray addObject:file];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
    [self updateNavbar];
    
    if ([CTCTGlobal shared].token.length == 0)
    {
        CTCTLoginViewController *loginViewController = [[CTCTLoginViewController alloc] init];
        loginViewController.delegate = self;
        
#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 60000)
        [self presentViewController:loginViewController animated:YES completion:nil];
#else
        [self presentModalViewController:loginViewController animated:YES];
#endif
    }
    
    else if (self.wasAdded)
    {
        [self onSearch:nil];
        self.wasAdded = NO;
    }
}

- (void)viewDidUnload
{
    [self setEmailTextField:nil];
    [self setTableView:nil];
    
    [self setUploadView:nil];
    [self setFilePicker:nil];
    [self setAddRemoveButton:nil];
    [self setListTextField:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    [self setEmailTextField:nil];
    [self setTableView:nil];
}

#pragma mark - IB
- (IBAction)onSearch:(id)sender
{
  //   HttpResponse *resp = [ActivityService getStatusReportForLast50Activites:[CTCTGlobal shared].token];
   // HttpResponse *resp = [ActivityService getActivityWithToken:[CTCTGlobal shared].token status:@"COMPLETE" andType:@"ADD_CONTACTS"];
   // HttpResponse *response =  [ActivityService addContactsMultipartWithToken:[CTCTGlobal shared].token file:@"salut.txt" toLists:@"1"];
  //  NSLog(@"DADA :%d",resp.statusCode);
    //HttpResponse *response =  [ActivityService removeContactsMultipartWithToken:[CTCTGlobal shared].token withFileName:@"salut.txt" fromLists:@"1"]; //
  //  HttpResponse *response =  [ContactsCollection contactsWithAccessToken:[CTCTGlobal shared].token andStatus:@"active"];
  //   HttpResponse *response =  [ContactsCollection contactsWithAccessToken:[CTCTGlobal shared].token andModifiedSince:[NSDate date]];
  //  HttpResponse *response =  [ContactsCollection contactsWithAccessToken:[CTCTGlobal shared].token andEmail:@"dumitras.rm.vlad@gmail.com" withALimitOf:@"10"];
    
    if (self.emailTextField.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter email" message:@"Email address cannot be empty" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else if (![self isValidEmail:self.emailTextField.text])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid email" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self showLoading];
        [self.emailTextField resignFirstResponder];
        
        dispatch_queue_t callService = dispatch_queue_create("callService", nil);
        dispatch_async(callService, ^{
            
            HttpResponse *response =  [ContactsCollection contactsWithAccessToken:[CTCTGlobal shared].token andEmail:self.emailTextField.text withALimitOf:nil];
            
            if(response.statusCode != 200)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:((HttpError*)[response.errors objectAtIndex:0]).message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                self.contacts = response.data;
                if (self.contacts.count == 0)
                    self.addContact = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
                [self hideLoading];
                
            });
        });
        dispatch_release(callService);

    }
}
- (IBAction)onAddRemove:(UIButton *)sender
{
    if(self.listTextField.text.length > 0)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:selectedFile];
        
        if([sender.titleLabel.text isEqualToString:@"Add"])
        {
           HttpResponse *response =  [ActivityService addContactsMultipartWithToken:[CTCTGlobal shared].token withFile:filePath toLists:self.listTextField.text];
            if(response.statusCode != 201)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:((HttpError*)[response.errors objectAtIndex:0]).message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Upload Succesful" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }
        else
        {
            HttpResponse *response =  [ActivityService removeContactsMultipartWithToken:[CTCTGlobal shared].token withFile:filePath fromLists:self.listTextField.text];
            if(response.statusCode != 201)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:((HttpError*)[response.errors objectAtIndex:0]).message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Upload Succesful" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"insert at least one list to add/ remove contacts from" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    [self hideLoading];
    [self.uploadView removeFromSuperview];
}

#pragma mark - CTCTLogin delegate

- (void)loginViewController:(CTCTLoginViewController *)loginViewController didLoginWithAccessToken:(NSString *)accessToken
{
    [CTCTGlobal shared].token = accessToken;
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"token"];
    
#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 60000)
        [self dismissViewControllerAnimated:YES completion:nil];
#else
        [self dismissModalViewControllerAnimated:YES];
#endif
    
    [self showLoading];
    
    dispatch_queue_t callService = dispatch_queue_create("callService", nil);
    dispatch_async(callService, ^{
        
        
        HttpResponse *response = [VerifiedEmailAddresses getEmailAddresses:accessToken andConfirmedStatus:@"CONFIRMED"];
        
        if(response.statusCode != 200)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:((HttpError*)[response.errors objectAtIndex:0]).message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            NSArray *verifiedEmails = response.data;
            EmailAddress *vEmail = [verifiedEmails objectAtIndex:0];
            [CTCTGlobal shared].email = vEmail.emailAddress;
            
            [[NSUserDefaults standardUserDefaults] setObject:vEmail.emailAddress forKey:@"email"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self hideLoading];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        });
    });

}

- (void)loginViewControllerDidCancelAuthentication:(CTCTLoginViewController *)loginViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginViewControllerDidDeniedAccess:(CTCTLoginViewController *)loginViewController
{
    [loginViewController reloadLogin];
}

#pragma mark - UITableView delegate and dataSource

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Contacts";
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.addContact)
        return 1;
    
    return self.contacts.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactCell"];
    }
    
    if (self.contacts.count > 0)
    {
        Contact *contact = [self.contacts objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
        cell.detailTextLabel.text = contact.status;
    }
    else
    {
        cell.textLabel.text = @"Add contact";
        cell.detailTextLabel.text = self.emailTextField.text;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    Contact *contact = nil;
    
    if (self.contacts.count > 0)
    {
        contact = [self.contacts objectAtIndex:indexPath.row];
    }
    else
    {
        contact = [[Contact alloc] init];
        EmailAddress *emailAddress = [[EmailAddress alloc] initWithEmailAddress:self.emailTextField.text];
        [contact.emailAddresses addObject:emailAddress];
       
        if (self.contactVC.listsVC && self.contactVC.listsVC.selectedLists.count > 0)
            [self.contactVC.listsVC.selectedLists removeAllObjects];
        
        if (self.contactVC.customFieldsVC)
            [self.contactVC.customFieldsVC clearAll];
        
        self.addContact = NO;
    }
    
    self.contactVC.contactToEdit = contact;

    [self.navigationController pushViewController:self.contactVC animated:YES];
}

#pragma mark - Loading

- (void)showLoading
{
    [self.loadingView showLoadingInView:self.view];
}

- (void)hideLoading
{
    [self.loadingView hideLoading];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Utilities

- (BOOL)isValidEmail:(NSString *)emailString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailString];
}

- (void)updateNavbar
{
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithTitle:@"Bulk activites" style:UIBarButtonItemStylePlain target:self action:@selector(upload)];
    leftBtn.title = @"Upload File";
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"Bulk activites" style:UIBarButtonItemStylePlain target:self action:@selector(collections)];
    leftBtn.title = @"Collection status";
    self.navigationItem.leftBarButtonItem = leftBtn;
    self.navigationItem.rightBarButtonItem = rightBtn;
}

- (void)collections
{
    contCol = [[CollectionsViewController alloc]init];
    
    [self.navigationController pushViewController:contCol animated:YES];
}
#pragma mark - upload 

- (void)upload
{
    [[[UIActionSheet alloc]initWithTitle:@"Bulk Activites" delegate:self cancelButtonTitle:@"Cance" destructiveButtonTitle:nil otherButtonTitles:@"Add contacts from file",@"Remove contacts from file", nil] showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != 2)
    {
        [self showLoading];
        self.uploadView.frame = CGRectMake(0, 0, 320, self.uploadView.frame.size.height);
        [self.view addSubview:self.uploadView];
        [self.listTextField becomeFirstResponder];
    }
    
    if (buttonIndex == 0)
        [self.addRemoveButton setTitle:@"Add" forState:UIControlStateNormal];
    else
        [self.addRemoveButton setTitle:@"Remove" forState:UIControlStateNormal];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(row != 0)
    {
        selectedFile = filesArray[row];
    }
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return filesArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return filesArray[row];
}

@end
