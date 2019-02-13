# Challenge

### Installation
`git clone git@github.com:tailec/cs.git`

`pod install`


### Short overview
*Architecture* - MVVM architecture with observables as binding mechanism
between view model and view controller

*Networking* - Simple generic `Network` class which supports GET requests only

*Cache* - Generic cache which uses `FileManager` under the hood

*Unit testing* - There are some unit tests for view model but the rest of the app should be easy to test because of DI, protocol conformances etc.

### What I tested
I tested the following scenarios (just to make sure that caching is working):

**Scenario 1:**

Steps:
- Launch app for the first time with network connection off

Expected result:
- App shows `UIAlertController`


**Scenario 2:**

Steps:
- Launch app for the first time with network connection on

Expected result:
- App shows correct score


**Scenario 3:**

Steps:
- Launch app for the first time with network connection on
- Kill app
- Launch app again but this time with network connection off

Expected result:
- App shows loading spinner (and tries to retry network request) and then loads data from cache


**Scenario 4:**

Steps:
- Change `Score` decoding so it parses network result incorrectly]
- Launch app for the first time with network connection on

```
enum CreditReportInfoKeys: String, CodingKey {
    case score = "randomvalue"
}
```

Expected result:
- App shows `UIAlertController`
