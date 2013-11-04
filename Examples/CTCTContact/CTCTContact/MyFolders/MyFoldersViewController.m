//
//  MyFoldersViewController.m
//  CTCTContact
//
//  Created by A_Dumitras on 10/31/13.
//  Copyright (c) 2013 OSF Global. All rights reserved.
//

#import "MyFoldersViewController.h"

#import "MyLibraryFoldersService.h"
#import "NewFolderViewController.h"
#import "LibrarySummary.h"
#import "LibraryFolder.h"
#import "UsageSummary.h"
#import "CTCTGlobal.h"

@interface MyFoldersViewController () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSMutableArray *tableArray;
    NSMutableArray *pickerArray;
    
    NSArray *allFolders;
    int selectedFolder;
    
    NSArray *folderCollectionSort;
    NSArray *trashSort;
    NSArray *trashType;
    
    NewFolderViewController *newFolder;
}

//collection
@property (weak, nonatomic) IBOutlet UITextField *folderCollectionSortTextField;
@property (weak, nonatomic) IBOutlet UITextField *folderCollectionLimitTextField;

//individual
@property (weak, nonatomic) IBOutlet UITextField *folderSelectionTextField;

//trash
@property (weak, nonatomic) IBOutlet UITextField *trashTypeTextField;
@property (weak, nonatomic) IBOutlet UITextField *trashSortTextField;
@property (weak, nonatomic) IBOutlet UITextField *trashLimitTextField;

@property (weak, nonatomic) IBOutlet UITableView *resultsTableView;

@property (weak, nonatomic) IBOutlet UIScrollView *containerScrollView;
@property (strong, nonatomic) IBOutlet UIView     *containerView;
@property (strong, nonatomic) IBOutlet UIPickerView *dataPicker;
@end

@implementation MyFoldersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {  }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.resultsTableView.delegate   = self;
    self.resultsTableView.dataSource = self;
    
    [self.containerScrollView addSubview:self.containerView];
    self.containerScrollView.contentSize = CGSizeMake(320, self.containerView.frame.size.height);
    
    self.folderCollectionSortTextField.delegate  = self;
    self.folderCollectionLimitTextField.delegate = self;
    self.folderSelectionTextField.delegate       = self;
    self.trashTypeTextField.delegate             = self;
    self.trashSortTextField.delegate             = self;
    self.trashLimitTextField.delegate            = self;
    
    self.dataPicker.delegate   = self;
    self.dataPicker.dataSource = self;
    selectedFolder = -1;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeKeys)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    tableArray = [[NSMutableArray alloc]init];
    pickerArray = [[NSMutableArray alloc]init];
    
    folderCollectionSort = [NSArray arrayWithObjects:@"CREATED_DATE",@"CREATED_DATE_DESC",@"MODIFIED_DATE",@"MODIFIED_DATE_DESC",@"NAME",@"NAME_DESC", nil];
    trashSort = [NSArray arrayWithObjects:@"CREATED_DATE",@"CREATED_DATE_DESC",@"MODIFIED_DATE",@"MODIFIED_DATE_DESC",@"NAME",@"NAME_DESC",@"SIZE",@"SIZE_DESC",@"DIMENSION",@"DIMENSION_DESC", nil];
    trashType = [NSArray arrayWithObjects:@"ALL",@"IMAGES",@"DOCUMENTS", nil];
    
    HttpResponse  *response = [MyLibraryFoldersService getFoldersWithAccessToken:[CTCTGlobal shared].token SortedBy:nil withALimitOf:0];
    ResultSet *set = response.data;
    allFolders = set.results;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//summary
