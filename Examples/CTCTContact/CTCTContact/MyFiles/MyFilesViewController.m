//
//  MyFilesViewController.m
//  CTCTContact
//
//  Created by A_Dumitras on 11/1/13.
//  Copyright (c) 2013 OSF Global. All rights reserved.
//

#import "MyFilesViewController.h"

#import "MyLibraryFoldersService.h"
#import "MyLibraryFilesService.h"
#import "NewFileViewController.h"
#import "FileUploadStatus.h"
#import "LibraryFolder.h"
#import "LibraryFile.h"
#import "CTCTGlobal.h"
#import "FileMoved.h"

@interface MyFilesViewController () <UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIGestureRecognizerDelegate>
{
    NSMutableArray *tableArray;
    
    NSArray *fileType;
    NSArray *fileSource;
    
    NSArray *allFolders;
    NSArray *allFiles;
    
    NSMutableArray*filesArray;
    
    int selectedFolder;
    int selectedFile;
    int selectedLocalFile;
    
    NewFileViewController *newFile;
}

@property (weak, nonatomic) IBOutlet UIScrollView *containerScrollView;
@property (strong, nonatomic) IBOutlet UIView     *containerView;
@property (weak, nonatomic) IBOutlet UITableView *filesTableview;
@property (strong, nonatomic) IBOutlet UIPickerView *filesPicker;

//file collection
@property (weak, nonatomic) IBOutlet UITextField *fileCollectionTypeTextField;
@property (weak, nonatomic) IBOutlet UITextField *fileCollectionSourceTypeTextField;
@property (weak, nonatomic) IBOutlet UITextField *fileCollectionLimitTextField;
//file by folder
@property (weak, nonatomic) IBOutlet UITextField *filesByFolderLimitTextField;
@property (weak, nonatomic) IBOutlet UITextField *filesByFolderFolderTextfield;
//individual file
@property (weak, nonatomic) IBOutlet UITextField *individualFileTextfield;
// upload
@property (weak, nonatomic) IBOutlet UITextField *uploadFileTextField;
//upload status
@property (weak, nonatomic) IBOutlet UITextField *uploadStatusFileTextField;
// move
@property (weak, nonatomic) IBOutlet UITextField *moveFilesTextField;
@property (weak, nonatomic) IBOutlet UITextField *moveFilesToFileTextField;

@end

@implementation MyFilesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) { }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fileCollectionTypeTextField.delegate = self;
    self.fileCollectionSourceTypeTextField.delegate = self;
    self.fileCollectionLimitTextField.delegate = self;
   
    self.filesByFolderLimitTextField.delegate = self;
    self.filesByFolderFolderTextfield.delegate = self;
    
    self.individualFileTextfield.delegate = self;
    self.uploadFileTextField.delegate = self;
   
    self.uploadStatusFileTextField.delegate = self;
    
    self.moveFilesTextField.delegate = self;
    self.moveFilesToFileTextField.delegate = self;
    
    self.filesTableview.delegate = self;
    self.filesTableview.dataSource = self;
    
    self.filesPicker.delegate = self;
    self.filesPicker.dataSource = self;
    
    fileSource = [NSArray arrayWithObjects:@"ALL",@"MYComputer",@"StockImage",@"Facebook",@"Instagram",@"Shutterstock",@"Mobile", nil];
    fileType   = [NSArray arrayWithObjects:@"ALL",@"IMAGES",@"DOCUMENTS", nil];
    
    [self.containerScrollView addSubview:self.containerView];
    [self.containerScrollView setContentSize:CGSizeMake(320, self.containerView.frame.size.height)];
    
    tableArray = [[NSMutableArray alloc]init];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeKeys)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    HttpResponse *resp = [MyLibraryFoldersService getFoldersWithAccessToken:[CTCTGlobal shared].token SortedBy:nil withALimitOf:0];
    ResultSet *set = resp.data;
    
    allFolders = set.results;
    
    HttpResponse *resp2 = [MyLibraryFilesService getFileCollectionWithAccessToken:[CTCTGlobal shared].token type:nil source:nil withALimitOf:0];
    ResultSet *set2 = resp2.data;
    
    allFiles = set2.results;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setContainerScrollView:nil];
    [self setContainerView:nil];
    [self setFileCollectionTypeTextField:nil];
    [self setFileCollectionSourceTypeTextField:nil];
    [self setFileCollectionLimitTextField:nil];
    [self setFilesByFolderLimitTextField:nil];
    [self setFilesByFolderFolderTextfield:nil];
    [self setIndividualFileTextfield:nil];
    [self setUploadFileTextField:nil];
    [self setUploadStatusFileTextField:nil];
    [self setMoveFilesTextField:nil];
    [self setMoveFilesToFileTextField:nil];
    [self setFilesTableview:nil];
    [self setFilesPicker:nil];
    [super viewDidUnload];
}

