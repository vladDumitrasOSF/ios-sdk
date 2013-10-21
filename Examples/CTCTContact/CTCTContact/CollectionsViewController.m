//
//  CollectionsViewController.m
//  CTCTContact
//
//  Created by A_Dumitras on 10/14/13.
//  Copyright (c) 2013 OSF Global. All rights reserved.
//

#import "CollectionsViewController.h"

#import "ContactsCollection.h"
#import "ListsCollection.h"
#import "EmailCampaignService.h"
#import "LoadingView.h"
#import "CTCTGlobal.h"
#import "ResultSet.h"

@interface CollectionsViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSString        *status;
    int             selectedCall;
    int             selectedList;
    NSArray         *resultsArray;
    NSDateFormatter *dateFormat;
    
    NSMutableArray  *listArray;
    NSMutableArray  *contactListArray;
    
    LoadingView *loadingView;
}

typedef enum
{
    CONTACT_CALL = 1,
    LIST_CALL = 2,
    EMAIL_CALL = 3,
    MEMBERSHIP_CALL = 4
}CALL_ENUM;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *statusLable;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *listTextField;
@property (strong, nonatomic) IBOutlet UIPickerView *listPicker;

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *activeBtn;
@property (weak, nonatomic) IBOutlet UIButton *unconfBtn;
@property (weak, nonatomic) IBOutlet UIButton *outputBtn;
@property (weak, nonatomic) IBOutlet UIButton *removedBtn;
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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.textField.delegate = self;
    self.listTextField.delegate = self;
    self.dateTextField.delegate = self;
    
    self.listPicker.dataSource = self;
    self.listPicker.delegate = self;
    
    resultsArray = [[NSArray alloc]init];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(CloseKeys)];
    [self.view addGestureRecognizer:tap];
    
    loadingView = [[LoadingView alloc]initWithFrame:self.view.frame];
    
    dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    selectedCall = 0;
    
    listArray = [[NSMutableArray alloc]initWithObjects:@"Select a list", nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_queue_t callService = dispatch_queue_create("callService", nil);
    dispatch_async(callService, ^{
        
        HttpResponse *response = [ListsCollection listsWithAccessToken:[CTCTGlobal shared].token andModificationDate:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            contactListArray = [NSArray arrayWithArray:response.data];
            
            for(ContactList *list in response.data)
            {
                [listArray addObject:list.name];
            }
            
            [self.listPicker selectRow:0 inComponent:0 animated:NO];
            [self.listPicker reloadAllComponents];
                   });
    });
    dispatch_release(callService);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setStatusLable:nil];
    [self setTextField:nil];
    [self setDateTextField:nil];
    [self setDatePicker:nil];
    [self setActiveBtn:nil];
    [self setUnconfBtn:nil];
    [self setOutputBtn:nil];
    [self setRemovedBtn:nil];
    [self setListTextField:nil];
    [self setListPicker:nil];
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
   
    if(selectedCall == CONTACT_CALL || selectedCall == 0 || selectedCall == MEMBERSHIP_CALL)
    {
    Contact *cont = resultsArray[indexPath.row];
    
    cell.textLabel.text =[NSString stringWithFormat:@"%@ %@",cont.firstName,cont.lastName];
    }
    else if(selectedCall == LIST_CALL)
    {
        ContactList *cont = resultsArray[indexPath.row];
        
        cell.textLabel.text =[NSString stringWithFormat:@"%@ %@",cont.name,cont.status];
    }
    else if(selectedCall == EMAIL_CALL)
    {
        EmailCampaign *cont = resultsArray[indexPath.row];
        
        cell.textLabel.text =[NSString stringWithFormat:@"%@ %@",cont.name,cont.status];
    }
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
    selectedCall = 0;
    self.statusLable.text = status;
    self.dateTextField.text = @"";
    [loadingView showLoadingInView:self.view];
    dispatch_queue_t callService = dispatch_queue_create("callService", nil);
    dispatch_async(callService, ^{
        
        HttpResponse *response = nil;
        if(self.textField.text.length > 0)
            response = [ContactsCollection contactsWithAccessToken:[CTCTGlobal shared].token andStatus:status withAlimitOf:[self.textField.text intValue]];
        else 
            response = [ContactsCollection contactsWithAccessToken:[CTCTGlobal shared].token andStatus:status withAlimitOf:0];
        
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField.tag == 1)
    {
        textField.inputView = self.datePicker;
        self.dateTextField.text = [dateFormat stringFromDate:[self.datePicker date]];
        self.textField.text = @"";
        
        self.activeBtn.enabled = NO;
        self.unconfBtn.enabled = NO;
        self.outputBtn.enabled = NO;
        self.removedBtn.enabled = NO;
    }
    if(textField.tag == 2)
    {
        textField.inputView = self.listPicker;
        self.textField.text = @"";
        
        self.activeBtn.enabled = NO;
        self.unconfBtn.enabled = NO;
        self.outputBtn.enabled = NO;
        self.removedBtn.enabled = NO;
    }
    
    self.dateTextField.text = @"";
    self.activeBtn.enabled = YES;
    self.unconfBtn.enabled = YES;
    self.outputBtn.enabled = YES;
    self.removedBtn.enabled = YES;
}
- (IBAction)onSelectedDate:(id)sender
{
    self.dateTextField.text = [dateFormat stringFromDate:[self.datePicker date]];  
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 1 && textField.text.length > 0)
    {
        [self callForDate];
    }
}

