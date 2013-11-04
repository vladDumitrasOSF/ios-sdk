//
//  NewFileViewController.m
//  CTCTContact
//
//  Created by A_Dumitras on 11/1/13.
//  Copyright (c) 2013 OSF Global. All rights reserved.
//

#import "NewFileViewController.h"

#import "MyLibraryFilesService.h"
#import "MyLibraryFoldersService.h"
#import "LibraryFile.h"
#import "CTCTGlobal.h"

@interface NewFileViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>
{
    NSArray *folders;
    int selectedElement;
}

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *parrentTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;

@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UIButton *addUpdateButton;
@end

@implementation NewFileViewController

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
    self.descriptionTextField.delegate = self;
    self.parrentTextField.userInteractionEnabled = NO;
    
    folders = [[NSArray alloc]init];
    selectedElement = -1;
    
    [self.addUpdateButton setTitle:@"Update" forState:UIControlStateNormal];
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
    [self setDescriptionTextField:nil];
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
    LibraryFile *file = (LibraryFile *)folders[row];
    return  file.name;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    LibraryFile *fold = (LibraryFile *)folders[row];
    self.parrentTextField.text = fold.name;
    selectedElement = row;
}
- (IBAction)update:(id)sender
{
    if(self.titleTextField.text.length > 0 )
    {
        LibraryFile *fil = [[LibraryFile alloc] init];
        fil.name = self.titleTextField.text;
        fil.description = self.descriptionTextField.text;
        
        LibraryFolder *fold2 = (LibraryFolder *)folders[selectedElement];
        fil.folderId = fold2.folderId;
        
        HttpResponse *resp = [MyLibraryFilesService updateFileWithAccessToken:[CTCTGlobal shared].token fileId:self.fileId includePayload:YES andFile:fil];
            
        if(resp.errors.count == 0)
            [[[UIAlertView alloc] initWithTitle:@"added" message:@"File updated" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        else
            [[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end

