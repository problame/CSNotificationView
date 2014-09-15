#CSNotificationView

Easy to use, semi-translucent and blurring notification view that drops into `UIView`, `UITableView`, `UICollectionView`.
Also supports displaying progress.

**Supports iOS 7 and iOS 8. Requires Xcode 6.**


<div style="float: left; text-align: center">
<img src="https://f.cloud.github.com/assets/956573/1240926/3764db88-2a14-11e3-89d2-c1492b003d33.png" width="30%"></img>
&nbsp;
<img src="https://f.cloud.github.com/assets/956573/1240925/375efbdc-2a14-11e3-9258-7fc4395ae019.png" width="30%"></img>
&nbsp;
<img src="https://f.cloud.github.com/assets/956573/1329610/502c2ed0-351a-11e3-859d-534c792a7c65.png" width="30%"></img>


</div>

##Example code

###Quick presentation

```objc
[CSNotificationView showInViewController:self
									style:CSNotificationViewStyleError
								  message:@"A critical error happened."];
									  
[CSNotificationView showInViewController:self
									style:CSNotificationViewStyleSuccess
								  message:@"Great, it works."];
									  
									  
```

###UIActivityIndicatorView built-in

```objc
CSNotificationView* note = (...);
note.showingActivity = YES;

[note setVisible:YES animated:YES completion:nil];
(...)
[note dismissWithStyle:CSNotificationViewStyleSuccess message:@"Success!"
	      duration:kCSNotificationViewDefaultShowDuration animated:YES];
```

###Tap handling

Handle tap events on the notification using a block callback

```objc
    __block typeof(self) weakSelf = self;
    self.loadingNotificationView.tapHandler = ^{
        [weakSelf cancelOperationXYZ];
        [weakSelf.loadingNotificationView dismissWithStyle:CSNotificationViewStyleError
                                  	   message:@"Cancelled"
                                  	  duration:kCSNotificationViewDefaultShowDuration animated:YES];
    };
```

###Customization

####Custom image / icon

```objc
note.image = [UIImage imageNamed:@"mustache"];
```

####Flexible with text & no images

```objc
[CSNotificationView showInViewController:self
        tintColor:[UIColor colorWithRed:0.000 green:0.6 blue:1.000 alpha:1]
            image:nil
          message:@"No icon and a message that needs two rows and extra \
                    presentation time to be displayed properly."
         duration:5.8f];

```


##License

See [LICENSE.md](https://raw.github.com/problame/CSNotificationView/master/LICENSE.md)
