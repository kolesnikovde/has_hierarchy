# Changelog

## TODO

- Add README.md.
- Update .gitignore.
- Update rake tasks.

## current

- Added `#leaf?`.
- Added `has_children_options` accessor.
- Added counter cache and root scope specs.
- "orphan_strategy" option renamed to "dependent".

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
