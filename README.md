# THIS IS MOSTLY OUT OF DATE

# NEW README AND RELEASE COMING NEXT WEEK

# Trailblazer Finder

Provides DSL for creating [Trailblazer](https://github.com/trailblazer/trailblazer) based Finder Objects. But it is designed to be used on its own as a separate gem. It was influenced by popular [Ransack](https://github.com/activerecord-hackery/ransack) gem, but in addition to [ActiveRecord](https://github.com/rails/rails/tree/master/activerecord), it can be used with [DataMapper](https://github.com/datamapper) or [Sequel](https://github.com/jeremyevans/sequel). It also integrates with [Kaminari](https://github.com/kaminari/kaminari) or [Will Paginate](https://github.com/mislav/will_paginate), as well as [FriendlyId](https://github.com/norman/friendly_id)

[![Gitter Chat](https://badges.gitter.im/trailblazer/chat.svg)](https://gitter.im/trailblazer/chat) [![Build Status](https://secure.travis-ci.org/trailblazer/trailblazer-finder.svg)](https://travis-ci.org/trailblazer/trailblazer-finder) [![Coverage Status](https://coveralls.io/repos/github/trailblazer/trailblazer-finder/badge.svg?branch=master)](https://coveralls.io/github/trailblazer/trailblazer-finder?branch=master)

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
  adapters ActiveRecord

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
    options[:finder] = Post::Finder.new(filter: params['f'], page: params['page'], per_page: params['per_page'])
  end

  # Find first matching row, no method extension on model object
  def single_finder!(options, params:, **)

    # Since ID's are usually given directly, patch it into filter
    apply_id(params)

    # No paging, sorting, no methods and only returns the first matched result
    options[:finder] = Post::Finder.new(filter: params['f']).results.first
  end

  # Since ID's are usually given directly, patch it into filter
  def apply_id(params)
    return if params[:id].nil?
    params[:f] = {} unless params.key?('f')
    params[:f][:id] = params[:id] unless params[:f].key?('id')
  end
end
```

When using this, result[:finder] will be extended with (not available for :single row)
```ruby
# accessing filters
.name                                    # => name filter
.created_at                              # => created at filter

# accessing results
.count                                   # => number of found results
.results?                                # => are there any results found
.results                                 # => fetched results

# params for url generations
.params                                  # => filter values
.params published: false                 # => overwrites the 'published' filter
```


### Usable without Trailblazer
It's not really tied to [Trailblazer](https://github.com/trailblazer/trailblazer), you can actually use it anywhere by calling the below example directly.
If Trailblazer isn't loaded, the ties to [Trailblazer](https://github.com/trailblazer/trailblazer) won't be executed.

#### Example without Trailblazer
```ruby
result = Post::Finder.new(filter: params[:f], page: params[:page], per_page: params[:per_page])
```

When using this, result will be extended with (not available for :single row)
```ruby
# accessing filters
.name                                    # => name filter
.created_at                              # => created at filter

# accessing results
.count                                   # => number of found results
.results?                                # => are there any results found
.results                                 # => fetched results

# params for url generations
.params                                  # => filter values
.params published: false                 # => overwrites the 'published' filter
```

### Example Project
Coming soon!

## Features
Aside of the default filtering behavior, it offers the following optional features as well.

Just for the record, you can comma seperate features and load multiple by doing
```ruby
features Sorting, Paging, Predicate
```

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

#### Predicates Example
```ruby
class Post::Finder < Trailblazer::Finder
  features Predicate

  # Specify the fields you want predicates enabled for, mind you these fields need to exist on your entity
  predicates_for :name, :category_name

  filter_by :name
  filter_by :published
  filter_by :category_name

  # per page defaults to 25 (so not required)
  per_page 10

  # Minimum items per page (not required)
  min_per_page 5

  # Maximum items per page (not required)
  max_per_page 100
end
```

This feature extends the result[:finder] object with the following methods
```ruby
# accessing filters
.name             # => name filter
.created_at           # => created at filter

# Predicate filters
.name_eq            # => name equals filter
.name_not_eq          # => name not equals filter
.name_blank           # => name blank filter
.name_not_blank         # => name not blank filter
.name_lt            # => name less than filter (converts value to float)
.name_lte           # => name less than or equal to filter (converts value to float)
.name_gt            # => name greater than filter (converts value to float)
.name_gte           # => name greater than or equal to filter (converts value to float)
.category_name_eq       # => category name equals filter
.category_name_not_eq     # => category name not equals filter
.category_name_blank      # => category name blank filter
.category_name_not_blank    # => category name not blank filter
.category_name_lt       # => category name less than filter (converts value to float)
.category_name_lte        # => category name less than or equal to filter (converts value to float)
.category_name_gt       # => category name greater than filter (converts value to float)
.category_name_gte        # => category name greater than or equal to filter (converts value to float)

# accessing results
.count              # => number of found results
.results?           # => are there any results found
.results            # => fetched results
.all              # => if needed, use it to get dataset (sequel for example requires you use it in some cases)

# params for url generations
.params             # => filter values
.params published: false    # => overwrites the 'published' filter
```

### Paging
Really simple pagination feature, which uses the plain ```.limit``` and ```.offset``` methods.

#### Paging Example
```ruby
class Post::Finder < Trailblazer::Finder
  features Paging

  filter_by :name
  filter_by :category_name

  # per page defaults to 25 (so not required)
  per_page 10

  # Minimum items per page (not required)
  min_per_page 5

  # Maximum items per page (not required)
  max_per_page 100
end
```

This feature extends the result[:finder] object with the following methods
```ruby
.page                                    # => page number
.per_page                                # => per page (10)
.results                                 # => paginated page results
```

### Sorting
Really simple sorting feature, fixing the pain of dealing with sorting attributes and directions. Can sort by multiple columns/directions.

#### Sorting Example
```ruby
class Post::Finder < Trailblazer::Finder
  features Sorting

  sortable_by :name, :body
end
```

This feature extends the result[:finder] object with the following methods
```ruby
.results                                # => Posts sorted by title DESC

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

# Add Params for sorting links (add to existing / replace with different direction)
.add_sort_params_for('title')

# New Params for sorting links (reset)
.new_sort_params_for('title')
```

## Adapters
By default, everything works with an array of hashes. You can change the default behaviour by using adapters. Adapters are not just tied to the ORM's, we also have a few adapters included that make it easier to work along with existing gems such as [Kaminari](https://github.com/kaminari/kaminari), [WillPaginate](https://github.com/mislav/will_paginate/) and [FriendlyId](https://github.com/norman/friendly_id).

Currently supported ORM's:
* [ActiveRecord](https://github.com/rails/rails/tree/master/activerecord)
* [DataMapper](https://github.com/datamapper)
* [Sequel](https://github.com/jeremyevans/sequel)

You can specify the adapters you wish to use inside your enherited Finder class.

### Adapters Example
```ruby
class Post::Finder < Trailblazer::Finder
  # Features, in case you use any, need to be specified before adapters
  adapters ActiveRecord, Kaminari, FriendlyId
end
```

### ActiveRecord
The only thing the [ActiveRecord](https://github.com/rails/rails/tree/master/activerecord) adapter does, is overwrite one specific method for Paging (limit/offset) and Sorting (order) each, as well as change the default filter behaviour (from select to where). These are overwritten by the adapter to match the specific use case of [ActiveRecord](https://github.com/rails/rails/tree/master/activerecord).

#### Active Record Example
```ruby
class Post::Finder < Trailblazer::Finder
  # Features, in case you use any, need to be specified before adapters
  adapters ActiveRecord
end
```

### Sequel
The only thing the [Sequel](https://github.com/jeremyevans/sequel) adapter does, is overwrite one specific method for Paging (limit/offset) and Sorting (order) each, as well as change the default filter behaviour (from select to where). These are overwritten by the adapter to match the specific use case of [Sequel](https://github.com/jeremyevans/sequel).

#### Sequel Example
```ruby
class Post::Finder < Trailblazer::Finder
  # Features, in case you use any, need to be specified before adapters
  adapters Sequel
end
```

## Tips & Tricks
### ORM's are not required
Not even for the Paging, Predicates and Sorting features.

```ruby
class Post::Finder < Trailblazer::Finder
  # Features, in case you use any, need to be specified before adapters
  entity { fetch_product_as_hashes }

  filter_by(:name)     { |entity, value| entity.select { |product| product[:name] == value } }
  filter_by(:category) { |entity, value| entity.select { |product| product[:category] == value } }
end
```

### Overwriting Methods
You can have fine grained entity, by overwriting ```initialize``` method:

```ruby
class Post::Finder < Trailblazer::Finder
  # Features, in case you use any, need to be specified before adapters

  filter_by :name
  filter_by :category_name

  def initialize(user, options = {})
    super options.merge(entity: Product.visible_to(user))
  end
end
```

### Utils / Helpers
Coming soon

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
