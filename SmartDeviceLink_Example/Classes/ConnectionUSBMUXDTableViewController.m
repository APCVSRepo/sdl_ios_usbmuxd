//
//  ConnectionUSBMUXDTableViewController.m
//  SmartDeviceLink-iOS

#import "ConnectionUSBMUXDTableViewController.h"
#import "ProxyManager.h"
#import "LogTableViewController.h"
#import "RPCTableViewController.h"
#import "Masonry.h"

@interface ConnectionUSBMUXDTableViewController ()
{
    UITabBarController *_tabBarController;
}

@property (weak, nonatomic) IBOutlet UITableViewCell *connectTableViewCell;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;

@end

@implementation ConnectionUSBMUXDTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Observe Proxy Manager state
//    [[ProxyManager sharedManager] addObserver:self forKeyPath:NSStringFromSelector(@selector(state)) options:(NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew) context:nil];
    
    // Tableview setup
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    // Connect Button setup
    self.connectButton.tintColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor whiteColor];
    [button addTarget:self action:@selector(showUsbmuxdSample) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Show Sample" forState:UIControlStateNormal];
    [self.tableView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.width.equalTo(self.tableView);
        make.top.equalTo(self.mas_topLayoutGuide).offset(40);
        make.height.equalTo(@44);
    }];
}

- (void)dealloc {
    @try {
        [[ProxyManager sharedManager] removeObserver:self forKeyPath:NSStringFromSelector(@selector(state))];
    } @catch (NSException __unused *exception) {}
}

- (void)showUsbmuxdSample {
    if (!_tabBarController) {
        RPCTableViewController *rpcViewController = [[RPCTableViewController alloc] init];
        UINavigationController *rpcNavigationController = [[UINavigationController alloc] initWithRootViewController:rpcViewController];
        
        LogTableViewController *logViewController = [[LogTableViewController alloc] init];
        UINavigationController *logNavigationController = [[UINavigationController alloc] initWithRootViewController:logViewController];
        
        _tabBarController = [[UITabBarController alloc] init];
        _tabBarController.viewControllers = @[rpcNavigationController, logNavigationController];
    }
    
    [self.navigationController presentViewController:_tabBarController animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

#pragma mark - IBActions

- (IBAction)connectButtonWasPressed:(UIButton *)sender {
    ProxyState state = [ProxyManager sharedManager].state;
    switch (state) {
        case ProxyStateStopped: {
            [[ProxyManager sharedManager] startUSBMUXD];
        } break;
        case ProxyStateSearchingForConnection: {
            [[ProxyManager sharedManager] reset];
        } break;
        case ProxyStateConnected: {
            [[ProxyManager sharedManager] reset];
        } break;
        default: break;
    }
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(state))]) {
        ProxyState newState = [change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        [self proxyManagerDidChangeState:newState];
    }
}


#pragma mark - Private Methods

- (void)proxyManagerDidChangeState:(ProxyState)newState {
    UIColor* newColor = nil;
    NSString* newTitle = nil;
    
    switch (newState) {
        case ProxyStateStopped: {
            newColor = [UIColor redColor];
            newTitle = @"Connect";
        } break;
        case ProxyStateSearchingForConnection: {
            newColor = [UIColor blueColor];
            newTitle = @"Stop Searching";
        } break;
        case ProxyStateConnected: {
            newColor = [UIColor greenColor];
            newTitle = @"Disconnect";
        } break;
        default: break;
    }
    
    if (newColor && newTitle) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.connectTableViewCell.backgroundColor = newColor;
            self.connectButton.titleLabel.text = newTitle;
        });
    }
}

@end
