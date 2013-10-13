#CSNotificationView

Easy to use, iOS-7-style, semi-translucent notification view with blur that drops into `UIView` and `UITableView`.

**Requires iOS 7.**


<div style="float: left; text-align: center">
<img src="https://f.cloud.github.com/assets/956573/1240926/3764db88-2a14-11e3-89d2-c1492b003d33.png" width="30%"></img>
&nbsp;
<img src="https://f.cloud.github.com/assets/956573/1240925/375efbdc-2a14-11e3-9258-7fc4395ae019.png" width="30%"></img>
&nbsp;
<img src="https://f.cloud.github.com/assets/956573/1240927/37601cce-2a14-11e3-8963-daff170e5c05.png" width="30%"></img>


</div>

##Example code

Predefined styles

```objc
[CSNotificationView showInViewController:self
	 								style:CSNotificationViewStyleError
								  message:@"A critical error happened."];
									  
[CSNotificationView showInViewController:self
									style:CSNotificationViewStyleSuccess
								  message:@"Great, it works."];
									  
									  
```

Customize appearance

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
