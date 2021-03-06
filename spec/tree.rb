shared_context 'example tree' do
  let!(:foo) { described_class.create!(name: 'foo') }
  let!(:bar) { described_class.create!(name: 'bar') }
  let!(:qux) { bar.children.create!(name: 'qux') }
  let!(:baz) { bar.children.create!(name: 'baz') }
  let!(:quux) { qux.children.create!(name: 'quux') }

  def reload_items
    [ foo, bar, baz, qux, quux ].each(&:reload)
  end

  before do
    reload_items
  end
end

shared_examples 'adjacency list' do
  include_context 'example tree'

  describe '.tree' do
    it 'arranges tree to hash' do
      expect(described_class.tree).to be_arranged_like({
        foo => {},
        bar => {
          qux => {
            quux => {}
          },
          baz => {}
        }
      })
    end

    it 'allows custom order' do
      expect(described_class.alphabetic.tree).to be_arranged_like({
        bar => {
          baz => {},
          qux => {
            quux => {}
          }
        },
        foo => {}
      })
    end
  end

  describe '.flat_tree' do
    it 'arranges tree to array' do
      expect(described_class.flat_tree).to eq([
        foo,
        bar,
          qux,
            quux,
          baz
      ])
    end

    it 'allows custom order' do
      expect(described_class.alphabetic.flat_tree).to eq([
        bar,
          baz,
          qux,
            quux,
        foo
      ])
    end
  end

  describe '.roots' do
    it 'returns roots' do
      expect(described_class.roots).to match_array([ foo, bar ])
    end
  end

  describe '#move_children_to_parent' do
    it 'changes children parent' do
      bar.move_children_to_parent

      expect(described_class.tree).to be_arranged_like({
        foo => {},
        bar => {},
        qux => {
          quux => {}
        },
        baz => {}
      })
    end
  end

  describe '#root?' do
    it 'returns true if node has parent' do
      expect(bar).to be_root
      expect(baz).not_to be_root
    end
  end

  describe '#leaf?' do
    it 'returns true if node does not have children' do
      expect(quux).to be_leaf
      expect(qux).not_to be_leaf
    end
  end

  describe '#parent_of?' do
    it 'returns true if node is a parent of given node' do
      expect(bar).to be_parent_of(qux)
      expect(bar).not_to be_parent_of(quux)
    end
  end

  describe '#child_of?' do
    it 'returns true if node is a child of given node' do
      expect(qux).to be_child_of(bar)
      expect(qux).not_to be_child_of(quux)
    end
  end

  describe '#sibling_of?' do
    it 'returns true if both nodes have same parent' do
      expect(foo).to be_sibling_of(bar)
      expect(baz).to be_sibling_of(qux)
      expect(foo).not_to be_sibling_of(qux)
    end
  end
end

