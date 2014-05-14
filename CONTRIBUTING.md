We want your help to make our project great.
There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

* [The Hydra Way](#the-hydra-way)
* [Reporting Issues](#reporting-issues)
  * [What is a well written issue?](#what-is-a-well-written-issue)
* [Making Changes](#making-changes)
  * [Where to Engage for Help](#where-to-engage-for-help)
* [Submitting Changes](#submitting-changes)
  * [Contributor License Agreement](#contributor-license-agreement)
  * [Coding Guidelines](#coding-guidelines)
    * [Stating Your Intent](#stating-your-intent)
    * [Writing Your Specs](#writing-your-specs)
    * [Writing Your Code](#writing-your-code)
    * [Ruby File Structure](#ruby-file-structure)
  * [Well Written Commit Messages](#well-written-commit-messages)
    * [Hooks into other Subsystems](#hooks-into-other-subsystems)
* [Reviewing Changes](#reviewing-changes)
  * [Responsibilities of a Reviewer](#responsibilities-of-a-reviewer)
  * [Responsibilities of the Submitter](#responsibilities-of-the-submitter)
* [Merging Changes](#merging-changes)

# The Hydra Way

We strive to…

* Provide a [harassment-free community experience](https://wiki.duraspace.org/display/hydra/Anti-Harassment+Policy)
* Adhere to our [Hierarchy of Promises](https://wiki.duraspace.org/display/hydra/Hydra+Stack+-+The+Hierarchy+of+Promises)
* Operate under [Lazy Consensus](http://rave.apache.org/docs/governance/lazyConsensus.html)
* Encourage community participation as guided by [our community principles](https://wiki.duraspace.org/display/hydra/Hydra+Community+Principles)

# Reporting Issues

Submit a [well written issue](#what-is-a-well-written-issue) to [Github's issue tracker](./issues).
This will require a [GitHub account](https://github.com/signup/free) *(its free)*.

## What is a well written issue?

* Provide a descriptive summary
* Reference the version in which you encountered the problem
* Explain the expected behavior
* Explain the actual behavior
* Provide steps to reproduce the actual behavior

# Making Changes

Hydra is an open source project, released under the [APACHE 2 license](LICENSE).
You are free to clone or [fork the repository](https://help.github.com/articles/fork-a-repo) and modify the code as you see fit.

## Where to Engage for Help

This gem is part of ProjectHydra, so you can [connect via the usual ProjectHydra channels](https://wiki.duraspace.org/pages/viewpage.action?pageId=43910187).

# Submitting Changes

## Contributor License Agreement

**Note: You can submit a pull request before you've signed the Contributor License Agreement, but we won't merge your changes until we have your CLA on file.**

Before any [ProjectHydra project](https://github.com/projecthydra) can accept your contributions we must have a [Contributor License Agreement on file](https://wiki.duraspace.org/display/hydra/Hydra+Project+Intellectual+Property+Licensing+and+Ownership).

All code contributors must have an Individual Contributor License Agreement (iCLA) on file with the Hydra Project Steering Group.
If the contributor works for an institution, the institution must have a Corporate Contributor License Agreement (cCLA) on file.

[More on the Contributor License Agreements](https://wiki.duraspace.org/display/hydra/Hydra+Project+Intellectual+Property+Licensing+and+Ownership)

## Coding Guidelines

This project is using [HoundCI](https://houndci.com) to help support our agreed upon style guide.
The style guide is a work in progress, and is declared in the project's `./hound.yml` file.

Hound is a Github integration tool that essentially runs [rubocop](http://rubygems.org/gems/rubocop).

> Automatic Ruby code style checking tool. Aims to enforce the community-driven Ruby Style Guide.

If you want to run `rubocop` with our style guide, first `gem install rubocop` then inside the project:

```bash
$ rubocop ./path/to/file ./or/path/to/directory -c ./.hound.yml
```
**Can I break these guidelines?** Yes.
But you may need to convince the person merging your changes.

### Stating Your Intent

Think of your written test as a statement of intent.
The statement of intent can then be used when asking for help or clarity;
Either from another developer or a stakeholder.
Someone helping you can then see both what you are trying to do and how you are doing it;
And that helper may know of a "better" way to do it.

### Writing Your Specs

Your code changes should include supporting tests.

Before you begin writing code, think about the test that will verify the code you plan to write.
A [well written story with Gherkin syntax](http://pivotallabs.com/well-formed-stories/) can help formulate the pre-conditions (Given), invocation (When), and post-conditions (Then).

*This is the first step of Test Driven Development, and something that we encourage.*

Now write that test; It should be your guidepost for any changes you plan on making.
The test you just wrote should be executable code;
If you are uncomfortable with where to put the executable code, a well formed Gherkin-syntax story is a suitable proxy.

### Writing Your Code

We are going to do our best to follow [Sandi Metz' Rules for Developers](http://robots.thoughtbot.com/post/50655960596/sandi-metz-rules-for-developers)

> Here are the rules:
>
> * Classes can be no longer than one hundred lines of code.
> * Methods can be no longer than five lines of code.
> * Pass no more than four parameters into a method. Hash options are parameters.
> * Controllers can instantiate only one object. Therefore, views can only know about one instance variable and views should only send messages to that object (`@object.collaborator.value` is not allowed).

## Well Written Commit Messages

**TL;DR**

* First line is 50 characters or less
* The message body explains what the code changes are about
* [Reference any Github issues](https://help.github.com/articles/writing-on-github#references) on new lines.
  * It is helpful if you [close a related issue via the commit message](https://help.github.com/articles/closing-issues-via-commit-messages)

### Terse Example

```
    Removing Document title validation

    We thought we wanted title validation but that was too complicated.

    Closes #12
```

### Verbose Example

```
    Present tense short summary (50 characters or less)

    More detailed description, if necessary. It should be wrapped to 72
    characters. Try to be as descriptive as you can, even if you think that
    the commit content is obvious, it may not be obvious to others. You
    should add such description also if it's already present in bug tracker,
    it should not be necessary to visit a webpage to check the history.

    Description can have multiple paragraphs and you can use code examples
    inside, just indent it with 4 spaces:

        class PostsController
          def index
            respond_with Post.limit(10)
          end
        end

    You can also add bullet points:

    - you can use dashes or asterisks

    - also, try to indent next line of a point for readability, if it's too
      long to fit in 72 characters
```

> When appropriate, please squash your commits into logical units of work.
> This simplifies future cherry picks, and also keeps the git log clean.

### Hooks into other Subsystems

**[ci skip]**: If your commit does not need to go through the Continuous Integration server, add `[ci skip]` to your commit message.
This is used for updates to the documentation and stylesheet changes.

# Reviewing Changes

The review process is a conversation between the submitter and the team as a whole.
Please feel free to bring other people into the conversation as necessary.

As either the submitter or reviewer, feel free to assign the Pull Request to a repository contributor.
This is a way of indicating that you want that repository contributor to review the change.

When you do assign someone to the Pull Request, please make sure to add a comment stating why you assigned it to them.

## Responsibilities of a Reviewer

As a reviewer, it is important that the pull request:

* Has a [well written commit message](#well-written-commit-messages)
* Has [well written code](#coding-guidelines)
* All tests pass in the test suite
* Any questions regarding the pull request are answered
* Adjudicate if the Pull Request should be squashed into a smaller number of commits

## Responsibilities of the Submitter

**As the submitter**, you should be responsive to the review process:

* answering questions
* making refinements
* providing clarification
* rebasing your commits.

*If your changes are gridlocked please notify [@jeremyf](https://github.com/jeremyf) via a comment on the pull request.*

# Merging Changes

*If a pull request has received at least one Thumbs Up, but has still not been merged, please notify [@jeremyf](https://github.com/jeremyf) via a comment on the pull request.*

**As the submitter,** you should not merge your own pull request.
That is bad form.

**As the reviewer,** if you are comfortable merge the pull request.
 Otherwise feel free to assign the pull request to another contributor for final merging.

**As the merger,** once you have merged the pull request, go ahead and delete the pull request's topic branch.
You are now on the hook for any breaking of the build.
