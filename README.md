# Orcid

[![Version](https://badge.fury.io/rb/orcid.png)](http://badge.fury.io/rb/orcid)
[![Build Status](https://travis-ci.org/projecthydra-labs/orcid.png?branch=master)](https://travis-ci.org/projecthydra-labs/orcid)
[![Coverage Status](https://img.shields.io/coveralls/projecthydra-labs/orcid.svg)](https://coveralls.io/r/projecthydra-labs/orcid)
[![API Docs](http://img.shields.io/badge/API-docs-blue.svg)](http://rubydoc.info/gems/orcid/0.8.0/frames)
[![APACHE 2 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)
[![Contributing Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./CONTRIBUTING.md)

A [Rails Engine](https://guides.rubyonrails.org/engines.html) for integrating with [Orcid](https://orcid.org). It leverages the [Devise MultiAuth plugin](https://rubygems.org/gems/devise-multi_auth) for negotiating the interaction with [orcid.org](https://orcid.org).

## Features

Associate ORCID with your user account for the application by:

* Creating an ORCID
* Looking up and associating with an existing ORCID
* Providing an ORCID to directly associate with your account

Authentication

* Using OAuth2, you can use orcid.org as one of your authentication mechanisms

Interacting with ORCID Profile Works:

**The functionality exists, but it will be a bit bumpy to implement.**
**Plans are to improve the integration with Version 1.0.0 of the Orcid gem.**

* Query for your Orcid Profile's works
* Append one or more works to your Orcid Profile
* Replace your Orcid Profile works with one or more works

## Getting Started with the Orcid gem

To fully interact with the Orcid remote services, you will need to [register your ORCID application profile](#registering-for-an-orcid-application-profile).

* [Installation](#installation)
* [Using the Orcid widget in your application](#using-the-orcid-widget-in-your-application)
* [Registering for an ORCID application profile](#registering-for-an-orcid-application-profile)
* [Setting up your own ORCIDs in the ORCID Development Sandbox](#setting-up-your-own-orcids-in-the-orcid-development-sandbox)
* [Running the tests](#running-the-tests)
* [Versioning](#versioning)
* [Contributing to this gem](./CONTRIBUTING.md)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'orcid'
```

And then execute:

```console
$ bundle
```

If bundle fails, you may need to [install Qt](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit).

And then install by running the following:

```console
$ rails generate orcid:install
```

*Note: It will prompt you for your Orcid application secrets.*

You may find it helpful to review the help text, as there are a few options for the generator.

```console
$ rails generate orcid:install -h
```

## Using the Orcid widget in your application

In order to facilitate integration of this ORCID gem into your application, a widget has been provided to offer these functions:

1. Enter a known ORCID and connect to the ORCID repository.
1. Look up the ORCID of the current user of your application.
1. Create an ORCID to be associated with the current user of your application.

The widget is contained in the partial `app/views/orcid/profile_connections/_orcid_connector.html.erb`.

An example use of the partial is shown below.

```ruby
# The `if defined?(Orcid)` could be viewed as a courtesy.
# Don't attempt to render this partial if the Orcid gem is not being used.
if defined?(Orcid)
  <%= render partial: 'orcid/profile_connections/orcid_connector', locals: {default_search_text: current_user.name } %>
end
```

**To customize the labels, review the `./config/locales/orcid.en.yml` file.**

## Registering for an ORCID application profile

Your application which will interface with ORCID must be registered with ORCID.  Note that you will want to register your production
application separately from the development sandbox.

1. Go to http://support.orcid.org/knowledgebase/articles/116739-register-a-client-application
1. Read the information on the entire page, in particular, the 'Filling in the client application form' and 'About Redirect URIs' sections.
1. Click on 'register a client application', http://orcid.org/organizations/integrators/create-client-application
1. There you will be given a choice of registering for the Development Sandbox or the Production Registry.
1. Fill in the other information as appropriate for your organization.  If you are doing development, select Development Sandbox.
1. For the URL of the home page of your application, you must use an https:// URL.  If you are going to be doing development work locally
on your own machine where your application's server will run, enter https://localhost:3000 for the URL of your home page (or as appropriate
to your local development environment).  See **NOTE: Application home page URL** below.
1. You must enter at least one Redirect URI, which should be https://localhost:3000/users/auth/orcid/callback
1. Another suggested Redirect URI is https://developers.google.com/oauthplayground

Within a day or so, you will receive an email with an attached xml file containing the client-id and client-secret which must be used in the application.yml
file discussed below.

### NOTE: Application home page URL
You must enter the same URL for the application home page on the form as you would enter into your browser.  For example, if you specify "https://localhost:3000" on
the ORCID registration form, then you MUST invoke your application via the browser with "https://localhost:3000" in order for all of the ORCID functionality to work.

For development work in particular, there are multiple ways to specify the local machine: 127.0.0.1, ::1, 192.168.1.1, and localhost.  It is strongly recommended that you use 'localhost'
in the ORCID form's URL for your application and when invoking your application from the browser rather than using any IP address for your local machine.

## Setting up your own ORCIDs in the ORCID Development Sandbox

[Read more about the ORCID Sandbox](http://support.orcid.org/knowledgebase/articles/166623-about-the-orcid-sandbox).

1. Register two ORCID users: https://sandbox-1.orcid.org/register (make sure to use <blah>@mailinator.com as your email)
Save the email addresses, orcid ids, and passwords for editing the application.yml later.
1. Go to mailinator (http://mailinator.com/) and claim 1 ORCID by clicking the verify link in the email.
1. Go to the ORCID sandbox https://sandbox.orcid.org, log in and click on *Account Settings* (https://sandbox.orcid.org/account).  On the Account Settings page,
click on Email and select the little icon with the group of heads to make your Primary Email publicly accessible.

## Setting up the config/application.yml file
Customize the sample application.yml file by first copying it to config/application.yml and opening it for editing.

```console
$ cp config/application.yml.sample config/application.yml
```

## Running the tests

Run `rake` to generate the dummy app and run the offline tests.

To run the online tests, you'll need ORCID application credentials:

1. Register for an ORCID app. See **Registering for an ORCID application profile** above.  (This may take several days to complete.)
1. Register two ORCID users in the ORCID Development Sandbox.  See **Setting up your own ORCIDs in the ORCID Development Sandbox** above.
1. Update the application.yml with your information.  See **Setting up the config/application.yml file** above.

Run the online tests with

```console
$ rake spec:online
```

## Versioning

**Orcid** uses [Semantic Versioning 2.0.0](http://semver.org/)