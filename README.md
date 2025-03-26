# Trailblazer Finder

Provides DSL for creating [Trailblazer](https://github.com/trailblazer/trailblazer) based Finder Objects. But it is designed to be used on its own as a separate gem. It was influenced by popular [Ransack](https://github.com/activerecord-hackery/ransack) gem, but in addition to [ActiveRecord](https://github.com/rails/rails/tree/master/activerecord), it can be used with [DataMapper](https://github.com/datamapper) or [Sequel](https://github.com/jeremyevans/sequel). It also integrates with [Kaminari](https://github.com/kaminari/kaminari) or [Will Paginate](https://github.com/mislav/will_paginate), as well as [FriendlyId](https://github.com/norman/friendly_id)

[![Gem Version](https://badge.fury.io/rb/trailblazer-finder.svg)](http://badge.fury.io/rb/trailblazer-finder)

## Table of Contents

* [Installation](#installation)
  * [Dependencies](#dependencies)
* [Usage](#usage)
  * [Finder](#finder)
    * [Finder Example](#finder-example)
  * [Operation](#operation)
    * [Operation Example](#operation-example)
  * [Usable without Trailblazer](#usable-without-trailblazer)
    * [Example without Trailblazer](#example-without-trailblazer)
  * [Example Project](#example-project)
  * [Features](#features)
    * [Predicates](#predicate)
      * [Predicates Example](#predicates-example)
    * [Paging](#paging)
      * [Paging Example](#paging-example)
    * [Sorting](#sorting)
      * [Sorting Example](#sorting-example)
  * [Adapters](#adapters)
    * [Adapters Example](#adapters-example)
    * [ActiveRecord](#active_record)
      * [Active Record Example](#active-record-example)
    * [Sequel](#sequel)
      * [Sequel Example](#sequel-example)
  * [Tips & Tricks](#tips--tricks)
  * [ORM's are not required](#results-shortcut)
  * [Passing Entity as Argument](#passing-entity-as-argument)
* [Contributing](#contributing)
* [License](LICENSE.txt)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'trailblazer-finder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install trailblazer-finder

### Dependencies
* [Trailblazer-Activity](https://github.com/trailblazer/trailblazer-activity) - required
* [Trailblazer](https://github.com/trailblazer/trailblazer) - [actually optional, but requires 2.1+](https://github.com/trailblazer/trailblazer-finder#usable-without-trailblazer)

## Usage

### Finder
Just inherit from the ```Trailblazer::Finder``` class.

Features and adapters are optional. However.

NOTE: features are only applied if their options are specified in your finder

An Entity (model) is required, but can:
* be defined in the inherited Finder class
* be given as an option in the call

Be sure to specify features you wish to use in your finder, before specifying adapters.

Basically for most use cases, Entity is the entity/model/array of hashes you wish to use finder on

#### Finder Example

```ruby
class Post::Finder < Trailblazer::Finder
  # Without defining an ORM everything defaults to dealing with hash objects
  adapter :ActiveRecord

  # Optional if you use it as option in the caller, Model/Entity or Array with Hashes
  entity { Post }

  # Pagination settings (don't use it if you don't wish to use paging)
  paging per_page: 5, min_per_page: 1, max_per_page: 100

  # Property
  # Set the properties with their respective options
  #
  # Params:
  #  * +name+::         The property name (attribute /column / field - name) (required)
  #  * +type:+::         Dry Types type, for future validations (required)
  #
  #  * Following is optional (don't use it if you do not wish to use sorting)
  #    * +sortable:+::       Can this property be sorted on? (default: false)
  #    * +sort_direction:+:: Specify default sort direction (only usable if sortable is true)
  #                          (default: :desc)
  property :id, type: Types::Integer
  property :body, type: Types::String, sortable: true
  property :title, type: Types::String, sortable: true, sort_direction: :asc

  # Filter By
  # A simple way to make custom filter methods
  #
  # Params:
  #  * +parameter+::     The parameter to use to call this filter (required)
  #
  #  * Following is optional, matches exact value if not specified
  #    * +with:+::       Filter method defined in Finder class
  #    * block::         A block can be given with the code to filter with
  filter_by :created_after,     with: :apply_created_after
  filter_by(:created_before)    { |entity, _attribute, value| entity.where('DATE(created_at) <= ?', value) if value.present? }

  private

  def apply_created_after(entity, _attribute, value)
    entity.where('DATE(created_at) >= ?', value) if value.present?
  end
end
```

### Operation
The only tie this has to [Trailblazer 2.1](https://github.com/trailblazer/trailblazer), is this part to be honest, which doesn't get loaded in case [Trailblazer](https://github.com/trailblazer/trailblazer) isn't loaded in your environment. The idea was actually to create it specifically for use with [Trailblazer 2.1](https://github.com/trailblazer/trailblazer), hence the name Trailblazer-Finder.

#### Operation Example using Finder Macro
```ruby
class Post::Index < Trailblazer::Operation
  # Runs a Trailblazer Task with a Finder object
  # Params:
  # +finder_class+:: Finder class to be used
  # +action+:: :all, :single (optional, defaults to :all)
  # +entity+:: Entity/Model or array (optional if specified in Finder Class, overwrites Finder class entity)
  step Finder(Post::Finder, :all, Post)
end
```

#### Operation Example using custom step
```ruby
class Post::Index < Trailblazer::Operation
  step :finder!

  # Find all matching results and extend model object with required methods
  def finder!(options, params:, **)
    options[:finder] = Post::Finder.new(params: params)
  end

  # Find first matching row, no method extension on model object
  def single_finder!(options, params:, **)

    # Since ID's are usually given directly, patch it into filter
    apply_id(params)

    # No paging, sorting, no methods and only returns the first matched result
    options[:finder] = Post::Finder.new(params: params).result.first
  end

  # Since ID's are usually given directly, patch it into filter
  def apply_id(params)
    return if params[:id].nil?
    params[:id_eq] = params[:id] unless params.key?("id")
  end
end
```

When using this, result[:finder] will be extended with (not available for :single row)
```ruby
# accessing results
.count                                   # => number of found results
.result?                                # => are there any results found
.result                                 # => fetched results

# params for url generations
.params                                  # => filter values
```


### Usable without Trailblazer
It's not really tied to [Trailblazer](https://github.com/trailblazer/trailblazer), you can actually use it anywhere by calling the below example directly.
If Trailblazer isn't loaded, the ties to [Trailblazer](https://github.com/trailblazer/trailblazer) won't be executed.

#### Example without Trailblazer
```ruby
# If entity is specified in your finder
result = Post::Finder.new(params: params)

# If entity ism't specified in your finder
result = Post::Finder.new(entity: Post, params: params)
```

When using this, result will be extended with (not available for :single row)
```ruby
# accessing results
.count                                   # => number of found results
.result?                                # => are there any results found
.result                                 # => fetched results

# params for url generations
.params                                  # => filter values
```

### Example Project
Coming soon!

## Features
Aside of the default filtering behavior, it offers the following optional features as well.

NOTE: FEATURES NEED TO BE SPECIFIED ON TOP OF YOUR CLASS

### Predicates
Simple predicate feature, that enables you to have default predicate filters available for the specified fields.

At the moment we support:
- eq: equals to
- not_eq: not equals to
- blank: blank (empty/nil/nul)
- not_blank: not blank (empty/nil/null)
- lt: less than (value converts to float)
- lte: less than or equal to (value converts to float)
- gt: greater than (value converts to float)
- gte: greater than or equal to (value converts to float)
- cont: contains specified value
- not_cont: does not contain specified value
- sw: starts with specified value
- not_sw: does not start with specified value
- ew: end with specified value
- not_ew: does not end with specified value

#### Predicates Example
```ruby
class Post::Finder < Trailblazer::Finder
  entity { Post }

  property :id, type: Types::Integer
  property :body, type: Types::String
  property :title, type: Types::String
end
```

This feature extends the result[:finder] object with the following methods
```ruby
# Available Predicate filters with the above example
id_eq            # => id equals value
id_not_eq        # => id not equals value
id_blank         # => id blank value
id_not_blank     # => id not blank value
id_lt            # => id less than value (converts value to float)
id_lte           # => id less than or equal to value (converts value to float)
id_gt            # => id greater than value (converts value to float)
id_gte           # => id greater than or equal to value (converts value to float)
id_cont          # => id contains value
id_not_cont      # => id does not contain value
id_sw            # => id starts with
id_not_sw        # => id does not start with
id_ew            # => id ends with
id_not_ew        # => id does not end with

body_eq            # => body equals value
body_not_eq        # => body not equals value
body_blank         # => body blank value
body_not_blank     # => body not blank value
body_lt            # => body less than value (converts value to float)
body_lte           # => body less than or equal to value (converts value to float)
body_gt            # => body greater than value (converts value to float)
body_gte           # => body greater than or equal to value (converts value to float)
body_cont          # => body contains value
body_not_cont      # => body does not contain value
body_sw            # => body starts with
body_not_sw        # => body does not start with
body_ew            # => body ends with
body_not_ew        # => body does not end with

title_eq            # => title equals value
title_not_eq        # => title not equals value
title_blank         # => title blank value
title_not_blank     # => title not blank value
title_lt            # => title less than value (converts value to float)
title_lte           # => title less than or equal to value (converts value to float)
title_gt            # => title greater than value (converts value to float)
title_gte           # => title greater than or equal to value (converts value to float)
title_cont          # => title contains value
title_not_cont      # => title does not contain value
title_sw            # => title starts with
title_not_sw        # => title does not start with
title_ew            # => title ends with
title_not_ew        # => title does not end with
```

### Paging
Really simple pagination feature, which uses the plain ```.limit``` and ```.offset``` methods.

#### Paging Example
```ruby
class Post::Finder < Trailblazer::Finder
  entity { Post }

  paging per_page: 5, min_per_page: 1, max_per_page: 100
end
```

### Sorting
Really simple sorting feature, fixing the pain of dealing with sorting attributes and directions. Can sort by multiple columns/directions.

#### Sorting Example
```ruby
class Post::Finder < Trailblazer::Finder
  entity { Post }

  # Property
  # Set the properties with their respective options
  #
  # Params:
  #  * +name+::         The property name (attribute /column / field - name) (required)
  #  * +type:+::         Dry Types type, for future validations (required)
  #
  #  * Following is optional (don't use it if you do not wish to use sorting)
  #    * +sortable:+::       Can this property be sorted on? (default: false)
  #    * +sort_direction:+:: Specify default sort direction (only usable if sortable is true)
  #                          (default: :desc)
  property :id, type: Types::Integer
  property :body, type: Types::String, sortable: true
  property :title, type: Types::String, sortable: true, sort_direction: :asc
end
```

This feature extends the result[:finder] object with the following methods
```ruby
.result                                # => Posts sorted by title DESC

# Smart sort checking
.sort?('title')                         # => true

# Helpers for seeing current sort direction
.sort_direction_for('title')            # => 'asc'
.sort_direction_for('body')           # => 'desc'

# Helpers for seeing reversing sort direction
.reverse_sort_direction_for('title')            # => 'desc'
.reverse_sort_direction_for('body')          # => 'asc'

# Params for sorting links (new if none exists, existing params if exists)
.sort_params_for('title')

# Add Params for sorting links (add to existing / replace with different direction if exists)
.add_sort_params_for('title')

# Remove Params for sorting links (remove from existing)
.remove_sort_params_for('title')

# New Params for sorting links (reset)
.new_sort_params_for('title')
```

## Adapters
By default, everything works with an array of hashes. You can change the default behaviour by using adapters.

Currently supported ORM's:
* [ActiveRecord](https://github.com/rails/rails/tree/master/activerecord)
* [Sequel](https://github.com/jeremyevans/sequel)

You can specify the adapters you wish to use inside your enherited Finder class.

### Adapters Example
```ruby
class Post::Finder < Trailblazer::Finder
  adapter "ActiveRecord"
end
```

### ActiveRecord
The only thing the [ActiveRecord](https://github.com/rails/rails/tree/master/activerecord) adapter does, is overwrite one specific method for Paging (limit/offset) and Sorting (order) each, as well as change the default filter behaviour (from select to where). These are overwritten by the adapter to match the specific use case of [ActiveRecord](https://github.com/rails/rails/tree/master/activerecord).

#### Active Record Example
```ruby
class Post::Finder < Trailblazer::Finder
  adapter "ActiveRecord"
end
```

### Sequel
The only thing the [Sequel](https://github.com/jeremyevans/sequel) adapter does, is overwrite one specific method for Paging (limit/offset) and Sorting (order) each, as well as change the default filter behaviour (from select to where). These are overwritten by the adapter to match the specific use case of [Sequel](https://github.com/jeremyevans/sequel).

#### Sequel Example
```ruby
class Post::Finder < Trailblazer::Finder
  adapter "Sequel"
end
```

## Tips & Tricks
### ORM's are not required
Not even for the Paging, Predicates and Sorting features.

```ruby
class Post::Finder < Trailblazer::Finder
  entity { fetch_product_as_hashes }

  filter_by(:name)     { |entity, _attribute, value| entity.select { |product| product[:name] == value } }
  filter_by(:category) { |entity, _attribute, value| entity.select { |product| product[:category] == value } }
end
```

### Overwriting Methods
You can have fine grained entity, by overwriting ```initialize``` method:

```ruby
class Post::Finder < Trailblazer::Finder
  property :name, type: Types::String

  def initialize(options = {})
    super options.merge(entity: Product.visible_to(user))
  end
end
```

You can have fine grained result set, by overwriting ```fetch_result``` method:

```ruby
class Post::Finder < Trailblazer::Finder
  property :name, type: Types::String

  def fetch_result
    super
    result.merge! test: "I added this"
  end
end
```

## Contributing
1. Fork it
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Run the tests (`rake`)
6. Make sure all tests pass, rubocop has no offenses and coverage is 100%
7. Create new Pull Request

## Bugs
Please report them on the [Github issue tracker](http://github.com/trailblazer/trailblazer-finder) for this project.

If you have a bug to report, please include the following information:

* **Version information for Trailblazer-Finder, Trailblazer, used Adapters and Ruby.**
* Full stack trace and error message (if you have them).
* Any snippets of relevant model, view or controller code that shows how you are using Trailblazer-Finder.

If you are able to, it helps even more if you can fork Trailblazer-Finder on Github,
and add a test that reproduces the error you are experiencing.

For more info on how to report bugs, please see [this article](http://yourbugreportneedsmore.info/).
