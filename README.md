## Why did we fork https://github.com/snowplow/snowplow-objc-tracker?

When we upgraded Odyssey from RxSwift 3.x to 4.x, we needed to upgrade every other dependency that depends on RxSwift, including [RxReachability](https://github.com/gamechanger/odyssey/pull/2222). Upgrading RxReachability included an upgrade to [ReachabilitySwift](https://github.com/ashleymills/Reachability.swift), which renamed it's module to Reachability. The module name change introduced a namespace collision with [Reachability](https://github.com/tonymillion/Reachability) in this library. We decided to make the Reachability dependency private to avoid the collision. You can read more about alternative strategies we pursued here: https://github.com/gamechanger/odyssey/pull/2222.

## Contributing

There is no continuous integration for this repository. Please ensure tests pass by running the test suite for either the `Snowplow` or `SnowplowTests` target before merging new changes.

If this repository becomes out of date from the [upstream](https://github.com/snowplow/snowplow-objc-tracker), feel free to rebase and update this repository as long as tests still pass.

You can publish a new Cocoapod version to our private repository by running [`./script/publish_version.sh <version>`](https://github.com/gamechanger/snowplow-objc-tracker/blob/master/script/publish-version.sh). Please abide by [semantic versioning](https://semver.org/).
