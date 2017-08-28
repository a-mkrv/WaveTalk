[![Build Status](https://travis-ci.org/MarioCode/WaveTalk.svg?branch=master)](https://travis-ci.org/MarioCode/WaveTalk)
[![Chrome Web Store](https://img.shields.io/chrome-web-store/price/nimelepbpejjlbmoobocpfnjhihnpked.svg)](https://github.com/MarioCode)
[![NPM Downloads](https://img.shields.io/npm/dt/https://github.com/MarioCode/WaveTalk.svg)](https://github.com/MarioCode/WaveTalk/archive/master.zip)

# Wave Talk
<center>
<img src="https://cloud.githubusercontent.com/assets/12527666/22626570/60ae9e12-ebc1-11e6-9089-5d86ced0a4dc.png" width="250">
</center>

**Client - messenger for the iOS / iPhone**, which interacts with the сrossplatform clients for the operating systems Windows, Linux, Mac (written in Qt - C++).
All "communication" between devices is performed using TCP sockets.
The development is aimed at creating a secure multi-user system for instant information exchange between users.

Currently implemented all the basic functionality of the messenger. Views: Welcome, Authorization, Registration and Tab with Contacts -> Detailed description, Tab with Dialogues, and Tab with different flexible User Settings.

<img src="https://user-images.githubusercontent.com/12527666/29724493-5a5a6e2a-89d1-11e7-8aba-30f7814a9bfa.png" width="30"> Server part (C++) for the client (+ desktop client): https://github.com/MarioCode/Chat

<img src="https://user-images.githubusercontent.com/12527666/29724734-4b37921e-89d2-11e7-818b-ddf0a550e5af.png" width="30"> This project is developed as a diploma thesis of bachelor for the University. 

---

#### Already implemented:
+ Finished the basic UI elements
+ Attempt to use MVC 
+ Registration, authorization of users
+ Encryption:
  - RSA (256 bit) - for messages
  - MD5 (+salt) - for user passwords
+ Database: 
  - SQLite - storage for text information (user's data, messages, etc)
  - Firebase - cloud storage for media files
+ Small features: flexible notification system, database search, status setting, extended user information and edit your own data, password reminder.

#### In the plans:
+ _Optimization of sending / receiving data_
+ _Advanced security settings_
+ _Group Dialogues_
+ _Black list for users_
+ _Adding to change the language_
+ _Notifications_
+ _Add primitive calls_

---

#### Instruments:
+ Xcode 8
+ Swift 3 / iOS 9+
+ SourceTree
+ Frameworks (use pods):
  - [JSQMessagesViewController](https://github.com/jessesquires/JSQMessagesViewController "JSQMessagesViewController")
  - [SCLAlertView](https://github.com/vikmeup/SCLAlertView-Swift "SCLAlertView")
  - [Firebase SDK](https://firebase.google.com "Firebase SDK")
  - [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift "CryptoSwift")

---

### Architecture interaction

<img src="https://user-images.githubusercontent.com/12527666/29724817-b6cac6fe-89d2-11e7-8fa6-a5939be71fa4.png" width="570">

### The current developments
##### Authorization, Registration and Reset password
<img src="https://user-images.githubusercontent.com/12527666/29726174-73a84478-89d7-11e7-9b23-a19e7b41dc27.png" width="750">

##### Setting -> My Profile -> More personal information
<img src="https://user-images.githubusercontent.com/12527666/29726435-610d27ba-89d8-11e7-9963-9658dd4ed0ee.png" width="750">

##### Details of user from userlist (Contacts), Dialogues
<img src="https://user-images.githubusercontent.com/12527666/29728884-81ad0102-89e2-11e7-87dc-6e72775d4455.png" width="750">