- (IBAction)onSummary:(id)sender
{
    HttpResponse  *response = [MyLibraryFoldersService getMyLibrarySummaryInformationWithAccessToken:[CTCTGlobal shared].token];
    
    LibrarySummary *sum = response.data;
    UsageSummary *us = (UsageSummary *)sum.usageSummary;
    
    NSString *str = [NSString stringWithFormat:@"Max free files to upload: %d \r\n number of free files remaining: %d \r\n file count:%d \r\n folder count: %d \r\n",sum.maxFreeFileNum,us.freeFilesRemaining,us.fileCount,us.folderCount];
    
    [[[UIAlertView alloc]initWithTitle:@"Summary" message:str delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
}

//folder collection
- (IBAction)getFoldersAll:(id)sender
{
    NSString *limittext = self.folderCollectionLimitTextField.text.length > 0 ? self.folderCollectionLimitTextField.text : @"0";
    NSString *sortCriterya = self.folderCollectionSortTextField.text.length > 0 ? self.folderCollectionSortTextField.text : nil;
    
    HttpResponse  *response = [MyLibraryFoldersService getFoldersWithAccessToken:[CTCTGlobal shared].token SortedBy:sortCriterya withALimitOf:[limittext intValue]];
    ResultSet *set = response.data;
    NSArray *arr = set.results;
    
    [tableArray removeAllObjects];
    for (LibraryFolder *fold in arr)
    {
        [tableArray addObject:[NSString stringWithFormat:@"NAME : %@ item count: %d",fold.name,fold.itemCount]];
    }
    [self.resultsTableView reloadData];
}

- (IBAction)postFolder:(id)sender
{
    newFolder = [[NewFolderViewController alloc]init];
    
    [self.navigationController pushViewController:newFolder animated:YES];
}

//individual folder
- (IBAction)getFolder:(id)sender
{
    LibraryFolder *fold = allFolders[selectedFolder];
    HttpResponse *resp = [MyLibraryFoldersService getFolderWithAccessToken:[CTCTGlobal shared].token withId:fold.folderId];

    LibraryFolder *fold2 = resp.data;
    
    [tableArray removeAllObjects];
  
    [tableArray addObject:[NSString stringWithFormat:@"NAME : %@ item count: %d",fold2.name,fold2.itemCount]];
    
    [self.resultsTableView reloadData];
    
}

- (IBAction)updateFolder:(id)sender
{
    if(self.folderSelectionTextField.text.length > 0)
    {
        LibraryFolder *fold = allFolders[selectedFolder];
        
        newFolder = [[NewFolderViewController alloc]init];
        newFolder.updateFolder = YES;
        newFolder.folderId = fold.folderId;
        
        [self.navigationController pushViewController:newFolder animated:YES];
    }
    else
        [[[UIAlertView alloc]initWithTitle:@"" message:@"Select a folder to update" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (IBAction)deleteFolder:(id)sender
{
    LibraryFolder *fold = allFolders[selectedFolder];
    
    NSArray *error;
    BOOL deleted = [MyLibraryFoldersService deleteFolderWithAccessToken:[CTCTGlobal shared].token  andWithId:fold.folderId errors:&error];
    
    NSString *mess = deleted ? @"folder deleted" : @"error";
    
    [[[UIAlertView alloc]initWithTitle:@"" message:mess delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    
    [tableArray removeAllObjects];
    
    if(deleted)
    {
        HttpResponse  *response = [MyLibraryFoldersService getFoldersWithAccessToken:[CTCTGlobal shared].token SortedBy:nil withALimitOf:0];
        ResultSet *set = response.data;
        allFolders = set.results;
    }
    
    [self.resultsTableView reloadData];
}

// trash folder
- (IBAction)gettrashFolders:(id)sender
{
    NSString *type = (self.trashTypeTextField.text.length > 0) ? self.trashTypeTextField.text : nil;
    NSString *sort = (self.trashSortTextField.text.length > 0) ? self.trashSortTextField.text : nil;
    NSString *limittext = self.trashLimitTextField.text.length > 0 ? self.trashLimitTextField.text : @"0";
    
    HttpResponse *resp = [MyLibraryFoldersService getTrashFoldersWithAccessToken:[CTCTGlobal shared].token  withType:type sortedBy:sort withALimitOf:[limittext intValue]];
    
    ResultSet *set = resp.data;
    NSArray *arr = set.results;
    
    [tableArray removeAllObjects];
    for (LibraryFile *fil in arr)
    {
        [tableArray addObject:[NSString stringWithFormat:@"NAME : %@ source: %@",fil.name,fil.source]];
    }
    [self.resultsTableView reloadData];
}
- (IBAction)emptyTrash:(id)sender
{
    NSArray *error;
    BOOL deleted = [MyLibraryFoldersService deleteTrashFoldersWithAccessToken:[CTCTGlobal shared].token errors:&error];
    
    NSString *mess = deleted ? @"folder deleted" : @"error";
    
    [[[UIAlertView alloc]initWithTitle:@"" message:mess delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    
    [tableArray removeAllObjects];
    
    [self.resultsTableView reloadData];
}

- (void)viewDidUnload {
    [self setFolderCollectionSortTextField:nil];
    [self setFolderCollectionLimitTextField:nil];
    [self setFolderSelectionTextField:nil];
    [self setTrashTypeTextField:nil];
    [self setTrashSortTextField:nil];
    [self setTrashLimitTextField:nil];
    [self setResultsTableView:nil];
    [self setContainerScrollView:nil];
    [self setContainerView:nil];
    [self setDataPicker:nil];
    [super viewDidUnload];
}

#pragma mark - table view
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
    self.dataPicker.tag = textField.tag;
    if(textField.tag == 111)
    {
        textField.inputView = self.dataPicker;
        pickerArray = [folderCollectionSort mutableCopy];
    }
    else if(textField.tag == 222)
    {
        textField.inputView = self.dataPicker;
        pickerArray = [allFolders mutableCopy];
    }
    else if(textField.tag == 333)
    {
        textField.inputView = self.dataPicker;
        pickerArray = [trashType mutableCopy];
    }
    else if(textField.tag == 444)
    {
        textField.inputView = self.dataPicker;
        pickerArray = [trashSort mutableCopy];
    }

    [self.dataPicker reloadAllComponents];
    [self.dataPicker selectRow:0 inComponent:0 animated:NO];

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
        nr = folderCollectionSort.count;
    else if(pickerView.tag == 222)
        nr = allFolders.count;
    else if(pickerView.tag == 333)
        nr = trashType.count;
    else if(pickerView.tag == 444)
        nr = trashSort.count;
    
    return nr;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView.tag == 111)
    {
        self.folderCollectionSortTextField.text = folderCollectionSort[row];
    }
    else if(pickerView.tag == 222)
    {
        LibraryFolder *fold = allFolders[row];
        self.folderSelectionTextField.text = fold.name;
        selectedFolder = row;
    }
    else if(pickerView.tag == 333)
    {
        self.trashTypeTextField.text = trashType[row];
    }
    else if(pickerView.tag == 444)
    {
        self.trashSortTextField.text = trashSort[row];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = @"";
    if(pickerView.tag == 111)
        title = folderCollectionSort[row];
    else if(pickerView.tag == 222)
    {
        LibraryFolder *fold = allFolders[row];
        title = fold.name;
    }
    else if(pickerView.tag == 333)
        title = trashType[row];
    else if(pickerView.tag == 444)
        title = trashSort[row];
    
    return title;
}

- (void)closeKeys
{
    [self.view endEditing:YES];
}
@end
