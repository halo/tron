[![Gem Version](https://img.shields.io/gem/v/tron.svg)](https://rubygems.org/gems/tron)
[![Build Status](https://travis-ci.org/halo/tron.svg?branch=master)](https://travis-ci.org/halo/tron)
[![License](http://img.shields.io/badge/license-MIT-blue.svg)](http://github.com/halo/tron/blob/master/LICENSE.md)

# Tron

Imagine you have a class like this:

```ruby
class User
  def self.delete(id)
    @users.delete id
  end
end
```

It's not clear from the code what this method returns (`true`?, a `User`?, a user ID?). What if an error occured - how does anyone calling `User.delete 42` know what happened?

Indeed, it is not even clear what "successful" means in the context of this message - if there is no user and you try to delete one, is that considered a "failure"?

Let's rewrite the method using Tron:

```ruby
class User
  include Tron

  def self.delete(id)
    return Failure.call(:id_missing) unless id
    return Failure.call(:invalid_id, id: id) unless id.match /[a-f]{8}/

    user = @users[id]
    if @users.delete id
      Success.call :user_deleted, user: user
    else
      Success.call :deletion_failed, id: id
    end

  rescue ConnectionError
      Failure.call :deletion_failed_badly, id: id
  end
end
```

One could even take it a step further and write it like this:

```ruby
class User
  include Tron

  def self.delete(id)
    # If any one of these fail, the following blocks won't be executed
    check_id_syntax(id)
      .on_success { delete_user(id) }
      .on_success { send_sms }
      .on_success { redirect }
  end

  def self.check_id_syntax(id)
    return Failure.call(:id_missing) unless id
    return Failure.call(:invalid_id, id: id) unless id.match /[a-f]{8}/
    Success.call(:id_looks_good)
  end

  def self.delete_user(id)
    user = @users[id]
    if @users.delete id
      Success.call :user_deleted, user: user
    else
      Success.call :deletion_failed, id: id
    end

  rescue ConnectionError
    Failure.call :deletion_failed_badly, id: id
  end
end
```

### So what are the benefits?

#### 1. It will give you robust and predictable code

Tron will give you this consistent, implementation-unaware, programming convention:

```ruby
result = User.delete 42

if result.success?
  puts "It worked! You deleted the user #{result.meta.user.first_name}"
else
  puts "Aw, could not delete User with ID #{result.meta.id} because #{result.code}"
end
```

```ruby
result = User.delete 42

result.success? # => true
result.failure? # => false
result.metadata # => { object: <#User id=42> }
result.meta     # => { object: <#User id=42> }
result.object   # => <#User id=42>   <- shortcut for meta[:object]

# In case you use Hashie, you will get that via #meta
require 'hashie/mash'
result.meta     # => <#Hashie::Mash object: <#User id=42>>
result.object   # => <#User id=42>   <- shortcut for meta.object
```

#### 2. If will give you better tests

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

#### 3. It gives you documentation

While the code you're writing becomes slightly more verbose, that verbosity translates directly into documenation. You see immediately what each line is doing.

### Background

Tron is a complete rewrite of its predecessor [operation](https://github.com/halo/operation). I got inspired by the [deterministic](https://github.com/pzol/deterministic) gem, which is the follow-up of the [monadic](https://github.com/pzol/monadic) gem.

`operation` is very useful, but the API was always a bit cumbersome. Additionally, there was no paradigm of chaining trons, i.e. run multiple trons but bail out if one of them fails.

### Requirements

* Ruby >= 2.2.3

### Copyright

MIT 2015 halo. See [MIT-LICENSE](http://github.com/halo/tron/blob/master/LICENSE.md).

### TODO

* Include in README that freezing is only top-level, see https://bugs.ruby-lang.org/issues/2509
