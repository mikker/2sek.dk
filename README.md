# [2sek.dk](http://2sek.dk)

## Development

```sh
$ bundle exec puma -C config/puma.rb
```

## Compatibility and security checks

Use Ruby 3.4.12 and the committed lockfile:

```sh
bundle install
bundle exec bundle-audit check --update --config .bundler-audit.yml
bundle exec ruby test/application_test.rb
```

Tests create a disposable SQLite database with synthetic words; they never open
the checked-in dictionary. CI runs the same checks on PRs, master pushes and a
weekly schedule. Advisory failures are not ignored, and tests need no secrets.

## Deployment

Source: `mikker/2sek.dk`, branch `master`. The documented Dokku remote is
`dokku@hz1:tosek`, serving `2sek.dk`. Historical production lockfile inspection
confirmed this app had the dependency versions being patched here; that does not
establish the current deployed revision.

Before a normal fast-forward Dokku deployment, require a successful GitHub
`compatibility-and-advisories` check for the exact source SHA and rerun the above
commands. Do not use an old manual deployment script to skip these checks.
No automatic deployment is configured by this workflow. Host SSH access and
deployed-revision/health verification must work before claiming a release is live.