shared_examples 'materialized path' do
  include_context 'example tree'
  it_behaves_like 'adjacency list'

  describe '.find_by_path' do
    it 'returns node' do
      expect(described_class.find_by_path('bar')).to eq(bar)
      expect(described_class.find_by_path('bar/qux')).to eq(qux)
      expect(described_class.find_by_path('/bar/qux')).to eq(qux)
      expect(described_class.find_by_path('/bar/qux/')).to eq(qux)
      expect(described_class.find_by_path('bar/qux/quux')).to eq(quux)
    end
  end

  describe '.find_by_path!' do
    it 'returns node or raises RecordNotFound' do
      expect(described_class.find_by_path!('bar/qux/')).to eq(qux)
      expect{ described_class.find_by_path!('wrong') }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#full_path' do
    it 'returns full node path' do
      expect(bar.full_path).to eq('bar')
      expect(qux.full_path).to eq('bar/qux')
      expect(quux.full_path).to eq('bar/qux/quux')
    end
  end

  describe '#root' do
    it 'returns first node ancestor' do
      expect(baz.root).to eq(bar)
    end

    it 'returns nil if node is a root' do
      expect(bar.root).to be nil
    end
  end

  describe '#ancestors' do
    it 'returns node ancestors' do
      expect(quux.ancestors).to match_array([ qux, bar ])
      expect(qux.ancestors).to match_array([ bar ])
      expect(bar.ancestors).to be_empty
    end
  end

  describe '#descendants' do
    it 'returns node descendants' do
      expect(bar.descendants).to match_array([ qux, quux, baz ])
      expect(qux.descendants).to match_array([ quux ])
      expect(quux.descendants).to be_empty
    end
  end

  describe '#subtree' do
    it 'returns node with descendants' do
      expect(qux.subtree.tree).to be_arranged_like({
        qux => {
          quux => {}
        }
      })
    end

    it 'returns node if node is a leaf' do
      expect(baz.subtree).to eq([ baz ])
    end
  end

  describe '#root_of?' do
    it 'returns true of node is a root of given node' do
      expect(bar).to be_root_of(qux)
      expect(bar).to be_root_of(quux)
      expect(bar).not_to be_root_of(bar)
      expect(bar).not_to be_root_of(foo)
    end
  end

  describe '#ancestor_of?' do
    it 'returns true if node is an ancestors of given node' do
      expect(bar).to be_ancestor_of(qux)
      expect(bar).to be_ancestor_of(quux)
      expect(bar).not_to be_ancestor_of(bar)
      expect(bar).not_to be_ancestor_of(foo)
    end
  end

  describe '#descendant_of?' do
    it 'returns true if node is a descendant of given node' do
      expect(quux).to be_descendant_of(qux)
      expect(quux).to be_descendant_of(bar)
      expect(quux).not_to be_descendant_of(quux)
      expect(quux).not_to be_descendant_of(foo)
    end
  end

  describe '#depth' do
    it 'returns ancestors count' do
      expect(bar.depth).to eq(0)
      expect(qux.depth).to eq(1)
      expect(quux.depth).to eq(2)
    end
  end

  describe 'node id column change' do
    before do
      bar.name = 'bor'
      bar.save!
    end

    it 'updates children pathes' do
      expect(described_class.find_by_path('bor')).to eq(bar)
      expect(described_class.find_by_path('bor/qux')).to eq(qux)
      expect(described_class.find_by_path('bor/qux/quux')).to eq(quux)
    end
  end

  describe 'parent change' do
    let(:prev_parent) { bar }
    let(:new_parent) { foo }
    let(:new_ancestors) { [ foo ] }

    before do
      qux.parent = new_parent
      qux.save!
      reload_items
    end

    it 'updates counter cache' do
      expect(prev_parent.children_count).to eq(prev_parent.children.count)
      expect(new_parent.children_count).to eq(new_parent.children.count)

      new_parent.descendants.destroy_all
      new_parent.reload

      expect(new_parent.children_count).to eq(0)
    end

    it 'changes ancestors' do
      expect(qux.ancestors).to match_array(new_ancestors)
    end

    it 'applies to all descendants' do
      qux.children.each do |child|
        expect(child).to be_descendant_of(new_parent)
      end
    end
  end
end

shared_examples 'tree with cached depth' do
  include_context 'example tree'
  it_behaves_like 'adjacency list'

  it 'stores node level' do
    expect(described_class.where(depth: 0)).to match_array([ foo, bar ])

    expect(described_class.where(depth: 1...3).tree).to be_arranged_like({
      qux => {
        quux => {}
      },
      baz => {}
    })
  end
end

shared_examples 'scoped tree' do
  let!(:foo) { described_class.create!(name: 'foo', category: 'foo') }
  let!(:bar) { described_class.create!(name: 'bar', category: 'bar') }

  it 'restricts scope' do
    expect(bar.siblings).to be_empty
  end
end

shared_examples 'ordered tree' do
  include_context 'example tree'

  before(:each) do
    quux.move_after(foo)
    reload_items
  end

  describe '#previous_siblings' do
    it 'returns siblings with smaller position' do
      expect(bar.previous_siblings).to match_array([ foo, quux ])
    end
  end

  describe '#next_siblings' do
    it 'returns siblings with greater position' do
      expect(foo.next_siblings).to match_array([ quux, bar ])
    end
  end

  it '#move_after' do
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
      baz => {},
      quux => {},
      bar => {
        qux => {}
      }
    })
  end
end
