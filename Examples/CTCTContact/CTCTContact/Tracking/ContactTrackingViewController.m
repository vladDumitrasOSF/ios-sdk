//
//  ContactTrackingViewController.m
//  CTCTContact
//
//  Created by A_Dumitras on 10/16/13.
//  Copyright (c) 2013 OSF Global. All rights reserved.
//

#import "ContactTrackingViewController.h"

#import "ContactTrackingService.h"
#import "ContactsCollection.h"
#import "CTCTGlobal.h"
#import "ResultSet.h"

@interface ContactTrackingViewController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>
{
    NSMutableArray  *activityResponseArray;
    
    NSMutableArray  *activityArray;
    NSMutableArray  *contactsArray;
    NSDateFormatter *dateFormat;
    
    HttpResponse *responseContacts;
}

@property (weak, nonatomic) IBOutlet UITableView *trackingTableView;

@property (strong, nonatomic) IBOutlet UIPickerView *dataPickerView;
@property (strong, nonatomic) IBOutlet UIDatePicker *timePickerView;

@property (weak, nonatomic) IBOutlet UITextField *limitTextField;
@property (weak, nonatomic) IBOutlet UITextField *crationDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *contactTextField;
@property (weak, nonatomic) IBOutlet UITextField *activityTextField;

@end

@implementation ContactTrackingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) { }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeKeys)];
    [self.view addGestureRecognizer:tapView];
    
    [self customizeViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setTrackingTableView:nil];
    [self setDataPickerView:nil];
    [self setTimePickerView:nil];
    [self setLimitTextField:nil];
    [self setCrationDateTextField:nil];
    [self setContactTextField:nil];
    [self setActivityTextField:nil];
    [super viewDidUnload];
}

- (void)customizeViews
{
    self.limitTextField.delegate       = self;
    self.crationDateTextField.delegate = self;
    self.contactTextField.delegate     = self;
    self.activityTextField.delegate    = self;
    
    activityArray = [[NSMutableArray alloc] initWithObjects:@"Select Activity",@"All Activites",@"Click",@"Forward",@"Send",@"Open",@"Unsubscribes", nil];
    contactsArray = [[NSMutableArray alloc] initWithObjects:@"Select Contact", nil];
    
    activityResponseArray = [[NSMutableArray alloc] init];
    
    responseContacts = [ContactsCollection contactsWithAccessToken:[CTCTGlobal shared].token withLimitOf:nil];
    
    for (Contact *cont in responseContacts.data)
    {
        [contactsArray addObject:[NSString stringWithFormat:@"%@ %@",cont.firstName,cont.lastName]];
    }
    
    dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
}

#pragma mark - text field
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.dataPickerView selectRow:0 inComponent:0 animated:NO];
    
    if(textField.tag < 2 )
    {
        self.dataPickerView.tag = textField.tag;
        textField.inputView = self.dataPickerView;
    }
    else if (textField.tag == 2)
    {
        self.limitTextField.text = @"";
        NSString *dateString = [dateFormat stringFromDate:[self.timePickerView date]];
        
        self.crationDateTextField.text = dateString;
        textField.inputView = self.timePickerView;
    }
    else if (textField.tag == 3)
    {
        self.crationDateTextField.text = @"";
    }
    
    [self.dataPickerView reloadAllComponents];
}

#pragma mark - gesture recognizer
- (void)closeKeys
{
    [self.view endEditing:YES];
}
#pragma mark - picker view
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    int rows = pickerView.tag == 0 ? activityArray.count : contactsArray.count;
    
    return rows;
}

- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = pickerView.tag == 0 ? activityArray[row] : contactsArray[row];
    
  return title;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
  if(pickerView.tag == 0)
      self.activityTextField.text = activityArray[row];
  else
      self.contactTextField.text = contactsArray[row];

    if(row == 0)
    {
        self.activityTextField.text = @"";
        self.contactTextField.text = @"";
    }
    
}
- (IBAction)dateChanged:(id)sender
{
    NSString *dateString = [dateFormat stringFromDate:[self.timePickerView date]];
    
    self.crationDateTextField.text = dateString;
}

