
# Trailblazer Finder

Description should come here

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
		* [Predicate](#predicate)
			* [Predicate Example](#predicate-example)
		* [Paging](#paging)
			* [Paging Example](#paging-example)
		* [Sorting](#sorting)
			* [Sorting Example](#sorting-example)
	* [Adapters](#adapters)
		* [Adapters Example](#adapters-example)
		* [ActiveRecord](#active_record)
			* [Active Record Example](#active-record-example)
		* [DataMapper](#data_mapper)
			* [Data Mapper Example](#data-mapper-example)
		* [Sequel](#sequel)
			* [Sequel Example](#sequel-example)
		* [Kaminari](#kaminari)
			* [Kaminari Example](#kaminari-example)
		* [WillPaginate](#will_paginate)
			* [Will Paginate Example](#will-paginate-example)
		* [FriendlyId](#friendly_id)
			* [Friendly Id Example](#friendly-id-example)
	* [Tips & Tricks](#tips--tricks)
	* [ORM's are not required](#results-shortcut)
	* [Passing Entity Type as Argument](#passing-entity_type-as-argument)
* [Contributing](#contributing)
* [License](#license)

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

NOTE: features only work if they're specified on top of your Finder class

An Entity Type is required, but can:
* be defined in the inherited Finder class
* be given as an option in the call

Basically for most use cases, Entity Type is the entity/model/array of hashes you wish to use finder on

#### Finder Example

```ruby
class Post::Finder < Trailblazer::Finder
	# Optional features
  features Paging, Sorting

  # Optional if you use it as option in the caller, Model/Entity or Array with Hashes
  entity_type { Post }

  # Without defining an ORM everything defaults to dealing with an
  # array with Hashes
  adapters ActiveRecord, Kaminari

  # Pagination settings (remove if not using the Paging feature)
  per_page 25
  min_per_page 10
  max_per_page 100

  # Sortable attributes (remove if not using the Sorting feature)
  sortable_by :id, :title, :created_at

  # Runs filter_by to filter results
  #
  # Params:
  #  * +attribute+::     The attribute to be filtered on
  #
  #  * Following is optional, matches exact value if not specified
  #    * +with:+::       Filter method defined in Finder class
  #    * +defined_by:+:: Array of filter Methods defined in Finder class
  #                      method name: apply_filter_name_with_array_value
  #    * block::         A block can be given with the code to filter with
  filter_by :id
  filter_by :body,              with: :apply_body_filter
  filter_by :created_after,     with: :apply_created_after
  filter_by :created_before,    with: :apply_created_before
  filter_by :is_hot,            defined_by: %i[true false]
  filter_by(:title)             { |entity_type, value| entity_type.where title: value }
  filter_by(:published, false)  do |entity_type, value|
     value ? entity_type.where('published = false') : entity_type.where('published = true')
  end

  private

  def apply_body_filter(entity_type, value)
    return unless value.present?
    entity_type.where 'lower(body) LIKE ?', Utils::Parse.term(value.downcase)
  end

  def apply_created_after(entity_type, value)
    entity_type.where('DATE(created_at) >= ?', value) if value.present?
  end

  def apply_created_before(entity_type, value)
    entity_type.where('DATE(created_at) <= ?', value) if value.present?
  end

  def apply_is_hot_with_true(entity_type)
    entity_type.where 'views > 100'
  end

  def apply_is_hot_with_false(entity_type)
    entity_type.where 'views < 100'
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
  # +entity_type+:: Entity/Model or array (optional if specified in Finder Class, overwrites Finder class entity_type)
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

### Predicate
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

#### Predicate Example
```ruby
class Post::Finder < Trailblazer::Finder
  features Predicate

  # Specify the fields you want predicates enabled for, mind you these fields need to exist on your entity_type
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
.name							# => name filter
.created_at						# => created at filter

# Predicate filters
.name_eq						# => name equals filter
.name_not_eq					# => name not equals filter
.name_blank 					# => name blank filter
.name_not_blank					# => name not blank filter
.name_lt						# => name less than filter (converts value to float)
.name_lte						# => name less than or equal to filter (converts value to float)
.name_gt						# => name greater than filter (converts value to float)
.name_gte						# => name greater than or equal to filter (converts value to float)
.category_name_eq				# => category name equals filter
.category_name_not_eq			# => category name not equals filter
.category_name_blank 			# => category name blank filter
.category_name_not_blank		# => category name not blank filter
.category_name_lt				# => category name less than filter (converts value to float)
.category_name_lte				# => category name less than or equal to filter (converts value to float)
.category_name_gt				# => category name greater than filter (converts value to float)
.category_name_gte				# => category name greater than or equal to filter (converts value to float)

# accessing results
.count							# => number of found results
.results?						# => are there any results found
.results						# => fetched results
.all 							# => if needed, use it to get dataset (sequel for example requires you use it in some cases)

# params for url generations
.params							# => filter values
.params published: false 		# => overwrites the 'published' filter
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

### DataMapper
The only thing the [DataMapper](https://github.com/datamapper) adapter does, is overwrite one specific method for Paging (limit/offset) and Sorting (order) each, as well as change the default filter behaviour (from select to where). These are overwritten by the adapter to match the specific use case of [DataMapper](https://github.com/datamapper).

#### Data Mapper Example
```ruby
class Post::Finder < Trailblazer::Finder
	# Features, in case you use any, need to be specified before adapters
  adapters DataMapper
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

### Kaminari
The only thing the [Kaminari](https://github.com/kaminari/kaminari) adapter does, is overwrite one specific method for Paging (limit/offset). These are overwritten by the adapter to match the specific use case of [Kaminari](https://github.com/kaminari/kaminari).

**Note**
Not usable without the Paging feature enabled, and requires an ORM that's supported by [Kaminari](https://github.com/kaminari/kaminari), directly or by using additional gems.

#### Kaminari Example
```ruby
class Post::Finder < Trailblazer::Finder
  features Paging
  adapters ActiveRecord, Kaminari
end
```
**Note**
To use [Kaminari](https://github.com/kaminari/kaminari) in combination with [Cells](https://github.com/trailblazer/cells), you'll currently have to use [kaminari-cells](https://github.com/apotonick/kaminari-cells) and monkey-patch Kaminari by using in an initiliazer:
```ruby
Kaminari::Helpers::Paginator.class_eval do
  def render(&block)
    instance_eval(&block) if @options[:total_pages] > 1
  end
end
```

### WillPaginate
The only thing the [WillPaginate](https://github.com/mislav/will_paginate/) adapter does, is overwrite one specific method for Paging (limit/offset). These are overwritten by the adapter to match the specific use case of [WillPaginate](https://github.com/mislav/will_paginate/).

**Note**
Not usable without the Paging feature enabled, and requires an ORM that's supported by [WillPaginate](https://github.com/mislav/will_paginate/), directly or by using additional gems.

#### Will Paginate Example
```ruby
class Post::Finder < Trailblazer::Finder
  features Paging
  adapters ActiveRecord, WillPaginate
end
```

### FriendlyId
The [FriendlyId](https://github.com/norman/friendly_id) adapter was written cause I personally use it a lot, as well as to show an example of what kind of adapters we could potentially write in the future to compliment the filters with.

Basically the [FriendlyId](https://github.com/norman/friendly_id) adapter adds the following filter, which automatically checks wether the id is an integer or slug and makes sure the right filter is applied on the row set:
```ruby
filter_by :id, with: :apply_slug_filter
```

**Note**
Currently only tested with ActiveRecord.

**Note**
Do not set a filter_by for id or slug when using this adapter.

#### Friendly Id Example
```ruby
class Post::Finder < Trailblazer::Finder
	# Features, in case you use any, need to be specified before adapters
  adapters ActiveRecord, FriendlyId
end
```

## Tips & Tricks
### ORM's are not required
Not even for the Paging and Sorting features, however using additional adapters such as Kaminari, WillPaginate and FriendlyId won't work well with this.

```ruby
class Post::Finder < Trailblazer::Finder
	# Features, in case you use any, need to be specified before adapters
  entity_type { fetch_product_as_hashes }

  filter_by(:name)     { |entity_type, value| entity_type.select { |product| product[:name] == value } }
  filter_by(:category) { |entity_type, value| entity_type.select { |product| product[:category] == value } }
end
```

### Overwriting Methods
You can have fine grained entity_type, by overwriting ```initialize``` method:

```ruby
class Post::Finder < Trailblazer::Finder
	# Features, in case you use any, need to be specified before adapters

  filter_by :name
  filter_by :category_name

  def initialize(user, options = {})
    super options.merge(entity_type: Product.visible_to(user))
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

## License
Copyright (c) 2018 Trailblazer GmbH and contributors, released under the MIT
license.

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
