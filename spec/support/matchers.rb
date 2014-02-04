RSpec::Matchers.define :be_arranged_like do |expected|
  match do |actual|
    deep_hash_to_a(actual) == deep_hash_to_a(expected)
  end

  def deep_hash_to_a hash
    hash.map { |k, v| [ k, deep_hash_to_a(v) ] }
  end
end