#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return activityResponseArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identify = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
    }
    cell.textLabel.text = activityResponseArray[indexPath.row];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Activities";
}
#pragma mark - button actions
- (IBAction)onTrack:(id)sender
{
    BOOL ERROR = NO;
    
    [self.view endEditing:YES];
    NSUInteger index = [activityArray indexOfObject:self.activityTextField.text];

    if(index > 0 && self.contactTextField.text.length > 0)
    {
       HttpResponse *response = nil;
       ResultSet *set = nil;
        
       NSUInteger indexContact = [contactsArray indexOfObject:self.contactTextField.text];
       Contact *cont = responseContacts.data[indexContact];
       NSDate *time = (self.crationDateTextField.text.length > 0) ? self.timePickerView.date : nil;
        
      NSString *message = @"";
        
      [activityResponseArray removeAllObjects];
        switch (index)
        {
            case 1:{ response = [ContactTrackingService getAllContactActivitesWithAccessToken:[CTCTGlobal shared].token contactId:cont.contactId creationDate:time andALimitOf:self.limitTextField.text];
                
                if(response.errors.count > 0)
                {
                    ERROR = YES;
                }
                
                set = response.data;
                for (AllActivites *act in set.results)
                {
                    [activityResponseArray addObject:[NSString stringWithFormat:@"type:%@ campaignID: %@",act.activityType,act.campaignId]];
                }
            }
            break;
                
            case 2:{ response = [ContactTrackingService getClicksWithAccessToken:[CTCTGlobal shared].token contactId:cont.contactId creationDate:time andALimitOf:self.limitTextField.text];
                
                if(response.errors.count > 0)
                {
                    ERROR = YES;
                }
                
                set = response.data;
                for (ClickActivity *act in set.results)
                {
                    [activityResponseArray addObject:[NSString stringWithFormat:@"date:%@",act.clickDate]];
                }
            }
            break;
                
            case 3:{ response = [ContactTrackingService getForwardsWithAccessToken:[CTCTGlobal shared].token contactId:cont.contactId creationDate:time andALimitOf:self.limitTextField.text];
                
                if(response.errors.count > 0)
                {
                    ERROR = YES;
                }
                
                set = response.data;
                for (ForwardActivity *act in set.results)
                {
                    [activityResponseArray addObject:[NSString stringWithFormat:@"date:%@",act.forwardDate]];
                }
            }
                break;
                
            case 4:{ response = [ContactTrackingService getSendsWithAccessToken:[CTCTGlobal shared].token contactId:cont.contactId creationDate:time andALimitOf:self.limitTextField.text];
               
                if(response.errors.count > 0)
                {
                    ERROR = YES;
                }
                
               set = response.data;
                for (SendActivity *act in set.results)
                {
                    [activityResponseArray addObject:[NSString stringWithFormat:@"date:%@",act.sendDate]];
                }
            }
                break;
            case 5:{ response = [ContactTrackingService getOpensWithAccessToken:[CTCTGlobal shared].token contactId:cont.contactId creationDate:time andALimitOf:self.limitTextField.text];
                
                if(response.errors.count > 0)
                {
                    ERROR = YES;
                }
                
                set = response.data;
                for (OpenActivity *act in set.results)
                {
                    [activityResponseArray addObject:[NSString stringWithFormat:@"date:%@",act.openDate]];
                }
            }
                break;
                
            case 6:{ response = [ContactTrackingService getUnsubscribesWithAccessToken:[CTCTGlobal shared].token contactId:cont.contactId creationDate:time andALimitOf:self.limitTextField.text];
                
                if(response.errors.count > 0)
                {
                    ERROR = YES;
                }
                
                set = response.data;
                for (OptOutActivity *act in set.results)
                {
                    [activityResponseArray addObject:[NSString stringWithFormat:@"date:%@",act.unsubscribeDate]];
                }
            }
                break;
            default: break;
        }
        [self.trackingTableView reloadData];
        
        if(activityResponseArray.count == 0)
         [[[UIAlertView alloc] initWithTitle:@"" message: @"No entries with the selected filters" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        else if(ERROR)
                [[[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
    else
        [[[UIAlertView alloc]initWithTitle:@"" message:@"Select at least a activity and a client" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

@end
