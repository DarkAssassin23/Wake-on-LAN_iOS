# Wake-on-LAN iOS App

## Table of Contents
 * [About](#about)
 * [iOS Device Requirements](#ios-device-requirements)
 * [Installing the App](#installation)
   * [Enabling Developer Mode](#enable-developer-mode)
   * [Trusting your Developer License](#trusting-your-developer-license)
 * [Configuration](#configuration)
   * [Adding a new device](#adding-a-new-device)
   * [Deleting a device](#deleting-a-device)
 * [Usage](#usage)

## About
iOS App to wake devices by sending Wake-on-LAN magic packets

## iOS Device Requirements
  * iOS 16 or newer

## Installation
To install the app on your iPhone, you will need a Mac with Xcode 
Version 14 or newer installed on it.

### Enable Developer Mode
Seeing that this app is not on the App Store and you need to install 
it manually, you need to enable developer mode on your iPhone. To do
this, go to <code>Settings</code> -> <code>Privacy & Security</code>. 
Scroll down to the bottom, select <code>Developer Mode</code>, and 
toggle it on. After you do so, Settings presents an alert to warn you 
that Developer Mode reduces the security of your device. To continue 
enabling Developer Mode, tap the alert's Restart button.

### Trusting Your Developer License
Again, since this app is not on the App Store and you have to manually 
install it onto your iPhone, you will most likely encounter an error 
from Xcode trying to install it on your phone saying it was unable to 
launch the app because it has an invalid code signature. 

You will also see a similiar message on your iPhone saying "Untrusted 
Developer" and "Your device management settings do not allow using 
apps from developer <Your Developer Email/ID> on this iPhone." To fix 
this, go to <code>Settings</code> -> <code>General</code> -> 
<code>VPN & Device Management</code>. From here, tap the Developer App
and then trust it on the next page. Then re-build the app to your 
phone.

## Configuration
### Adding a new Device
To add a device, select the `+` icon in the top right corner of the screen.
This will bring up a window that will allow you to enter the Name, MAC
Address, and IP address of the device.

> [!NOTE]
> Yes, I am well aware that Wake-on-LAN uses broadcast and not a specific
> IP Address. However, per Apple's [documentation](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_networking_multicast)
> you need to have the `com.apple.developer.networking.multicast` 
> entitlement in order to use broadcast in iOS apps. Seeing as I do not
> have this, I had to make due with IP Addresses. Which, yes, does not work
> nearly as reliably. Especially if you don't have IP-MAC address binding
> configured.

Once you have entered the proper configuration for that device, select
`Save`.

### Deleting a device
To delete a device simply press one it and swipe to the left. Similarly, 
you can select `Edit` at the top right corner of the screen, then select
the red circle with the `-` in the middle that just appeared

## Usage
To wake a device, select the device you wish to select from the list of
devices. If you need to update any of the devices configuration settings
you can do so here. Just make sure you select `Update` before you try to
wake the device, or your changes won't be used.

If your configuration looks good, select the `Send WOL Packet` button at 
the bottom of the screen to send the magic packet.
