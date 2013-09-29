#CSNotificationView

Easy to use, iOS-7-style, semi-translucent notification view with blur that drops into `UIView` and `UITableView`.

**Requires iOS 7.**


<div style="float: left; text-align: center">

<img src="https://f.cloud.github.com/assets/14349/1233447/de61fffc-2928-11e3-8259-c1b81b08dfe0.png" width="30%"></img>
&nbsp;
<img src="https://f.cloud.github.com/assets/14349/1233448/de644492-2928-11e3-89da-3801a77e1498.png" width="30%"></img>
&nbsp;
<img src="https://f.cloud.github.com/assets/956573/1167997/81752d2a-2098-11e3-96a3-c99f4b576a1f.png" width="30%"></img>


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
