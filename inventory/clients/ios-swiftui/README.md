To set the realm app-id at runtime, use the `ci` scheme and set `REALM_APP_ID`.

If tests were working then something like this should work:

```
xcodebuild -project InventoryDemo.xcodeproj -scheme "ci" -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 12 Pro Max,OS=14.5' -derivedDataPath './output' REALM_APP_ID='inventorysync-xlrrz' test
```