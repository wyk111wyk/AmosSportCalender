//
//  ConflictTV.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/8/30.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "ConflictTV.h"
#import "CommonMarco.h"

@interface ConflictTV ()

@end

@implementation ConflictTV
@synthesize documentName, documentVersions;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    documentVersions = [[iCloud sharedCloud] findUnresolvedConflictingVersionsOfFile:documentName];
    return [documentVersions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"versionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSFileVersion *fileVersion = [documentVersions objectAtIndex:indexPath.row];
    
    NSNumber *filesize = [[iCloud sharedCloud] fileSize:documentName];
    NSDate *updated = [[iCloud sharedCloud] fileModifiedDate:documentName];
    
    NSString *fileDetail = [NSString stringWithFormat:@"%@ Kb, updated %@.\nVersion %@", @([filesize floatValue]/1024), [[self dateFormatterDisplay] stringFromDate:updated], fileVersion];
    
    // Configure the cell...
    cell.textLabel.text = documentName;
    cell.detailTextLabel.text = fileDetail;
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[iCloud sharedCloud] resolveConflictForFile:documentName withSelectedFileVersion:[documentVersions objectAtIndex:indexPath.row]];
    [[iCloud sharedCloud] updateFiles];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSDateFormatter *)dateFormatterDisplay
{
    static NSDateFormatter *dateFormatterDisplay;
    if(!dateFormatterDisplay){
        dateFormatterDisplay = [NSDateFormatter new];
        dateFormatterDisplay.dateFormat = Local(@"yyyy-MM-dd EEEE H:mm");
    }
    
    return dateFormatterDisplay;
}
@end
