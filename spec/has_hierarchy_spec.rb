require 'spec_helper'
require 'tree'

describe AdjacencyListTreeItem do
  it_behaves_like 'adjacency list'
  it_behaves_like 'ordered tree'
end

describe MaterializedPathTreeItem do
  it_behaves_like 'materialized path'
end

describe CachedDepthTreeItem do
  it_behaves_like 'tree with cached depth'
end

describe ScopedWithColumnTreeItem do
  it_behaves_like 'scoped tree'
end

describe ScopedWithLambdaTreeItem do
  it_behaves_like 'scoped tree'
end
