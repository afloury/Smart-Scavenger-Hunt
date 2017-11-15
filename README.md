# Smart-Scavenger-Hunt
IOT Project based on the principle of Scavenger Hunt



## About this projet

Based on the scavenger hunt game, the goal is to :
- Go to the registration point
- Create your team
- go to the withdrawal point
- Get a list of objects
- Take a photo of one object in the list
- Go to the delivery point
- Send your photo and you can see the result (Now you can get an other mission)
- A supervision for organiser to see stats, ranks, photos with locations...


## Installing

### Equipment
- An iPhone with iOS 11 minimum
- Computer with Mac OS 10.12.6 or above
- Either or both:
  - 2x Bluetooth 4.0 LE compatible device (ex: Raspberry Pis) for the iBeacon feature
  - 2x Web browser connected to a monitor for the QR-Code feature
- Web browser connected to a monitor for visual feedback (score, won, lost)

### Software
- Xcode 9 or above
- A Google Cloud Vision API account
- Server with Docker and Docker-Compose

### Launch server with docker-compose


### Install iOS app on iPhone

- Open the project in Xcode
- Connect your iPhone to your Mac
- Select your device in the target list
- Launch the App

### Configure iOS app (settings ip)

When the app is installed, you have to go in the settings of the app and add the address of:
- The Router
- The Location Restriction

Like this:  

<img src="https://github.com/afloury/Smart-Scavenger-Hunt/blob/master/doc/Images/settings_iOS_resized.PNG" alt="Drawing" width="100px"/>

![alt text](https://github.com/afloury/Smart-Scavenger-Hunt/blob/master/doc/Images/settings_iOS_resized.PNG "Settings iOS")



### Setup iBeacon/RPi

### Setup QR-Code

### Setup visual feedback



## Making your own (Tutorial)


## Branches

- **[Router](https://github.com/afloury/Smart-Scavenger-Hunt/tree/router)**
- **[Game (container)](https://github.com/afloury/Smart-Scavenger-Hunt/tree/game)**
- **[Location Restriction](https://github.com/afloury/Smart-Scavenger-Hunt/tree/location-restriction)**
- **[Supervision](https://github.com/afloury/Smart-Scavenger-Hunt/tree/supervision)**
- **[Orchestrator](https://github.com/afloury/Smart-Scavenger-Hunt/tree/orchestrator)**
- **[iOS](https://github.com/afloury/Smart-Scavenger-Hunt/tree/ios)**


## [History (fr)](https://github.com/afloury/Smart-Scavenger-Hunt/blob/master/HISTORY.md)
