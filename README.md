[![Gem Version](https://img.shields.io/gem/v/tron.svg)](https://rubygems.org/gems/tron)
[![Build Status](https://travis-ci.org/halo/tron.svg?branch=master)](https://travis-ci.org/halo/tron)
[![License](http://img.shields.io/badge/license-MIT-blue.svg)](http://github.com/halo/tron/blob/master/LICENSE.md)

## TL;DR

Tron is a minimalistic combination of a [monad](https://www.morozov.is/2018/09/08/monad-laws-in-ruby.html) and [value object](https://madeintandem.com/blog/creating-value-objects-in-ruby/), implemented in [a few lines](https://github.com/halo/tron/blob/master/lib/tron.rb) of code.

* Return `Tron.success(:it_worked)` or `Tron.failure(:aww_too_bad)` from a method, to explain why and how it succeded or failed. That returns an immutable Data (value object) that responds to `result.success?` and `result.failure?`.
* Add metadata as a second argument: `Tron.failure(:nopes, error_code: 404)` which you then can access: `result.error_code #=> 404`.
* The result can also be queried with `result.success #=> :it_worked` and `result.failure #=> nil`.
* Chaining can make your code cleaner: `result.on_success { download }.on_failure { show_message }`

## Introduction

Imagine you have a class like this:

```ruby
class User
  def self.delete(id)
    @users.delete id
  end
end
```

It's not clear from the code what this method returns. `true`?, a `User`?, a user ID?. What if a network error occurs, how does anyone calling `User.delete 42` know what happened?

Indeed, it is not even clear what "successful" means in the context of this message - if there is no user and you try to delete one, is that considered a "failure"?

Let's rewrite the method using Tron:

```ruby
class User
  def self.delete(id)
    return Tron.failure(:id_missing) unless id
    return Tron.failure(:invalid_id, id: id) unless id.match /[a-f]{8}/

    user = @users[id]
    if @users.delete id
      Tron.success :user_deleted, user: user
    else
      Tron.success :already_deleted, id: id # Notice the success here
    end

  rescue ConnectionError
    Tron.failure :deletion_failed_badly, id: id
  end
end
```

One could break the functionality apart into smaller pieces:

```ruby
class User
  def self.delete(id)
    check_id_syntax(id).on_success { delete_user(id) }
                       .on_success { send_sms }
                       .on_success { redirect }
  end

  def self.check_id_syntax(id)
    return Tron.failure(:id_missing) unless id
    return Tron.failure(:invalid_id, id: id) unless id.match /[a-f]{8}/

    Tron.success :id_looks_good
  end

  def self.delete_user(id)
    user = @users[id]

    if @users.delete id
      Tron.success :user_deleted, user: user
    else
      Tron.success :deletion_failed, id: id
    end

  rescue ConnectionError => ex
    Tron.failure :deletion_failed_badly, id: id, message: ex.message
  end
end
```

On a side-note, the data object can be passed on further with modifications, that's due to the way `Data` object work.

```ruby
result = Tron.success(:api_not_responding, reason: :password_not_accepted)

result.with(code: :could_not_delete_user)
  # => "#<data failure=:could_not_delete_user, reason=:password_not_accepted>"
```

## So, what are the benefits?

### 1. An internal API that doesn't change over time

Tron will give you a consistent, implementation-unaware, programming convention. That means that you can decide later, what constitutes a success or a failure, without changing the way the result is handled. You could also add metadata after-the-fact and the following code would still work fine:

```ruby
result = User.delete 42

if result.success?
  puts "It worked! You deleted the user #{result.user.first_name}"
else
  puts "Aw, couldn't delete User with ID #{result.id} because #{result.failure}"
end
```

The result is just an instance of Data:

```ruby
result = User.delete 42

# Query whether it worked
result.success? # => false
result.failure? # => true

# Query why and how
result.success # => nil
result.failure # => :deletion_failed_badly

# Access immutable metadata
result.message # => "..."
result.inspect # => "#<data failure=:alright, user_id=42, message='...'>"
```

### 2. If will give you better tests

How would you test this code?

```ruby
class Product
  def self.delete(id)
    return false if id.blank?
    return false unless product = Products.find(id)
    return false unless permission?
    api.update(id, attributes)
  end

  def self.permission?
    Date.today.sunday?
  end
end
```

You cannot simply test for `false` as expected return value, because it could mean anything. Tron helps you to check the response objects for every case. Data objects even support deconstruction for `case` statements.

### 3. It gives you documentation

While the code you're writing becomes slightly more verbose, that verbosity translates directly into documenation. You see immediately what each line is doing.

## Upgrading from 2.0.0 to 3.0.0

* You will need to use at least Ruby `3.2`
* The result object doesn't respond to collection methods any more, such as `result[:some_key]` or `result.to_a`, but it's unlikely that you relied on them in the first place.

## Upgrading from 1.x.x to 2.0.0

* `1.2.0` and `2.0.0` are identical, except that all deprecations have been removed and don't work any more.

## Upgrading from 0.x.x to 1.x.x

* Don't use `include Tron`, it is not useful any more. There are no subclasses you might want to access.
* Replace `Tron::Success.call` with `Tron.success` (same for failure). The syntax is identical.
* The result object is now a Struct and has no `#meta` and `#metadata` methods anymore.
* The result object does not respond to `#code` any more. Instead use `#success` and `#failure` respectively. This is so that you can use `#code` as metadata, and also so that you can query the code via `#success` immediately, without first having to check `#success?`.

## Background

Tron is a complete rewrite of its predecessor [operation](https://github.com/halo/operation). I got inspired by the [deterministic](https://github.com/pzol/deterministic) gem, which is the follow-up of the [monadic](https://github.com/pzol/monadic) gem. There are some [complicated structs](https://github.com/dry-rb/dry-struct/blob/master/lib/dry/struct.rb) so I got inspired by [this robust implementation](https://github.com/iconara/immutable_struct) and simplified it even more.

## Requirements

* Ruby >= 3.2.0

## Copyright

MIT halo. See [MIT-LICENSE](http://github.com/halo/tron/blob/master/LICENSE.txt).

## Caveats

* There are no setter methods in the returned Data, so you cannot overwrite the metadata. But you can use `Data#with` to essentially clone the object and change values.