// file collection
- (IBAction)getFiiles:(id)sender
{
    NSString *limittext = self.fileCollectionLimitTextField.text.length > 0 ? self.fileCollectionLimitTextField.text : @"0";
    NSString *type = self.fileCollectionTypeTextField.text.length > 0 ? self.fileCollectionTypeTextField.text : nil;
    NSString *source = self.fileCollectionSourceTypeTextField.text.length > 0 ? self.fileCollectionSourceTypeTextField.text : nil;
    
    HttpResponse  *response = [MyLibraryFilesService getFileCollectionWithAccessToken:[CTCTGlobal shared].token type:type source:source withALimitOf:[limittext intValue]];
    ResultSet *set = response.data;
    NSArray *arr = set.results;
    
    [tableArray removeAllObjects];
    for (LibraryFile *fil in arr)
    {
        [tableArray addObject:[NSString stringWithFormat:@"NAME : %@ source: %@",fil.name,fil.source]];
    }
    [self.filesTableview reloadData];
}
//files by folder
- (IBAction)getFilesByFolder:(id)sender
{
    NSString *limittext = self.filesByFolderLimitTextField.text.length > 0 ? self.filesByFolderLimitTextField.text : @"0";
    LibraryFolder *folder = allFolders[selectedFolder];
    
    HttpResponse  *response = [MyLibraryFilesService getFileCollectionWithAccessToken:[CTCTGlobal shared].token folderId:folder.folderId withaAimitOf:[limittext intValue]];
   
    ResultSet *set = response.data;
    NSArray *arr = set.results;
    
    [tableArray removeAllObjects];
    for (LibraryFile *fil in arr)
    {
        [tableArray addObject:[NSString stringWithFormat:@"NAME : %@ source: %@",fil.name,fil.source]];
    }
    [self.filesTableview reloadData];
}

