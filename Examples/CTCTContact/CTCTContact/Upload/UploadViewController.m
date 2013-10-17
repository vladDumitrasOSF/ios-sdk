//
//  UploadViewController.m
//  CTCTContact
//
//  Created by A_Dumitras on 10/17/13.
//  Copyright (c) 2013 OSF Global. All rights reserved.
//

#import "UploadViewController.h"

#import "LoadingView.h"
#import "ActivityService.h"
#import "ListsCollection.h"
#import "CTCTGlobal.h"

@interface UploadViewController () < UITextFieldDelegate, UIPickerViewDelegate,UIPickerViewDataSource,UIGestureRecognizerDelegate>
{
    IBOutlet UIToolbar *accesoryBar;
    NSMutableArray *contactLists;
    NSMutableArray *filesArray;
    
    NSMutableArray *listsToSendToServer;
    
    ContactList *selectedList;
    LoadingView *loadingView;
}

@property (weak, nonatomic) IBOutlet UITextField *fileTextField;
@property (weak, nonatomic) IBOutlet UITextField *listsTextField;

@property (strong, nonatomic) IBOutlet UIPickerView *elementPickerView;

@end

@implementation UploadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) { }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeKeys)];
    [self.view addGestureRecognizer:tap];
    
    self.elementPickerView.delegate = self;
    self.elementPickerView.dataSource = self;
    
    filesArray = [[NSMutableArray alloc] init];
    
    self.listsTextField.delegate = self;
    self.fileTextField.delegate = self;
    
    loadingView = [[LoadingView alloc] initWithFrame:self.view.frame];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    listsToSendToServer = [[NSMutableArray alloc]init];
    
    NSError *error;
    filesArray = [[NSMutableArray alloc] init];
    NSString *documentsPath= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSArray* files= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    
    [filesArray addObject:@"select a element"];
    [filesArray addObjectsFromArray:files];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    HttpResponse *response = [ListsCollection listsWithAccessToken:[CTCTGlobal shared].token andModificationDate:nil];
    contactLists = [[NSMutableArray alloc] initWithArray:response.data];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setFileTextField:nil];
    [self setListsTextField:nil];
    [self setElementPickerView:nil];
    accesoryBar = nil;
    [super viewDidUnload];
}
- (IBAction)onRemoveUpload:(id)sender
{
    [self closeKeys];
    [loadingView showLoadingInView:self.view];
    if(self.listsTextField.text.length > 0)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:self.fileTextField.text];
        
        NSString *listsString = [self createListString];
            
        HttpResponse *response =  [ActivityService removeContactsMultipartWithToken:[CTCTGlobal shared].token withFile:filePath fromLists:listsString];
        [loadingView hideLoading];    
        if(response.statusCode != 201)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:((HttpError*)[response.errors objectAtIndex:0]).message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        else
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Upload Succesful" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];

    }
    else
    {
        [loadingView hideLoading];
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"insert at least one list to add/ remove contacts from" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

- (IBAction)onAddUpload:(id)sender
{
    [self closeKeys];
    [loadingView showLoadingInView:self.view];
    if(self.listsTextField.text.length > 0)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:self.fileTextField.text];
        
        NSString *listsString = [self createListString];
        
        HttpResponse *response =  [ActivityService addContactsMultipartWithToken:[CTCTGlobal shared].token withFile:filePath toLists:listsString];
        
        [loadingView hideLoading];
        if(response.statusCode != 201)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:((HttpError*)[response.errors objectAtIndex:0]).message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        else
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Upload Succesful" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    else
    {
        [loadingView hideLoading];
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"insert at least one list to add/ remove contacts from" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

#pragma mark - gesture recognizer
- (void)closeKeys
{
    [self.listsTextField resignFirstResponder];
    [self.fileTextField resignFirstResponder];
}

#pragma mark - picker view
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    int rows = (pickerView.tag == 1) ? contactLists.count +1 : filesArray.count;
    
    return rows;
}

- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *name = nil;
    if(pickerView.tag == 1)
    {
        if(row == 0)
            name = @"Select a list";
        else
        {
            ContactList *lis = contactLists[row -1];
            name = lis.name;
        }
    }
    
    return  (pickerView.tag == 1) ? name : filesArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(row != 0)
    {
        if(pickerView.tag == 1)
        {
            ContactList *lis = contactLists[row -1];
            selectedList = lis;
        }
        else
        {
            self.fileTextField.text = filesArray[row];
        }
    }
    else
    {
        [listsToSendToServer removeAllObjects];
        selectedList = nil;
    }
}

#pragma mark - text field
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.elementPickerView.tag = textField.tag;
    [self.elementPickerView selectRow:0 inComponent:0 animated:NO];
    [self.elementPickerView reloadAllComponents];
    
    if(textField.tag == 1)
        textField.inputAccessoryView = accesoryBar;
    
    textField.inputView = self.elementPickerView;
    [textField becomeFirstResponder];
}

- (IBAction)onAddlist:(id)sender
{
    if(selectedList)
    {
        if(![listsToSendToServer containsObject:selectedList.listId])
        {
            self.listsTextField.text =[NSString stringWithFormat:@"%@ %@",self.listsTextField.text,selectedList.name];
            [listsToSendToServer addObject:selectedList.listId];
        }
    }
    else
    {
        self.fileTextField.text = @"";
        self.listsTextField.text = @"";
        [listsToSendToServer removeAllObjects];
    }
    
    [self.view endEditing:YES];
}

- (NSString *)createListString
{
    NSString *str = @"";
    if(listsToSendToServer.count > 0)
    {
        str = [NSString stringWithFormat:@"%@",listsToSendToServer[0]];
        
        for (int i=1;i<listsToSendToServer.count;i++)
        {
             str = [NSString stringWithFormat:@"%@,%@",str,listsToSendToServer[0]];
        }
    }
    return str;
}
@end
