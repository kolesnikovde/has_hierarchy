require 'spec_helper'

shared_examples 'ordered tree' do
  let!(:foo) { described_class.create!(name: 'foo') }
  let!(:bar) { described_class.create!(name: 'bar') }
  let!(:qux) { bar.children.create!(name: 'qux') }
  let!(:baz) { bar.children.create!(name: 'baz') }
  let!(:quux) { qux.children.create!(name: 'quux') }

  def reload_items
    [ foo, bar, baz, qux, quux ].each(&:reload)
  end

  it do
    expect(described_class.tree).to be_arranged_like({
      foo => {},
      bar => {
        qux => {
          quux => {},
        },
        baz => {}
      }
    })
  end

  it '#move_after' do
    quux.move_after(foo)
    reload_items

    expect(described_class.ordered.tree).to be_arranged_like({
      foo => {},
      quux => {},
      bar => {
        qux => {},
        baz => {}
      }
    })
  end

  it '#move_before' do
    baz.move_before(quux)
    reload_items

    expect(described_class.ordered.tree).to be_arranged_like({
      foo => {},
      bar => {
        qux => {
          baz => {},
          quux => {},
        }
      }
    })
  end
end

describe Item do
  it_behaves_like 'ordered tree'
end
