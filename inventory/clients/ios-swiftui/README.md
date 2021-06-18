# Inventory Demo - SwiftUI

| Login       | Inventory List     | Adding an item     |
| :-------------: | :----------: | :-----------: |
|  ![](img/inventory-swiftui-login.png) | ![](img/inventory-swiftui-inventory.png)   | ![](img/inventory-swiftui-add.png)    |

## About

This is the SwiftUI version of the Inventory demo app. There are [other versions too](https://github.com/mongodb-developer/realm-demos/tree/main/inventory#mobile-clients).

## How to build

1. You need to clone this repo `git clone https://github.com/mongodb-developer/realm-demos/`
1. Go to the `ios-swiftui` folder: `cd inventory/clients/ios-swiftui/InventoryDemo`
1. Open the project file with Xcode: `InventoryDemo.xcodeproj`
1. Leave Swift Package Manager resolve and download all dependencies
1. Select `InventoryDemo` [Scheme](#Schemes)
1. Before running, [change the Realm Id in `realm-app-id.txt`](#changing-the-realm-app-id)
1. Build and Run

## Schemes

![](img/inventory-demo-swiftui-schemes.png)

This project has two Schemes:
- CI: used for Continous Integration. In this case, a GitHUb action is used to build the app. You can check the [workflow here](https://github.com/mongodb-developer/realm-demos/actions/workflows/build.yml)
- InventoryDemo: scheme used to run the app locally in Simulator, Device, etc.

## Changing the Realm App Id

This client uses Realm Sync to store data in the cloud. To do this, you need a Realm App Id so this client knows where to store data. [Instructions are here](https://github.com/mongodb-developer/realm-demos/tree/main/inventory#-create-an-atlas-cluster)

To set the realm app-id open the file `realm-app-id.txt` and put in there your Realm App Id.

## Tests

There are a few tests:
- Unit Tests
- Tests of SwiftUI
- UI Automation Tests

To run the tests from Xcode: ⌘ + U

### Running tests from the Command Line

If tests were working then something like this should work:

```
xcodebuild -project InventoryDemo.xcodeproj -scheme "ci" -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 12 Pro Max,OS=14.5' -derivedDataPath './output' test
```