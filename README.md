h1 Train

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

Let's rewrite the method using Train:

```ruby
class User
  include Train

  def self.delete(id)
    return Failure.new(:id_missing) unless id
    return Failure.new(:invalid_id, id: id) unless id.match /[a-f]{8}/

    user = @users[id]
    if @users.delete id
      Success.new :user_deleted, user: user
    else
      Success.new :deletion_failed, id: id
    end

  rescue ConnectionError
      Failure.new :deletion_failed_badly, id: id
  end
end
```




h3 Background

Train is a complete rewrite of its predecessor [operation](https://github.com/halo/operation). I got inspired by the [deterministic](https://github.com/pzol/deterministic) gem, which is the follow-up of the [monadic](https://github.com/pzol/monadic) gem.

`Operation` is very useful, but the API was always a bit cumbersome. Additionally, there was no paradigm of chaining operations, i.e. run multiple operations but bail out if one of them fails.

So let's see what Train can do for us.