- (IBAction)contactDate:(id)sender
{
    selectedCall = CONTACT_CALL;
    
    if(self.dateTextField.text.length > 0)
    {
        [self callForDate];
    }
    else
    {
        [self callForLimit];
    }
}

- (IBAction)listDate:(id)sender
{
    selectedCall = LIST_CALL;
    if(self.dateTextField.text.length > 0)
    {
        [self callForDate];
    }
    else
    {
        [self callForLimit];
    }
}

- (IBAction)EmailCampaignDate:(id)sender
{
    selectedCall = EMAIL_CALL;
    if(self.dateTextField.text.length > 0)
    {
        [self callForDate];
    }
    else
    {
        [self callForLimit];
    }
}

- (IBAction)membershipDate:(id)sender
{
    selectedCall = MEMBERSHIP_CALL;
    if( self.listTextField.text.length > 0)
    {
        if(self.dateTextField.text.length > 0)
        {
     
            [self callForDate];
        }
        else
        {
            [self callForLimit];
        }
    }
    else
        [[[UIAlertView alloc]initWithTitle:nil message:@"For membership lists a list must be selected" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - call for parameters
- (void)callForDate
{
    [self.view endEditing:YES];
    self.statusLable.text = status;
    [loadingView showLoadingInView:self.view];
    dispatch_queue_t callService = dispatch_queue_create("callService", nil);
    dispatch_async(callService, ^{
        
        HttpResponse *response = nil;
        
        switch (selectedCall) {
            case CONTACT_CALL: response = [ContactsCollection contactsWithAccessToken:[CTCTGlobal shared].token andModifiedSince:[self.datePicker date]];
                break;
            case LIST_CALL: response = [ListsCollection listsWithAccessToken:[CTCTGlobal shared].token andModificationDate:[self.datePicker date]];
                break;
                
            case EMAIL_CALL: response = [EmailCampaignService getCampaignsWithToken:[CTCTGlobal shared].token modificationDate:[self.datePicker date]];
                break;
                
            case MEMBERSHIP_CALL:
            {
                ContactList *list = contactListArray[selectedList - 1];
                
                response = [ListsCollection getContactListMembershipWithAccessToken:[CTCTGlobal shared].token fromList:list.listId withModificationDate:[self.datePicker date] withAlimitOf:0];
                break;
            }
            default: break;
        }
      
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [loadingView hideLoading];
            if(selectedCall != LIST_CALL)
            {
                ResultSet *set = response.data;
                resultsArray = set.results;
            }
            else
                resultsArray = response.data;
            
            if(response.errors.count > 0)
            {
                HttpError *err = [response.errors objectAtIndex:0];
                [[[UIAlertView alloc] initWithTitle:@"Error" message:err.message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }
            else if(resultsArray.count == 0)
                [[[UIAlertView alloc]initWithTitle:@"" message:@"No Results match this criteria" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            
            [self.tableView reloadData];
        });
    });
    dispatch_release(callService);
}

- (void)callForLimit
{
    [self.view endEditing:YES];
    self.statusLable.text = status;
    [loadingView showLoadingInView:self.view];
    dispatch_queue_t callService = dispatch_queue_create("callService", nil);
    dispatch_async(callService, ^{
        
        HttpResponse *response = nil;
        
        switch (selectedCall) {
            case CONTACT_CALL: response = [ContactsCollection contactsWithAccessToken:[CTCTGlobal shared].token withLimitOf:[self.textField.text intValue]];
                break;
                
            case EMAIL_CALL: response = [EmailCampaignService getCampaignsWithToken:[CTCTGlobal shared].token withALimitOf:[self.textField.text intValue]];
                break;
                
            case MEMBERSHIP_CALL:
            {
                ContactList *list = contactListArray[selectedList - 1];
                response = [ListsCollection getContactListMembershipWithAccessToken:[CTCTGlobal shared].token fromList:list.listId withModificationDate:nil withAlimitOf:[self.textField.text intValue]];
                break;
            }
            default:break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [loadingView hideLoading];
            ResultSet *set = response.data;
            resultsArray = set.results;
            
            if(response.errors.count > 0)
            {
                HttpError *err = [response.errors objectAtIndex:0];
                [[[UIAlertView alloc] initWithTitle:@"Error" message:err.message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }
            else if(resultsArray.count == 0)
                [[[UIAlertView alloc]initWithTitle:@"" message:@"No Results match this criteria" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            
            [self.tableView reloadData];
        });
    });
    dispatch_release(callService);
}

#pragma mark - picker view
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return listArray[row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return listArray.count;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.listTextField.text = listArray[row];
    selectedList = row;
}
@end
