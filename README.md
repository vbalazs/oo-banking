# Banking assessment

## Schema

![Banking database schema](schema.png)

## Setup

```
$ bundle install
```

## Running the app

```
$ bundle exec ruby app.rb
```

## Testing

Sequel triggers a [lot of warnings](https://github.com/jeremyevans/sequel/issues/1184) so we need to lower the warning level.

```
$ RUBYOPT="-W1" rake
```
