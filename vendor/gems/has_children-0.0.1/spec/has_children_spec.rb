require 'spec_helper'

describe HasChildren do
  before(:each) do
    @foo = Item.create!(name: 'foo', category: 'foo')
    @bar = Item.create!(name: 'bar', category: 'bar')

    @qux = @bar.children.create!(name: 'qux')
    @baz = @bar.children.create!(name: 'baz')

    @quux = @qux.children.create!(name: 'quux')
  end

  let(:tree) do
    {
      @foo => {},
      @bar => {
        @qux => {
          @quux => {}
        },
        @baz => {}
      }
    }
  end

  let(:alphabetic_tree) do
    {
      @bar => {
        @baz => {},
        @qux => {
          @quux => {}
        }
      },
      @foo => {}
    }
  end

  let(:roots) do
    tree.keys
  end

  describe 'node path column' do
    it 'defaults to "node_path"' do
      expect(Item.node_path_column).to eq(:node_path)
    end
  end

  describe '.arrange_tree' do
    it 'arranges tree' do
      expect(Item.tree).to be_arranged_like(tree)
    end

    it 'allows custom order' do
      expect(Item.alphabetic.tree).to be_arranged_like(alphabetic_tree)
    end
  end

  describe '.roots' do
    it 'returns roots' do
      expect(Item.roots).to match_array(roots)
    end
  end

  context 'root' do
    subject { @bar }

    let(:siblings) { [ @foo ] }
    let(:children) { [ @baz, @qux ] }
    let(:descendant) { @quux }
    let(:descendants) { children + [ descendant ] }

    it { should be_root }

    its(:depth) { should be_zero }

    its(:root) { should eq(subject) }

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

    describe '#descendant_of?' do
      it 'false for self' do
        expect(subject.descendant_of?(subject)).to be_false
      end

      it 'false for child' do
        expect(subject.descendant_of?(children.first)).to be_false
      end
    end

    describe '#ancestor_of?' do
      it 'true for child' do
        expect(subject.ancestor_of?(children.first)).to be_true
      end

      it 'true for descendant' do
        expect(subject.ancestor_of?(descendant)).to be_true
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
  end

  context 'leaf' do
    subject { @quux }

    let(:root) { @bar }
    let(:parent) { @qux }
    let(:ancestors) { [ @bar, @qux ] }

    it { should_not be_root }

    its(:root) { should eq(root) }

    its(:depth) { should eq(ancestors.count) }

    its(:parent) { should eq(parent) }

    its(:children) { should be_empty }

    its(:ancestors) { should eq(ancestors) }

    describe '#descendants' do
      it 'is empty' do
        expect(subject.descendants).to be_empty
      end
    end

    describe '#subtree' do
      it 'contains only that item' do
        expect(subject.subtree).to eq([ subject ])
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

    describe '#ancestor_of?' do
      it 'false for self' do
        expect(subject.ancestor_of?(subject)).to be_false
      end

      it 'false for parent' do
        expect(subject.ancestor_of?(parent)).to be_false
      end
    end
  end

  describe 'parent change' do
    subject { @baz }

    let(:new_parent) { @foo }
    let(:new_ancestors) { [ @foo ] }

    before do
      subject.parent = new_parent
      subject.save!
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
    before(:all) do
      Item.has_children scope: :category
    end

    it 'scoped by category' do
      expect(@foo.siblings).to be_empty
    end
  end
end
