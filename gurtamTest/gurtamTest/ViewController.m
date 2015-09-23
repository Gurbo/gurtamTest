//
//  ViewController.m
//  gurtamTest
//
//  Created by Hurbo Aliaksei on 9/23/15.
//  Copyright © 2015 Aliaksei Hurbo. All rights reserved.
//

#import "ViewController.h"
#import "Cache.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

typedef void (^ArrayWithNumbers)(NSArray *array);

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableArray *numbersDataSource;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.inputTextField.delegate = self;
    self.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.activityIndicator.hidden = YES;
    [self.searchButton addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SearchAction

- (void) searchAction:(id)sender
{
    NSCharacterSet *numericOnly = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *myStringSet = [NSCharacterSet characterSetWithCharactersInString:self.inputTextField.text];
    
    if (![numericOnly isSupersetOfSet: myStringSet])
    {
        if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
            UIAlertView *av  = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter the correct number" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
            return;
        } else {
            UIAlertController *av = [UIAlertController alertControllerWithTitle:@"Error" message:@"Enter the correct number" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action) {
                                                                 [self dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [av addAction:okAction];
            [self presentViewController:av animated:YES completion:nil];
            return;
        }
    }
    
    [self searchActionSetDesignSettings];
    self.numbersDataSource = [[Cache sharedInstance].cachedDictionary objectForKey:self.inputTextField.text];
    if (self.numbersDataSource.count == 0) {
        self.numbersDataSource = nil;
        [self.tableView reloadData];
        [self searchNumbersAlgorithm:^(NSArray *array) {
            if (![[Cache sharedInstance].cachedDictionary objectForKey:self.inputTextField.text]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [[Cache sharedInstance].cachedDictionary setObject:array forKey:self.inputTextField.text];
                    [[Cache sharedInstance] saveCache];
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Search finished");
                [self setDesignElementsEnabled:YES];
                self.activityIndicator.hidden = YES;
                self.numbersDataSource = [NSMutableArray arrayWithArray:array];
                [self.tableView reloadData];
            });
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Cache loaded");
            [self setDesignElementsEnabled:YES];
            self.activityIndicator.hidden = YES;
            [self.tableView reloadData];
        });
    }
}

- (void) searchNumbersAlgorithm:(ArrayWithNumbers)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        long long n = [self.inputTextField.text longLongValue];
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:[NSNumber numberWithInt:2]];
        
        for (long long i = 3; i < n+1; i += 2) {
            if (!((i > 10) && (i % 10 == 5))) {
                BOOL additionFlag;
                for (NSNumber *intNumber in arr) {
                    int numFromArray = [intNumber intValue];
                    if (numFromArray * numFromArray - 1 > i)  {
                        [arr addObject:[NSNumber numberWithLong:i]];
                        [self updateTableViewDinamicallyWithArray:arr];
                        additionFlag = YES;
                        break;
                    }
                    if (i % numFromArray == 0) {
                        break;
                    }
                }
                if (!additionFlag) {
                    [arr addObject:[NSNumber numberWithLong:i]];
                    [self updateTableViewDinamicallyWithArray:arr];
                }
            }
        }
        block(arr);
    });
}

- (void) updateTableViewDinamicallyWithArray:(NSMutableArray *)array {
    if (array.count % 1000 == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.numbersDataSource = array;
            [self.tableView reloadData];
        });
    }
}

- (void) searchActionSetDesignSettings
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.inputTextField resignFirstResponder];
        [self setDesignElementsEnabled:NO];
        [self.activityIndicator startAnimating];
    });
}

- (void) setDesignElementsEnabled:(BOOL)enabled
{
    self.historyButton.enabled = enabled;
    self.inputTextField.enabled = enabled;
    self.searchButton.enabled   = enabled;
    self.activityIndicator.hidden = enabled;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.numbersDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (self.numbersDataSource.count != 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.numbersDataSource objectAtIndex:indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