//individual files
- (IBAction)getFile:(id)sender
{
    LibraryFile *file = allFiles[selectedFile];
    
    HttpResponse  *response = [MyLibraryFilesService getFileWithAccessToken:[CTCTGlobal shared].token andFileId:file.fileId];
    
    [tableArray removeAllObjects];
    
    LibraryFile *fil = response.data;
    
    [tableArray addObject:[NSString stringWithFormat:@"NAME : %@ source: %@",fil.name,fil.source]];
    
    [self.filesTableview reloadData];
}
- (IBAction)updateFile:(id)sender
{
    newFile = [[NewFileViewController alloc]init];
    
    LibraryFile *file = allFiles[selectedFile];
    
    newFile.fileId = file.fileId;
    [self.navigationController pushViewController:newFile animated:YES];
}
- (IBAction)deleteFile:(id)sender
{
    LibraryFile *fil = allFiles[selectedFile];
    
    NSArray *error;
    BOOL deleted = [MyLibraryFilesService deleteFileWithAccessToken:[CTCTGlobal shared].token  andFileId:fil.fileId errors:&error];
    
    NSString *mess = deleted ? @"file deleted" : @"error";
    
    [[[UIAlertView alloc]initWithTitle:@"" message:mess delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    
    [tableArray removeAllObjects];
    
    if(deleted)
    {
        HttpResponse  *response = [MyLibraryFilesService getFileCollectionWithAccessToken:[CTCTGlobal shared].token type:nil source:nil withALimitOf:0];
        ResultSet *set = response.data;
        NSArray *arr = set.results;
        
        for (LibraryFile *fil in arr)
        {
            [tableArray addObject:[NSString stringWithFormat:@"NAME : %@ source: %@",fil.name,fil.source]];
        }
    }
    
    [self.filesTableview reloadData];
}
//upload
- (IBAction)uploadFile:(id)sender
{
     NSArray *error;
    
    LibraryFolder *folder = allFolders[selectedFolder];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *selectedFileToLoad = filesArray[selectedLocalFile];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:selectedFileToLoad];
    
    
    BOOL response =  [MyLibraryFilesService addFileMultipartWithToken:[CTCTGlobal shared].token  withFile:filePath toFolder:folder.folderId withDescription:@"testing testing" fromSource:@"MYCOMPUTER" errors:&error];
        
    if(response)
    {
        HttpResponse *resp2 = [MyLibraryFilesService getFileCollectionWithAccessToken:[CTCTGlobal shared].token type:nil source:nil withALimitOf:0];
        ResultSet *set2 = resp2.data;
        
        allFiles = set2.results;
        [self.filesPicker reloadAllComponents];
        
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Upload Succesful" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    else
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

//status
- (IBAction)uploadStatus:(id)sender
{
    LibraryFile *fil = allFiles[selectedFile];
    NSArray *array = [NSArray arrayWithObjects:fil.fileId,nil];
    HttpResponse  *response = [MyLibraryFilesService getUploadStatusWithAccessToken:[CTCTGlobal shared].token forFilesInArray:array];
    
    [tableArray removeAllObjects];
    for (FileUploadStatus *fil in response.data)
    {
        [tableArray addObject:[NSString stringWithFormat:@"status : %@ desc: %@",fil.status,fil.description]];
    }
    [self.filesTableview reloadData];
}

//move
- (IBAction)moveFile:(id)sender
{
    LibraryFile *file = allFiles[selectedFile];
    LibraryFolder *folder = allFolders[selectedFolder];
    
    NSArray *array = [NSArray arrayWithObjects:file.fileId,nil];
    
    HttpResponse  *response = [MyLibraryFilesService moveFilesWithAccessToken:[CTCTGlobal shared].token toFolderWithId:folder.folderId withMoveFilesArray:array];  

    [tableArray removeAllObjects];
    for (FileMoved *fil in response.data)
    {
        [tableArray addObject:[NSString stringWithFormat:@"id : %@ uri: %@",fil.fileID,fil.uri]];
    }
    [self.filesTableview reloadData];
}


#pragma  mark - tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if(cell == nil)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    cell.textLabel.text = tableArray[indexPath.row];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Folders";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.filesPicker.tag = textField.tag;
    if(textField.tag > 0)
    {
        textField.inputView = self.filesPicker;
    }
    [self.filesPicker reloadAllComponents];
    [self.filesPicker selectRow:0 inComponent:0 animated:NO];
    
    return YES;
}

#pragma mark - data picker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    int nr = 0;
    if(pickerView.tag == 111)
    {
        nr = fileType.count;
    }
    else if(pickerView.tag == 222)
    {
        nr = fileSource.count;
    }
    else if(pickerView.tag == 333)
    {
        nr = allFolders.count;
    }
    else if(pickerView.tag == 444)
    {
        nr = allFiles.count;
    }
    else if(pickerView.tag == 555)
    {
        [self getLocalFiles];
        nr = filesArray.count;
    }
    else if(pickerView.tag == 666)
    {
        nr = allFiles.count;
    }
    return nr;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView.tag == 111)
    {
        self.fileCollectionTypeTextField.text = fileType[row];
    }
    else if(pickerView.tag == 222)
    {
        self.fileCollectionSourceTypeTextField.text = fileSource[row];
    }
    else if(pickerView.tag == 333)
    {
        LibraryFolder *fold = allFolders[row];
        self.filesByFolderFolderTextfield.text = fold.name;
        selectedFolder = row;
        self.moveFilesToFileTextField.text = fold.name;
    }
    else if(pickerView.tag == 444)
    {
        LibraryFile *fil = allFiles[row];
        self.individualFileTextfield.text = fil.name;
        selectedFile = row;
    }
    else if(pickerView.tag == 555)
    {
        selectedLocalFile = row;
        self.uploadFileTextField.text = filesArray[row];
        
    }
    else if(pickerView.tag == 666)
    {
        LibraryFile *fil = allFiles[row];
        self.uploadStatusFileTextField.text = fil.name;
        selectedFile = row;
        self.moveFilesTextField.text = fil.name;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = @"";
    if(pickerView.tag == 111)
    {
        title = fileType[row];
    }
    else if(pickerView.tag == 222)
    {
        title = fileSource[row];
    }
    else if(pickerView.tag == 333)
    {
        LibraryFolder *fold = allFolders[row];
        title = fold.name;
    }
    else if(pickerView.tag == 444)
    {
        LibraryFile *fil = allFiles[row];
        title = fil.name;
    }
    else if(pickerView.tag == 555)
    {
        title = filesArray[row];
    }
    else if(pickerView.tag == 666)
    {
        LibraryFile *fold = allFiles[row];
        title = fold.name;
    }
    return title;
}

- (void)closeKeys
{
    [self.view endEditing:YES];
}

- (void)getLocalFiles
{
    NSError *error;
    filesArray = [[NSMutableArray alloc] init];
    NSString *documentsPath= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    
    [filesArray addObjectsFromArray:files];
}
@end
