# 0.10.3
* Add support for strings in filters keys.

# 0.10.2
* Add support for ActiveSupport::Hash as params

# 0.10.1
* Move activities to Activities folder to avoid conflict with Activity Class.

# 0.10.0
* Support Trailblazer 2.1.0 wiring api, drop old api

# 0.3.0
* Change internal context argument to symbols to match trailblazer 2.1 convention.

# 0.2.7
* Don't cast uuids to dates in the filters

# 0.1.4
* Updated DataMapper Adapter to include sorting by multiple columns/directions and the predicate feature.

# 0.1.3
* Added sorting by multiple columns/directions for Hash, ActiveRecord and Sequel. Temporarily disabled sorting for DataMapper Adapter until i can find the time this weekend to update that Adapter as well.
* Due to the above, a big change in the way sorting works, and which methods are available for it

# 0.1.2

* Predicate feature introduced, doesn't work for old datamapper adapter yet. Default predicates covered for now: eq, not_eq, blank, not_blank, lt, lte, gt, gte
* Removed Hashie as dependency and introduced simple version of deep_locate

# 0.1.1

* load options[:model] with result set otherwise loading contracts fails, have to find a nicer solution for this at some point

# 0.1.0

* First stable release
