require 'spec_helper'

describe HasHierarchy do
  before(:each) do
    @foo = Item.create!(name: 'foo')
    @bar = Item.create!(name: 'bar')

    @qux = @bar.children.create!(name: 'qux')
    @baz = @bar.children.create!(name: 'baz')

    @quux = @qux.children.create!(name: 'quux')
  end

  it do
    expect(Item.tree).to be_arranged_like({
      @foo => {},
      @bar => {
        @qux => {
          @quux => {},
        },
        @baz => {}
      }
    })
  end

  it '#move_after' do
    @quux.move_after(@foo)

    [@foo, @bar, @baz, @qux, @quux].each(&:reload)

    expect(Item.ordered.tree).to be_arranged_like({
      @foo => {},
      @quux => {},
      @bar => {
        @qux => {},
        @baz => {}
      }
    })
  end

  it '#move_before' do
    @baz.move_before(@quux)

    [@foo, @bar, @baz, @qux, @quux].each(&:reload)

    expect(Item.ordered.tree).to be_arranged_like({
      @foo => {},
      @bar => {
        @qux => {
          @baz => {},
          @quux => {},
        }
      }
    })
  end
end
