# Changelog

## [0.101.0](https://github.com/trailblazer/trailblazer-finder/compare/v0.100.0...v0.101.0) (2025-03-03)


### Features

* remove casting from the finder ([#53](https://github.com/trailblazer/trailblazer-finder/issues/53)) ([a16a106](https://github.com/trailblazer/trailblazer-finder/commit/a16a1067e330f3913e93ed2a25468554da5b5473))


### Bug Fixes

* test with ruby 3.4 ([#54](https://github.com/trailblazer/trailblazer-finder/issues/54)) ([c80c15e](https://github.com/trailblazer/trailblazer-finder/commit/c80c15e75c8597e400037365496b76b8045bb99f))
* use left instead of fail internally ([#51](https://github.com/trailblazer/trailblazer-finder/issues/51)) ([271b141](https://github.com/trailblazer/trailblazer-finder/commit/271b141b487ca178b4d4ed371b360f79e262b671))

## [0.100.0](https://github.com/trailblazer/trailblazer-finder/compare/v0.92.0...v0.100.0) (2024-01-12)


### Features

* use zeitwrek as autoloader ([#49](https://github.com/trailblazer/trailblazer-finder/issues/49)) ([a0be743](https://github.com/trailblazer/trailblazer-finder/commit/a0be74324c126df20fc7598f6453e2d97a403d5b))

## [0.92.0](https://github.com/trailblazer/trailblazer-finder/compare/v0.91.0...v0.92.0) (2024-01-12)


### Features

* allow finders to be inherited ([#47](https://github.com/trailblazer/trailblazer-finder/issues/47)) ([1869055](https://github.com/trailblazer/trailblazer-finder/commit/186905596d74aa6fe180ce709cf7da79b8a9aa2c))
* change configuration from hash to configuration object ([1869055](https://github.com/trailblazer/trailblazer-finder/commit/186905596d74aa6fe180ce709cf7da79b8a9aa2c))

## [0.91.0](https://github.com/trailblazer/trailblazer-finder/compare/v0.90.0...v0.91.0) (2024-01-10)


### Features

* init minitest migration ([#39](https://github.com/trailblazer/trailblazer-finder/issues/39)) ([dc6fdb0](https://github.com/trailblazer/trailblazer-finder/commit/dc6fdb05cd492a8d60ed9c9e882537bacf3d3f1e))
* use dry-types for adapter and paginator ([#42](https://github.com/trailblazer/trailblazer-finder/issues/42)) ([8575e26](https://github.com/trailblazer/trailblazer-finder/commit/8575e266aa1ae069bfd023970a2e427a8124dec8))


### Bug Fixes

* remove deprecated usage of Trailblazer::Activity::TaskBuilder::Binary ([#41](https://github.com/trailblazer/trailblazer-finder/issues/41)) ([b8965ff](https://github.com/trailblazer/trailblazer-finder/commit/b8965ff9f0549f927409e90cc2d8a227267c13d9))
* update gemspec ([#37](https://github.com/trailblazer/trailblazer-finder/issues/37)) ([7cf064f](https://github.com/trailblazer/trailblazer-finder/commit/7cf064f8e6e33b863a169041e2ee59ebd5152fd1))

## 0.90.0
* Use inject dsl api 

## 0.80.1
* Fix release error of 0.80.0

## 0.80.0
* Lock trailblazer-activity to below 0.13

## 0.70.0
* Drop Support Legacy Dry-types

## 0.60.0
* Support Ruby 3.0

## 0.50.0
* Breaking change: Use adapter and paginator configs instead of mixing them in adapters config.

## 0.10.3
* Add support for strings in filters keys.

## 0.10.2
* Add support for ActiveSupport::Hash as params

## 0.10.1
* Move activities to Activities folder to avoid conflict with Activity Class.

## 0.10.0
* Support Trailblazer 2.1.0 wiring api, drop old api

## 0.3.0
* Change internal context argument to symbols to match trailblazer 2.1 convention.

## 0.2.7
* Don't cast uuids to dates in the filters

## 0.1.4
* Updated DataMapper Adapter to include sorting by multiple columns/directions and the predicate feature.

## 0.1.3
* Added sorting by multiple columns/directions for Hash, ActiveRecord and Sequel. Temporarily disabled sorting for DataMapper Adapter until i can find the time this weekend to update that Adapter as well.
* Due to the above, a big change in the way sorting works, and which methods are available for it

## 0.1.2

* Predicate feature introduced, doesn't work for old datamapper adapter yet. Default predicates covered for now: eq, not_eq, blank, not_blank, lt, lte, gt, gte
* Removed Hashie as dependency and introduced simple version of deep_locate

## 0.1.1

* load options[:model] with result set otherwise loading contracts fails, have to find a nicer solution for this at some point

## 0.1.0

* First stable release
