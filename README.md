[![Gem Version](https://img.shields.io/gem/v/tron.svg)](https://rubygems.org/gems/tron)
[![Build Status](https://travis-ci.org/halo/tron.svg?branch=master)](https://travis-ci.org/halo/tron)
[![License](http://img.shields.io/badge/license-MIT-blue.svg)](http://github.com/halo/tron/blob/master/LICENSE.md)

## TL;DR

Tron is a minimalistic combination of a [monad](https://www.morozov.is/2018/09/08/monad-laws-in-ruby.html) and [value object](https://madeintandem.com/blog/creating-value-objects-in-ruby/), implemented in [a few lines](https://github.com/halo/tron/blob/master/lib/tron.rb) of code.

Return `Tron.success(:it_worked)` or `Tron.failure(:aww_too_bad)` from a method to explain why and how it succeded/failed. That returns an immutable Struct (value object) that responds to `result.success?` and `result.failure?`. 

The reason is accessible in `result.success #=> :it_worked`. You can add more metadata as a second argument: `Tron.failure(:nopes, error_code: 404)` which you can access like a Struct: `result.error_code #=> 404`.

Chaining can make your code cleaner: `result.on_success { download }.on_failure { show_message }`

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
      Tron.success :deletion_failed, id: id
    end

  rescue ConnectionError
    Tron.failure :deletion_failed_badly, id: id
  end
end
```

One could even take it a step further and write it like this:

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

## So what are the benefits?

### 1. It will give you robust and predictable code

Tron will give you this consistent, implementation-unaware, programming convention:

```ruby
result = User.delete 42

if result.success?
  puts "It worked! You deleted the user #{result.user.first_name}"
else
  puts "Aw, couldn't delete User with ID #{result.id} because #{result.failure}"
end
```

The result is just a Struct:

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
result.inspect # => "#<struct failure=:alright, user_id=42, message='...'>"

result.message.upcase! # => modification raises an exception
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

You cannot simply test for the `false` as expected return value because it could mean anything. Tron helps you to check the response objects for every case.

### 3. It gives you documentation

While the code you're writing becomes slightly more verbose, that verbosity translates directly into documentation. You see immediately what each line is doing.

## Upgrading from 0.x.x to 1.x.x

* Don't use `include Tron`, it is not useful any more. There are no subclasses you might want to access.
* Replace `Tron::Success.call` with `Tron.success` (same for failure). The syntax is identical.
* The result object is now a Struct and has no `#meta` and `#metadata` methods anymore.
* The result object does not respond to `#code` any more. Instead use `#success` and `#failure` respectively. This is so that you can use `#code` as metadata, and also so that you can query the code via `#success` immediately, without first having to check `#success?`.

## Background

Tron is a complete rewrite of its predecessor [operation](https://github.com/halo/operation). I got inspired by the [deterministic](https://github.com/pzol/deterministic) gem, which is the follow-up of the [monadic](https://github.com/pzol/monadic) gem. There are some [complicated structs](https://github.com/dry-rb/dry-struct/blob/master/lib/dry/struct.rb) so I got inspired by [this robust implementation](https://github.com/iconara/immutable_struct) and simplified it even more.

## Requirements

* Ruby >= 2.3.0

## Copyright

MIT 2015-2019 halo. See [MIT-LICENSE](http://github.com/halo/tron/blob/master/LICENSE.md).

## Caveats

* There are no setter methods in the returned Struct, so you cannot overwrite the metadata. The values are also frozen, so you don't accidentally modify the attributes in-place. However, they are not deep-frozen, so an object may still be modified if you're ignorant.
