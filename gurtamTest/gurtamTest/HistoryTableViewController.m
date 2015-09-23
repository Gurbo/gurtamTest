//
//  HistoryTableViewController.m
//  gurtamTest
//
//  Created by Hurbo Aliaksei on 9/23/15.
//  Copyright © 2015 Aliaksei Hurbo. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "Cache.h"
#import "HistoryDetailsTableViewController.h"

@interface HistoryTableViewController ()
@property (nonatomic, strong) NSArray *keysArray;
@end

@implementation HistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.navigationItem.title = @"Search History";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [Cache sharedInstance].cachedDictionary.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"HistoryCellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if ([Cache sharedInstance].cachedDictionary.count != 0) {
        self.keysArray = [[Cache sharedInstance].cachedDictionary allKeys];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.keysArray objectAtIndex:indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showDetailHistorySegue" sender:[self.keysArray objectAtIndex:indexPath.row]];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    HistoryDetailsTableViewController *detailsVC = [segue destinationViewController];
    detailsVC.searchDataSource = [NSArray arrayWithArray:[[Cache sharedInstance].cachedDictionary objectForKey:[NSString stringWithFormat:@"%@", (NSString *)sender]]];
    
}


@end
