[![Gem Version](https://badge.fury.io/rb/has_hierarchy.svg)](http://badge.fury.io/rb/has_hierarchy)

# has_hierarchy

Provides sortable tree behavior to active_record models.

## Installation

Add this line to your application's Gemfile:

    gem 'has_hierarchy'

And then execute:

    $ bundle

## Usage

  $ rails g migration Item name:string \
                           parent:belongs_to \
                           position:string \
                           node_path:string

```ruby
class Item < ActiveRecord::Base
  has_hierarchy
end

foo = Item.create!(name: 'foo')
bar = Item.create!(name: 'bar')
qux = bar.children.create!(name: 'qux')
baz = bar.children.create!(name: 'baz')
quux = qux.children.create!(name: 'quux')

Item.tree
# {
#   foo => {},
#   bar => {
#     qux => {
#       quux => {}
#     },
#     baz => {}
#   }
# }

foo.move_after(quux)

Item.tree
# {
#   bar => {
#     qux => {
#       quux => {},
#       foo => {}
#     },
#     baz => {}
#   }
# }

```

See [has_children](https://github.com/kolesnikovde/has_children) and
[has_order](https://github.com/kolesnikovde/has_order) for details.

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
