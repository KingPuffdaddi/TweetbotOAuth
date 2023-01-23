@interface PTHOAuthURLRequest
-(NSString *)consumerKey;
-(void)setConsumerKey:(id)arg1;
-(NSString *)consumerSecret;
-(void)setConsumerSecret:(id)arg1;
-(NSString *)token;
-(void)setToken:(id)arg1;
-(NSString *)tokenSecret;
-(void)setTokenSecret:(id)arg1;
@end

@interface _PTHTweetbotAccountSettingsCell : UITableViewCell
@end


NSString *consumerKey = @"";
NSString *consumerSecret = @"";
NSString *token = @"";
NSString *tokenSecret = @"";


//hook all OAuth Requests to use new API Keys
%hook PTHOAuthURLRequest

-(NSString *)consumerKey{
	return consumerKey;
}

-(void)setConsumerKey:(id)arg1{
	%orig(consumerKey);
}

-(NSString *)consumerSecret{

	return consumerSecret;
}

-(void)setConsumerSecret:(id)arg1{
	%orig(consumerSecret);
}


-(NSString *)token{
	return token;
}

-(void)setToken:(id)arg1{
	%orig(token);
	
}


-(NSString *)tokenSecret{
	return tokenSecret;
}

-(void)setTokenSecret:(id)arg1{
	%orig(tokenSecret);
}


%end






//add input of API Keys to settings
%hook _PTHTweetbotAccountSettingsCell

-(id)initWithStyle:(NSInteger *)style reuseIdentifier:(id)identifier{

	id og = %orig;
	UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:og action:@selector(handleLongPress:)];
	[og addGestureRecognizer:longPressRecognizer];


	return og;

}


%new
-(void)handleLongPress:(UILongPressGestureRecognizer *)sender{
	if (sender.state == UIGestureRecognizerStateEnded) {
		

		//setup an AlertController to get user input
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
		[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		textField.placeholder = @"Consumer Key";
		textField.text = consumerKey;
		}];
		[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		textField.placeholder = @"Consumer Secret";
		textField.text = consumerSecret;
		}];
		[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		textField.placeholder = @"Token";
		textField.text = token;
		}];
		[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		textField.placeholder = @"Token Secret";
		textField.text = tokenSecret;
		}];

		UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			consumerKey = [[alertController textFields][0] text];
			consumerSecret = [[alertController textFields][1] text];
			token = [[alertController textFields][2] text];
			tokenSecret = [[alertController textFields][3] text];

			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"apiKeys.plist"];
			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSMutableDictionary *data;
			if([fileManager fileExistsAtPath:path]){
				data = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
			}else{
				data = [[NSMutableDictionary alloc] init];
			}

			[data setObject:consumerKey forKey:@"ck"];
			[data setObject:consumerSecret forKey:@"cs"];
			[data setObject:token forKey:@"t"];
			[data setObject:tokenSecret forKey:@"ts"];

			[data writeToFile:path atomically:YES];



		}];


		[alertController addAction:confirmAction];
		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
		[alertController addAction:cancelAction];

		//find ViewController to present alert from
		id vc = [self nextResponder];
		while (vc != nil) {
			if ([vc isKindOfClass:[UIViewController class]]) {
				[(UIViewController *)vc  presentViewController:alertController animated:YES completion:nil];
				break;
			}
			vc = [vc nextResponder];
		}

	}
	
}


%end



%ctor{


	//load previous API Keys from .plist if already exist
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"apiKeys.plist"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if([fileManager fileExistsAtPath:path]){
		NSDictionary *domain = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
		
		consumerKey = [domain objectForKey:@"ck"];
		consumerSecret = [domain objectForKey:@"cs"];
		token = [domain objectForKey:@"t"];
		tokenSecret = [domain objectForKey:@"ts"];

		
	}
	
	
	
}