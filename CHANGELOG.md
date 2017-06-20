* __v0.3.0__
  * Update README to display more comprehensive documentation and quick-start
  * Add `privileges_on` and `guest_privileges_on` helpers
  * Add `InUser` helper module with `is_authoreyes_user` method to simplify setup

* __v0.2.2__
  * Fix some bugs preventing controllers named certain ways not to behave properly

* __v0.2.0__
  * Add _very_ basic functionality for Rails API: Authoreyes now has different behavior for ActionController::Base and ActionController::API.  On ::API, Authoreyes will return a ActiveModel::Serializers JSON API compliant error JSON object.
