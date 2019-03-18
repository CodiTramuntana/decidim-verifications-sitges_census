# Decidim::Verifications::SitgesCensus

Decidim Verifications for Sitges Census.

## Usage

Decidim::Verifications::SitgesCensus will be available as a Component for Verifications

## How it works
- The user must be registered as "normal" Decidim::User.
- Then, User goes to the Authorizations path and fill the fields Document number and birthday to verifiy the user. This connects to a WS with params (sitges_census_url) added on secrets.yml.
- If the return is valid, the user is verified.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-verifications-sitges_census'
```

And then execute:

```bash
bundle
```

SitgesCensus verificator needs 1 value to perform requests: url

Take care to add environment values to the secrets.yml file with:

```ruby
sitges_census:
  sitges_census_url: <%= ENV["SITGES_CENSUS_URL"] %>
  sitges_census_secret: <%= ENV["SITGES_CENSUS_SECRET"] %>
```
## Testing

1. Run `bundle exec rake test_app`. **Execution will fail in an specific migration.**

2. cd `spec/decidim_dummy_app/` and:

  2.1. Comment `up` execution in failing migration

  2.2. Execute...
  ```bash
  RAILS_ENV=test bundle exec rails db:drop
  RAILS_ENV=test bundle exec rails db:create
  RAILS_ENV=test bundle exec rails db:migrate
  ```
3. back to root folder `cd ../..`

4. run tests with `bundle exec rspec`

5. Remember to configure this new test App with configuration values.

## Versioning

`Decidim::Verifications::SitgesCensus` depends directly on `Decidim::Verifications` in `0.16.0` version.

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.
