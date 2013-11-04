//
//  NewFolderViewController.m
//  CTCTContact
//
//  Created by A_Dumitras on 11/1/13.
//  Copyright (c) 2013 OSF Global. All rights reserved.
//

#import "NewFolderViewController.h"

#import "MyLibraryFoldersService.h"
#import "LibraryFolder.h"
#import "CTCTGlobal.h"

@interface NewFolderViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>
{
    NSArray *folders;
    int selectedElement;
}

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *parrentTextField;

@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UIButton *addUpdateButton;

@end

@implementation NewFolderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) { }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
    self.titleTextField.delegate = self;
    self.parrentTextField.userInteractionEnabled = NO;
    
    folders = [[NSArray alloc]init];
    selectedElement = -1;
    
    if(self.updateFolder)
       [self.addUpdateButton setTitle:@"Update" forState:UIControlStateNormal];
    else
       [self.addUpdateButton setTitle:@"Add" forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated
{
    HttpResponse *resp = [MyLibraryFoldersService getFoldersWithAccessToken:[CTCTGlobal shared].token SortedBy:nil withALimitOf:0];
    ResultSet *set = resp.data;
    
    folders = set.results;
    [self.picker reloadAllComponents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setTitleTextField:nil];
    [self setParrentTextField:nil];
    [self setPicker:nil];
    [self setAddUpdateButton:nil];
    [super viewDidUnload];
}

#pragma mark - picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return folders.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    LibraryFolder *fold = (LibraryFolder *)folders[row];
    return  fold.name;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    LibraryFolder *fold = (LibraryFolder *)folders[row];
    self.parrentTextField.text = fold.name;
    selectedElement = row;
}

- (IBAction)addFolder:(id)sender
{
    if(self.titleTextField.text.length > 0 )
    {
        LibraryFolder *fold = [[LibraryFolder alloc] init];
        fold.name = self.titleTextField.text;
        
        if(self.parrentTextField.text.length > 0)
        {
            LibraryFolder *fold2 = (LibraryFolder *)folders[selectedElement];
            
            fold.parrentId = fold2.folderId;
            HttpResponse *resp = nil;
            if(self.updateFolder)
            {
                resp = [MyLibraryFoldersService updateFolderWithAccessToken:[CTCTGlobal shared].token  withId:self.folderId withUpdateFolder:fold includePayload:YES];
            }
            else
            {
               resp = [MyLibraryFoldersService addFolderWithAccessToken:[CTCTGlobal shared].token andFolder:fold];
            }
           
            
            if(resp.errors.count == 0)
                [[[UIAlertView alloc] initWithTitle:@"added" message:@"Folder added" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            else
                [[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        }
        else
        {
            HttpResponse *resp = nil;
            if(!self.updateFolder)
            {
                fold.parrentId = @"0";
                resp = [MyLibraryFoldersService addFolderWithAccessToken:[CTCTGlobal shared].token andFolder:fold];
            }
            else
            {
                fold.parrentId = @"0";
                resp = [MyLibraryFoldersService updateFolderWithAccessToken:[CTCTGlobal shared].token  withId:self.folderId withUpdateFolder:fold includePayload:NO];
            }
            
            if(resp.errors.count == 0)
                [[[UIAlertView alloc] initWithTitle:@"added" message:@"Folder added with no parrent" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            else
                [[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
      [[[UIAlertView alloc] initWithTitle:@"added" message:@"Add at least a name to the folder" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
