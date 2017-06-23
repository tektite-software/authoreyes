# Authoreyes

[![Gem Version](https://badge.fury.io/rb/authoreyes.svg)](https://badge.fury.io/rb/authoreyes) [![Build Status](https://travis-ci.org/tektite-software/authoreyes.svg?branch=master)](https://travis-ci.org/tektite-software/authoreyes) [![Dependency Status](https://gemnasium.com/badges/github.com/tektite-software/authoreyes.svg)](https://gemnasium.com/github.com/tektite-software/authoreyes)
 [![Code Climate](https://codeclimate.com/github/tektite-software/authoreyes/badges/gpa.svg)](https://codeclimate.com/github/tektite-software/authoreyes) [![Test Coverage](https://codeclimate.com/github/tektite-software/authoreyes/badges/coverage.svg)](https://codeclimate.com/github/tektite-software/authoreyes/coverage) [![Inline docs](http://inch-ci.org/github/tektite-software/authoreyes.svg?branch=master)](http://inch-ci.org/github/tektite-software/authoreyes)

_Authoreyes_ (pronounced "authorize") is intended to be a modern, Rails 5 compatible replacement for [Declarative Authorization](https://github.com/stffn/declarative_authorization/).

## Quick-Start

Add this line to your application's Gemfile:

```ruby
gem 'authoreyes'
```

This quick-start guide will cover the basic requirements needed to start using Authoreyes:
* Setup a User model that has one or more roles
* Define some authorization rules

### Setting Up a User

1. Create a Role model with `name` or `title` attribute
2. Define relationship between Role and User
3. Add `is_authoreyes_user` to your User model

User:
```ruby
# == Schema Information
#
# Table name: users
#
# name      :string
# email     :string
# ...
# role_id   :integer
#

class User < ApplicationRecord
  is_authoreyes_user

  # You could also define a many-to-many relationship
  belongs_to :role
  ...
end
```

Role:
```ruby
# == Schema Information
#
# Table name: roles
#
# name      :string
# ...
#

class Role < ApplicationRecord
  has_many :users
end
```

See below for more information on how Authoreyes expects your user to be set up, and what the `is_authoreyes_user` helper does.

### Defining Authorization Rules

Put a new `authorization_rules.rb` file in your `config` directory.  See the included `authorization_rules.dist.rb` for an example.

```ruby
# config/authorization_rules.rb
authorization do
  role :guest do
    # has_permission_on :context, to: :action
    has_permission_on :pages, to: :read
    # You can also pass in an array
    has_permission_on :posts, to: [:read]
  end

  role :user do
    # Include all permissions from another role
    includes :guest
    has_permission_on :posts, to: [:read, :create]
    # You can specify that a role only has permissions under certain
    # circumstances by passing in a block
    has_permission_on :posts, to: :manage do
      if_attribute user_id: is { user.id }
    end
  end

  role :admin do
    has_permission_on :posts, to: :manage
  end

  # Privileges are ways to group together several controller actions to make
  # writing auth rules easier.  Authoreyes will also match the name of the
  # privilege to possible controller actions, so there's no need to specify
  # that `create` includes `create`, for example.
  privileges do
    privilege :manage, includes: [:create, :read, :update, :delete]
    privilege :create, includes: :new
    privilege :read, includes: [:index, :show]
    privilege :update, includes: :edit
    privilege :delete, includes: :destroy
  end
end
```

See the Authorization Rules section below for more details.

## Usage

### User

The Authoreyes authorization engine expects your User model to respond to `role_symbols` with an array of symbols for each role the user has, even if the user only has one role.

For example:
```ruby
current_user.role_symbols
  => [:user]
```

Authoreyes provides the `is_authoreyes_user` to help simplify this, which you can call near the top of your User model.  This call, in turn, attempts to guess how you have your roles set up and can detect a few different scenarios, all of which require your User model to respond to either `role` or `roles`:
* A one-to-many User `belongs_to :role` type of relationship
* A many-to-many AR relationship
* A non-ActiveRecord method `role` or `roles` returning a string, symbol, AR model, class, or array of any of the above.

If you are not using the  `is_authoreyes_user` helper or if it is unable to figure out your roles, you will have to define the `role_symbols` method yourself.  Overriding this method may provide a slight performance boost as well, even if the helper is working for you setup:

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :roles
  ...

  def role_symbols
    roles.map { |r| r.title.to_sym }
  end
end
```

### Authorization Rules

Your authorization rules must be defined in a file in the root of your `config` directory called `authorization_rules.rb`.

__IMPORTANT NOTE:__ These rules are loaded at startup by the Authorization Engine, which is then constantized and FROZEN.  Therefore, any time you modify your authorization rules you must restart your server, even if you are using Spring.  This is for security reasons.  The Authorization Engine is the only source, so by freezing the Engine we ensure that an attacker cannot somehow inject an expression or run arbitrary code to change or bypass the authorization rules.

Authoreyes uses a straightforward DSL syntax for defining authorization rules.  The general format is as follows:

```ruby
# config/authorization_rules.rb
authorization do
  ...
  role :role do
    has_permission_on :context, to: :action
  end
  ...
end
```

`has_permission_on` takes as a first argument a symbol for the name of the context (singularized resource name corresponding to the authorized controller) followed by an optional options hash and an optional block.  The two options are `:to` and `:join_by`.  You can pass in a block to define one or more conditions to further restrict the permission granted to the role:

```ruby
authorization do
  ...
  role :user do
    has_permission_on :posts, to: :manage do
      if_attribute user_id: is { user.id }
    end
  end
  ...
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tektite-software/authoreyes.

__Please check out the wiki for guides on contributing to this project.__

## Acknowledgements

This gem was originally based on [stffn](https://github.com/stffn)'s gem [Declarative_Authorization](https://github.com/stffn/declarative_authorization).  Many thanks to stffn and all who contributed to Declarative Authorization for a great gem!


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

:copyright: 2016 Tektite Software
