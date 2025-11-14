# Release Checklist

This checklist ensures a smooth and consistent release process for BlogEngine.

## Pre-Release

### 1. Version Bump

- [ ] Update version in `mix.exs`:
  ```elixir
  version: "X.Y.Z"
  ```

- [ ] Follow [Semantic Versioning](https://semver.org/):
  - MAJOR: Breaking changes
  - MINOR: New features, backwards-compatible
  - PATCH: Bug fixes, backwards-compatible

### 2. Update CHANGELOG.md

- [ ] Move items from "Unreleased" to new version section
- [ ] Add version number and release date
- [ ] Organize changes into categories:
  - Added
  - Changed
  - Deprecated
  - Removed
  - Fixed
  - Security

Example:
```markdown
## [1.1.0] - 2025-11-13

### Added
- New feature X
- New feature Y

### Fixed
- Bug fix A
- Bug fix B
```

### 3. Update Documentation

- [ ] Review and update README.md
- [ ] Update API documentation if changed
- [ ] Update Docker guides if changed
- [ ] Update examples if needed
- [ ] Check all documentation links work

### 4. Code Quality

- [ ] Run full test suite:
  ```bash
  mix test
  ```

- [ ] Run code formatter:
  ```bash
  mix format --check-formatted
  ```

- [ ] Run static analysis:
  ```bash
  mix credo --strict
  ```

- [ ] Run type checker:
  ```bash
  mix dialyzer
  ```

- [ ] Check test coverage:
  ```bash
  mix coveralls
  ```

### 5. Security Check

- [ ] Audit dependencies:
  ```bash
  mix deps.audit
  ```

- [ ] Review SECURITY.md is up to date
- [ ] Check for hardcoded secrets or credentials
- [ ] Review Docker image security

### 6. Build Verification

- [ ] Build escript successfully:
  ```bash
  mix escript.build
  ```

- [ ] Test escript execution:
  ```bash
  ./blog_engine
  ```

- [ ] Build Docker image:
  ```bash
  docker build -t blog-engine:test .
  ```

- [ ] Test Docker image:
  ```bash
  docker run -it --rm blog-engine:test
  ```

### 7. Integration Testing

- [ ] Test all CLI commands manually
- [ ] Test import/export functionality
- [ ] Test with example data
- [ ] Test error scenarios
- [ ] Test on different platforms (if possible):
  - [ ] Linux
  - [ ] macOS
  - [ ] Windows (WSL)

### 8. Documentation Review

- [ ] Verify installation instructions work
- [ ] Test Quick Start guide
- [ ] Verify Docker instructions
- [ ] Check all code examples run
- [ ] Review API documentation accuracy

## Release Process

### 1. Commit Changes

```bash
git add mix.exs CHANGELOG.md
git commit -m "Bump version to X.Y.Z"
```

### 2. Create Git Tag

```bash
git tag -a vX.Y.Z -m "Release version X.Y.Z"
```

### 3. Push to GitHub

```bash
git push origin main
git push origin vX.Y.Z
```

### 4. Verify CI Passes

- [ ] Check GitHub Actions workflows pass:
  - [ ] CI workflow (tests, linting, etc.)
  - [ ] Release workflow (if triggered)

### 5. Create GitHub Release

Go to https://github.com/codeforgood-org/elixir-blog-engine/releases/new

- [ ] Select the tag (vX.Y.Z)
- [ ] Title: "BlogEngine vX.Y.Z"
- [ ] Description: Copy from CHANGELOG.md
- [ ] Attach artifacts (if not automated):
  - [ ] blog_engine escript binary
  - [ ] Source code (automatic)
- [ ] Check "Set as the latest release"
- [ ] Publish release

### 6. Verify Release Artifacts

- [ ] Download and test escript from release
- [ ] Verify Docker image builds from tag
- [ ] Check release notes display correctly

## Post-Release

### 1. Update Documentation Sites

- [ ] Update any external documentation
- [ ] Update package registries (if applicable)
- [ ] Update Docker Hub (if publishing there)

### 2. Announce Release

Consider announcing on:
- [ ] GitHub Discussions
- [ ] Project README
- [ ] Social media (if applicable)
- [ ] Elixir Forum (for major releases)

### 3. Monitor Issues

- [ ] Watch for new issues related to release
- [ ] Respond to user feedback
- [ ] Prepare hotfix if critical issues found

### 4. Prepare Next Release

- [ ] Create new "Unreleased" section in CHANGELOG.md
- [ ] Update project board/issues
- [ ] Close milestone (if used)
- [ ] Create next milestone

## Hotfix Process

For critical bugs requiring immediate release:

### 1. Create Hotfix Branch

```bash
git checkout -b hotfix/vX.Y.Z+1 vX.Y.Z
```

### 2. Fix Bug

- [ ] Make minimal changes to fix issue
- [ ] Add test for the bug
- [ ] Update CHANGELOG.md

### 3. Test Thoroughly

- [ ] Run all tests
- [ ] Manually verify fix

### 4. Release Hotfix

- [ ] Bump patch version
- [ ] Create tag
- [ ] Push to GitHub
- [ ] Create release

### 5. Merge Back

```bash
git checkout main
git merge hotfix/vX.Y.Z+1
git push origin main
```

## Release Types

### Major Release (X.0.0)

Breaking changes require:
- [ ] Migration guide in CHANGELOG
- [ ] Updated documentation
- [ ] Deprecation warnings in previous version (if possible)
- [ ] Communication plan for users

### Minor Release (X.Y.0)

New features require:
- [ ] Documentation for new features
- [ ] Examples of new features
- [ ] Tests for new features

### Patch Release (X.Y.Z)

Bug fixes require:
- [ ] Test demonstrating the bug
- [ ] Minimal changes
- [ ] Quick turnaround

## Rollback Procedure

If a release has critical issues:

### 1. Assess Severity

- [ ] Determine if rollback needed
- [ ] Document the issue

### 2. Create Hotfix or Rollback

Option A (Hotfix):
- [ ] Follow hotfix process above

Option B (Rollback):
- [ ] Delete problematic release
- [ ] Delete tag: `git tag -d vX.Y.Z`
- [ ] Force push: `git push origin :refs/tags/vX.Y.Z`
- [ ] Communicate rollback

### 3. Communicate

- [ ] Update release notes
- [ ] Notify users
- [ ] Provide workaround or timeline

## Automation Opportunities

Consider automating:
- [ ] Version bumping
- [ ] CHANGELOG generation
- [ ] Release note creation
- [ ] Artifact uploads
- [ ] Docker image publishing
- [ ] Announcement posting

## Release Metrics

Track for each release:
- [ ] Time from tag to release
- [ ] Number of downloads
- [ ] Issues reported
- [ ] Hotfixes needed

## Notes

- Always do a dry run for major releases
- Test the release process in a fork first
- Keep releases small and frequent
- Document any process improvements

---

**Remember:** A good release is boring - everything works as expected!
