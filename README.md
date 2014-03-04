# Orcid [![Version](https://badge.fury.io/rb/orcid.png)](http://badge.fury.io/rb/orcid) [![Build Status](https://travis-ci.org/jeremyf/orcid.png?branch=master)](https://travis-ci.org/jeremyf/orcid)


A Rails Engine for integrating with Orcid

## Installation

Add this line to your application's Gemfile:

    gem 'orcid'

And then execute:

    $ bundle

And then install:

    $ rails generate orcid:install

## Running the tests

Register for an ORCID app:  http://support.orcid.org/knowledgebase/articles/116739-register-a-client-application
 (this could take days to come back)
 
Register two ORCID users: https://sandbox-1.orcid.org/register (make sure to use <blah>@mailinator.com as your email)
Save the email addresses, orcid ids, and passwords for editing application.yml

Go to maininator (http://mailinator.com/) and claim 1 ORCID by clicking the verify link in the email.
 
`cp config/application.yml.sample config/application.yml`

Update the application.yml with your information

`rake`


## TODO Items

* When searching for your profile, expose Name and associated DOI as query parameters.
