# 1.0.0

Major changes

* Deprecated `Tron::Success` and `Tron::Failure` classes altogether
* Introduce `Tron.success` and `Tron.failure`, returning an (immutable) Struct
  This Api make it clearer where the method is defined - in the tron gem.
  Also, less overhead and more robust by not depending on class checking.

# 0.7.1

Improvements

* Lower ruby requirement from 2.2.3 to 2.1.5

# 0.7.0

Breaking changes

* Renamed `train` gem to `tron`, because Chef can make good use of `train`

# 0.1.0

Breaking changes

* The code param is not not optional anymore
* Introduced `Failure.call` and `Success.call` shortcuts

# 0.0.2

* Version bump only to avoid a yank conflict on Rubygems

# 0.0.1

* Initial functionality
