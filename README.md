# Orcid [![Version](https://badge.fury.io/rb/orcid.png)](http://badge.fury.io/rb/orcid) [![Build Status](https://travis-ci.org/jeremyf/orcid.png?branch=master)](https://travis-ci.org/jeremyf/orcid)


A Rails Engine for integrating with Orcid

## Installation

Add this line to your application's Gemfile:

    gem 'orcid'

And then execute:

    $ bundle

If bundle fails, you may need to install Qt: https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit

And then install:

    $ rails generate orcid:install

## Running the tests

Run `rake` to generate the dummy app and run the offline tests.

To run the online tests, you'll need ORCID application credentials:

1. Register for an ORCID app:  http://support.orcid.org/knowledgebase/articles/116739-register-a-client-application
 (this could take days to come back)
1. Register two ORCID users: https://sandbox-1.orcid.org/register (make sure to use <blah>@mailinator.com as your email)
Save the email addresses, orcid ids, and passwords for editing application.yml
1. Go to mailinator (http://mailinator.com/) and claim 1 ORCID by clicking the verify link in the email.
1. `cp config/application.yml.sample config/application.yml`
1. Update the application.yml with your information

Run the online tests with `rake spec:online`

## TODO Items

* When searching for your profile, expose Name and associated DOI as query parameters.
