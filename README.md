
#yunqi


## MARK

- Package name : **7cm.cloud7.yqqq**
- Version: **1.0.0**
- Auth:<http://terry.cloud7.com.cn>
- Seesion:<http://cloud7.com.cn>
- https link:<https://www.cloud7.com.cn>
- umeng sdk token: **53046df156240be48b0c3166**
- weichat token: **53046df156240be48b0c3166???** i dont know
- SystemTitColor **0x008ccd or 0x0082b6** 
- System font   **36.0f** and color **ffffff**
- app@cloud7.com.cn Cloud7App

============
*   orderStatus	订单状态*  10：未付款*  20:未发货*  30:已发货*  40:交易完成*  50:交易关闭/取消
=============* paymentMethodType	支付方式的类型* 10：货到付款* 20：在线支付
 


------------------------------------

### From e-mail 
- 轻应用管理员（云起会员）
- 登录界面：http://terry.cloud7.com.cn
- 轻应用管理员（云起会员）用户名：ciznx@qq.com
- 轻应用管理员（云起会员）密码：111111（六个 1）
- 测试用轻应用主机名：**apiservicetest.cloud7.com.cn**
- 测试用轻应用管理界面：<http://apiservicetest.cloud7.com.cn/Admin/Signin> (请点 击“使用集成 Cloud7 的管理员登录”进入管理)


------------------------------------

`轻应用管理员（云起会员）登录界面：http://terry.cloud7.com.cn
轻应用管理员（云起会员）用户名：ciznx@qq.com
轻应用管理员（云起会员）密码：111111（六个 1）
测试用轻应用主机名：apiservicetest.cloud7.com.cn
测试用轻应用管理界面：http://apiservicetest.cloud7.com.cn/Admin/Signin (请点击“使用集成 Cloud7 的管理员登录”进入管理)` 

## 前言

**tinkl**, is some of my experiences,hope that can help *ios  developers*.

**yunqi** uses ARC and requires iOS 7.0+.

It probably will work with iOS 6, I have not tried,but  it is not using any iOS7 specific APIs.
 
####  Installation

> just download zip file… &gt; and you can use it .

#### Links and Email

if you have some Question to ask me, you can contact email <nicolastinkl@gmail.com> link.
 

[id]: http://mouapp.com "Markdown editor on Mac OS X"



####  结束语
1. github 有那么多工具和开源项目,了解它,解剖它,弄懂它
2. 把这些工具组合在一起,才是最厉害的武器(tools)
3. 一定要快+稳,不要钻牛角尖,这不是读书时代.
4. 引用张小龙一句话:这只是我解决问题的其中一种方式,可能并非正确,但可以供你们参考取<b>交集</b>

##### websockte interfece

* (1) 登录时添加必要的参数（DevicePushToken）
* (2) 使用 SignalR 客户端登录响应中的鉴权信息连接到 Cloud7 Alive 服务器（尝试 http://dyknow.github.io/SignalR-ObjC/）
* (3) 完成连接过程中、已连接、失去连接的界面功能；
* (4) 处理 APN 消息
 
=============
根据服务器通信，实现界面功能（如新消息、新订单等）；

**实现两个通信功能:**

```

 a. 收到服务器通信时，send 确认通信
 b. expired 接口（服务器要求重新连接，请延时 5s 后重连）

```

* (5) *断线之后按 SDK 方法重连（SDK 已内置，考虑优化）
* (6) *注意 401 响应，一旦发生 401 响应，请重新登录（服务器出现不稳定的情况，登录信息已丢失）
* (7) 可能不一定好搞定，可以捕获连接失败事件，如果多次失败，则要求重新登录；可以通过传回错误的鉴权参数来发起这一状况




三分钟创建精美轻应用

立刻对接百度、微信、UC的数亿用户流量！在手机上实现 展示产品、销售产品、服务客户，不再需要“数人、数月、 数万”……

<a>https://www.cloud7.com.cn/<a/> 
