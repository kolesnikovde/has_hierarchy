[![Gem Version](https://badge.fury.io/rb/has_children.svg)](http://badge.fury.io/rb/has_children)
[![Build Status](https://api.travis-ci.org/kolesnikovde/has_children.svg)](https://travis-ci.org/kolesnikovde/has_children)
[![Code Climate](https://codeclimate.com/github/kolesnikovde/has_children/badges/gpa.svg)](https://codeclimate.com/github/kolesnikovde/has_children)
[![Test Coverage](https://codeclimate.com/github/kolesnikovde/has_children/badges/coverage.svg)](https://codeclimate.com/github/kolesnikovde/has_children)

# has_children

Provides tree behavior to active_record models.

## Installation

Add this line to your application's Gemfile:

    gem 'has_children'

And then execute:

    $ bundle

## Usage

Example tree:
```sh
$ rails g migration CreateItems \
    name:string \
    parent:belongs_to \
    node_path:string \
    children_count:integer
```
```ruby
class Item < ActiveRecord::Base
  # :scope            - optional, proc, symbol or an array of symbols.
  # :node_path_cache  - optional, column name or boolean (assumes :node_path if true), default true.
  # :node_id_column   - optional, column name, default :id.
  # :depth_cache      - optional, column name or boolean (assumes :depth if true), default false.
  # :counter_cache    - optional, :counter_cache option for parent association.
  # :dependent        - optional, :dependent option for children association.
  has_children node_id_column: :name,
               counter_cache: :children_count,
               dependent: :destroy
end

foo = Item.create!(name: 'foo')
bar = Item.create!(name: 'bar')
qux = bar.children.create!(name: 'qux')
baz = bar.children.create!(name: 'baz')
quux = qux.children.create!(name: 'quux')

Item.roots # => [ foo, bar ]
Item.tree  # => {
           #   foo => {},
           #   bar => {
           #     qux => {
           #       quux => {}
           #     },
           #     baz => {}
           #   }
           # }

Item.find_by_node_path('bar')          # => bar
Item.find_by_node_path('bar.qux')      # => qux
Item.find_by_node_path('bar.qux.quux') # => quux
```

Basic operations:
```ruby
foo.root?            # => true
foo.leaf?            # => false
bar.parent_of?(quux) # => false
bar.sibling_of?(foo) # => true
qux.child_of?(bar)   # => true
quux.root?           # => false
quux.leaf?           # => true
qux.parent           # => bar
bar.children         # => [ qux, baz ]
foo.siblings         # => [ bar ]
```

Node path cache is required for following methods:
```ruby
bar.root_of?(quux)      # => true
bar.ancestor_of?(quux)  # => true
qux.descendant_of?(bar) # => true
quux.root               # => bar
quux.ancestors          # => [ qux, bar ]
bar.descendants         # => [ qux, quux, baz ]
```

## License

Copyright (c) 2014 Kolesnikov Danil

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
