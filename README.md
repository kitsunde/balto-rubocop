# Balto

A GitHub action for style violations

Sample config:

```yaml
name: Balto

on: [pull_request]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v1
      - name: Read ruby version
        run: echo ::set-output name=RUBY_VERSION::$(cat .ruby-version | cut -f 1,2 -d .)
        id: rv
      - uses: actions/setup-ruby@v1
        with:
          ruby-version: "${{ steps.rv.outputs.RUBY_VERSION }}"
      - uses: planningcenter/balto-rubocop@v0.1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
