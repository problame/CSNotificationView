#CSNotificationView

Easy to use, iOS-7-style transculent notification view that drops into `UIView` and `UITableView`.
**Requires iOS 7.**

<div style="float: left; text-align: center">

<img src="https://f.cloud.github.com/assets/956573/1167993/7edb035a-2098-11e3-9572-34a35cbc288d.png" width="30%"></img>
&nbsp;
<img src="https://f.cloud.github.com/assets/956573/1167994/801ea4e2-2098-11e3-8d56-d856b8040eff.png" width="30%"></img>
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
