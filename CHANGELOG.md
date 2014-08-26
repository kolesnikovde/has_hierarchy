# Changelog

## 0.2.0

- Added custom node path values.
- Added `.find_by_node_path`.
- Added `#child_of?`.
- Updated "node_path_column" option (renamed to "node_path_cache").
- Rewrited specs.

## 0.1.3

- Added README.md.
- Added `#leaf?`.
- Added `has_children_options` accessor.
- Added counter cache and root scope specs.
- Updated "orphan_strategy" option (renamed to "dependent").
- Updated rake tasks.
- Updated .gitignore.
- Updated codestyle.
- Fixed rspec deprication warnings.

## 0.1.2

- Added root association.
- Added `#root_id`.
- Added `#root_of?`.
- Added `#parent_of?`.

## 0.1.1

- Fixed scopes (always using lambdas).

## 0.1.0

- Added `#move_children_to_parent`.
- `#ancestor_tokens` renamed to `#ancestor_ids`.
- Added lambda scopes support.
