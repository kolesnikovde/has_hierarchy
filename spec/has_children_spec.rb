require 'spec_helper'

describe HasChildren do
  before(:each) do
    @foo = Item.create!(name: 'foo', category: 'foo')
    @bar = Item.create!(name: 'bar', category: 'bar')
    @qux = @bar.children.create!(name: 'qux', category: 'bar')
    @baz = @bar.children.create!(name: 'baz')
    @quux = @qux.children.create!(name: 'quux')

    @bar.reload
    @qux.reload
  end

  describe 'node path column' do
    it 'defaults to "node_path"' do
      expect(Item.node_path_column).to eq(:node_path)
    end
  end

  describe '.tree' do
    it 'arranges tree' do
      expect(Item.tree).to be_arranged_like({
        @foo => {},
        @bar => {
          @qux => {
            @quux => {}
          },
          @baz => {}
        }
      })
    end

    it 'allows custom order' do
      expect(Item.alphabetic.tree).to be_arranged_like({
        @bar => {
          @baz => {},
          @qux => {
            @quux => {}
          }
        },
        @foo => {}
      })
    end
  end

  describe '.roots' do
    it 'returns roots' do
      expect(Item.roots).to match_array([ @foo, @bar ])
    end
  end

  describe '#move_children_to_parent' do
    subject { @bar }

    before { @bar.move_children_to_parent }

    it 'changes children parent' do
      expect(Item.tree).to be_arranged_like({
        @foo => {},
        @bar => {},
        @qux => {
          @quux => {}
        },
        @baz => {}
      })
    end
  end

  context 'root' do
    subject { @bar }

    let(:siblings) { [ @foo ] }
    let(:children) { [ @baz, @qux ] }
    let(:descendant) { @quux }
    let(:descendants) { children + [ descendant ] }

    it { should_not be_leaf }
    it { should be_root }

    its(:depth) { should be_zero }

    its(:root_id) { should be_nil }

    its(:root) { should be_nil }

    its(:parent) { should be_nil }

    its(:children) { should match_array(children) }

    its(:ancestors) { should be_empty }

    its(:siblings) { should match_array(siblings) }

    its(:descendants) { should match_array(descendants) }

    describe '#subtree' do
      it 'includes descendants' do
        subtree_items = subject.subtree

        descendants.each do |descendant|
          expect(subtree_items).to include(descendant)
        end
      end

      it 'includes self' do
        expect(subject.subtree).to include(subject)
      end
    end

    [ :root_of?, :ancestor_of? ].each do |method|
      describe "##{method}" do
        it 'true for child' do
          expect(subject.send(method, children.first)).to be_true
        end

        it 'true for descendant' do
          expect(subject.send(method, descendant)).to be_true
        end
      end
    end

    describe '#parent_of?' do
      it 'true for child' do
        expect(subject.parent_of?(children.first)).to be_true
      end
    end

    describe '#sibling_of?' do
      it 'true for siblings' do
        siblings.each do |sibling|
          expect(subject.sibling_of?(sibling)).to be_true
        end
      end

      it 'false for self' do
        expect(subject.sibling_of?(subject)).to be_false
      end
    end

    describe '#descendant_of?' do
      it 'false for self' do
        expect(subject.descendant_of?(subject)).to be_false
      end

      it 'false for child' do
        expect(subject.descendant_of?(children.first)).to be_false
      end
    end
  end

  context 'leaf' do
    subject { @quux }

    let(:root) { @bar }
    let(:parent) { @qux }
    let(:ancestors) { [ @bar, @qux ] }

    it { should be_leaf }
    it { should_not be_root }

    its(:root_id) { should eq(root.id) }

    its(:root) { should eq(root) }

    its(:depth) { should eq(ancestors.count) }

    its(:parent) { should eq(parent) }

    its(:children) { should be_empty }

    its(:ancestors) { should eq(ancestors) }

    its(:descendants) { should be_empty }

    its(:subtree) { should eq([ subject ]) }

    [ :root_of?, :ancestor_of?, :parent_of? ].each do |method|
      describe "##{method}" do
        it 'false for self' do
          expect(subject.send(method, subject)).to be_false
        end

        it 'false for ancestors' do
          expect(subject.send(method, root)).to be_false
          expect(subject.send(method, parent)).to be_false
        end
      end
    end

    describe '#descendant_of?' do
      it 'true for parent' do
        expect(subject.descendant_of?(parent)).to be_true
      end

      it 'true for ancestor' do
        expect(subject.descendant_of?(root)).to be_true
      end
    end
  end

  describe 'root association' do
    it 'can be preloaded' do
      item = Item.includes(:root).first

      expect(item.association(:root)).to be_loaded
    end
  end

  describe 'parent change' do
    subject { @baz }

    let(:prev_parent) { @baz.parent }
    let(:new_parent) { @foo }
    let(:new_ancestors) { [ @foo ] }

    before do
      subject.parent = new_parent
      subject.save!
    end

    it 'updates counter_cache' do
      prev_parent.reload
      new_parent.reload

      expect(prev_parent.children_count).to eq(prev_parent.children.count)
      expect(new_parent.children_count).to eq(new_parent.children.count)
    end

    it 'changes ancestors' do
      expect(subject.ancestors).to eq(new_ancestors)
    end

    it 'applies to all descendants' do
      subject.children.each do |c|
        expect(c.descendant_of?(new_parent)).to be_true

        c.children.each do |cc|
          expect(cc.descendant_of?(new_parent)).to be_true
        end
      end
    end
  end

  describe 'scoping' do
    shared_examples 'scoped' do
      its(:siblings) { should be_empty }
    end

    describe 'via attributes' do
      before(:all) do
        Item.has_children scope: :category
      end

      subject { @bar }

      it_behaves_like 'scoped'
    end

    describe 'via proc' do
      before(:all) do
        Item.has_children scope: ->(i){ Item.where(category: i.category) }
      end

      subject { @bar }

      it_behaves_like 'scoped'
    end
  end
end
