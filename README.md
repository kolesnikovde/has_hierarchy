[![Gem Version](https://badge.fury.io/rb/has_hierarchy.svg)](http://badge.fury.io/rb/has_hierarchy)
[![Build Status](https://api.travis-ci.org/kolesnikovde/has_hierarchy.svg)](https://travis-ci.org/kolesnikovde/has_hierarchy)
[![Code Climate](https://codeclimate.com/github/kolesnikovde/has_hierarchy/badges/gpa.svg)](https://codeclimate.com/github/kolesnikovde/has_hierarchy)
[![Test Coverage](https://codeclimate.com/github/kolesnikovde/has_hierarchy/badges/coverage.svg)](https://codeclimate.com/github/kolesnikovde/has_hierarchy)

# has_hierarchy

Tree behavior for ActiveRecord models and Mongoid documents.

## Features

- Sophisticated adjacency list with optional materialized path, user sorting, depth cache and more.
- ActiveRecord 4.x and Mongoid 4.x support.
- Convenient scope-oriented API.

## Installation

Add this line to your application's Gemfile:

    gem 'has_hierarchy'

And then execute:

    $ bundle

## Usage

Example model:
```sh
$ rails g model Item \
  name:string \
  path:string \
  depth:integer \
  position:integer \
  parent:belongs_to \
  children_count:integer
```
```ruby
class Item < ActiveRecord::Base
  has_hierarchy path_part: :name,
                depth_cache: true,
                counter_cache: true,
                dependent: :destroy
end
```

or Mongoid document:
```ruby
class Item
  include Mongoid::Document
  include Mongoid::HasHierarchy

  has_hierarchy path_part: :name,
                depth_cache: true,
                counter_cache: true,
                dependent: :destroy

  field :name,  type: String
  field :path,  type: String
  field :depth, type: Fixnum, default: 0
  field :children_count, type: Fixnum, default: 0
end
```

Options:
```
scope          - optional, proc, symbol or an array of symbols.
order          - optional, column name or boolean, default :position.
path_cache     - optional, column name or boolean, default :path.
path_part      - optional, column name, default :id.
path_separator - optional, string, default '/'.
depth_cache    - optional, column name or boolean, default :depth.
counter_cache  - optional, column name or boolean, default :children_count.
dependent      - optional, :dependent option for children association.
```

Operations on the tree:
```ruby
foo = Item.create!(name: 'foo')
bar = Item.create!(name: 'bar')
qux = bar.children.create!(name: 'qux')
baz = bar.children.create!(name: 'baz')
quux = qux.children.create!(name: 'quux')

Item.roots
# => [ foo, bar ]

Item.ordered.tree
# => {
#   foo => {},
#   bar => {
#     qux => {
#       quux => {}
#     },
#     baz => {}
#   }
# }

Item.ordered.flat_tree
# => [ foo, bar, qux, quux, baz ]

quux = Item.find_by_path('bar/qux/quux')
# => quux
quux.full_path
# => 'bar/qux/quux'
```

Operations on nodes:
```ruby
bar.children         # => [ qux, baz ]
qux.parent           # => bar
foo.siblings         # => [ bar ]
bar.parent_of?(quux) # => false
qux.child_of?(bar)   # => true
bar.sibling_of?(foo) # => true
bar.root?            # => true
qux.leaf?            # => false
```

Ancestors/descendants (requires path_cache):
```ruby
bar.root_of?(quux)      # => true
bar.ancestor_of?(quux)  # => true
qux.descendant_of?(bar) # => true
quux.root               # => bar
quux.ancestors          # => [ qux, bar ]
bar.descendants         # => [ qux, quux, baz ]
```

Ordering (see [has_order](https://github.com/kolesnikovde/has_order)):
```ruby
bar.previous_siblings  # => [ foo ]
foo.next_siblings      # => [ bar ]

foo.move_after(quux)
Item.ordered.tree
# => {
#   bar => {
#     qux => {
#       quux => {},
#       foo => {}
#     },
#     baz => {}
#   }
# }
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
