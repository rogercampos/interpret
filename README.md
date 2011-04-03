Interpret
=========

Interpret is a rails 3 engine to help you manage your application
translations, also allowing you to have editable contents in live. In order to
do so it will register the I18n activerecord backend to be used for your
application. Interpret is pretty tied to it at the moment, but there are plans
to make it backend-agnostic.
We believe that key-value stores as I18n backends are pretty awesome and we
want to support them, although the activerecord backend with Memoize and
Flatten is very fast too, once you have loaded all the data.

Interpret is intented to allow live edition of your contents, making it very
easy for your client, your co-workers or yourself to edit them without a
deployment.

Caching techniques play a key role here in order to expire the page or the
fragment in which a certain content is displayed, and Interpret helps you do
this work with an observer, but you are the responsible to expire your caches.
See later on caching section.

If you want you can also use Interpret only as a translation tool, like
[Tolk](https://github.com/dhh/tolk) in which this gem was initially inspired.
See later the `registered envs` section on how to avoid the registration of
I18n activerecord backend. This way you can still edit your translations as
before, but in this case the modifications you make won't be directly
available in your application.

[SEE DEMO](http://interpretapp.heroku.com)


Installation
===========

Add the gem to your Gemfile:

    gem 'interpret'

Then you must run the interpret setup generator in order to copy some asset
files required for the backoffice section, javascripts, css's and a couple of
images:

    rails g interpret:setup


Finally you should also run this generator to create the 'translations' table
required by the I18n active-record backend:

    rails g interpret:migration



Development considerations
==========================

If you have chosen to have dynamic contents, that is editable text in your
website, this means that all this text information is now stored in some
database. They no longer belongs to the application itself, they're now seed
data, but instead of _create_ it inside `seeds.rb` you edit an `en.yml` file
or something similar. This is the work flow Interpret expects you to follow,
develop your application using the standard `.yml` locale files and put in
there anything you need. Later, after a deployment, run the `update` rake task
to perform a synchronization between the production I18n database and your
modifications inside `.yml` files, not to update the _contents_ but to update
the **keys**.

The tool is different but the concept is the same. The contents you see and
edit in development ARE NOT the same contents you will see in production,
because they're dynamic and someone else may have changed them. However, the
page architecture does belongs to the application, I mean, the actual HTML
code you wrote. One `<h1>`, three paragraphs `<p>` and a list `<ul>` with five
elements `<li>`. This markup is there and it expects to have some text in it,
translated content, and it have to be there. So, that said, it's clear that
you can **edit** the contents, but not _create_ or _remove_ them.


The Update action
=================

The `update` action is the core of Interpret. It performs a synchronization
between your `*.yml` files and the I18n backend translations, and it is
expected to run after a deployment in order to update your production
translations.

- It will create any translation that exists in `.yml` files but not in the
  database backend. When doing so, the value of the translation in yaml files
  are preserved and copied into the database backend. The same happens if you
  have created it in more than one language, it is copied for each locale.

- It will remove any translation that exists in the database backend but not
  in the `.yml` files. Note that you can prevent Interpret to remove anything
  setting the `soft` option described at the bottom of this document.

- For any key that exists in both `.yml` files and database backend it will not
  do anything.


Main language
=============

The `I18n.default_locale` configured in your application will be the _master_
language Interpret will use. Keep in mind that rails lets you have a diferent
locale key hierarchy for each language in the `.yml` files, and this behaviour
is prohibited in Interpret. Here, the `I18n.default_locale` is the only
language that can be trusted to have all the required and correct locale keys
and it will be used to check for inconsitent translations into other
languages, knowing what you haven't translated yet.

This is also the locale used when an `update` action is performed. The
synchronization will only check for inconsistent keys between `.yml` files and
database backend within that **master** language.



Built-in Backoffice
===================

As an Engine, Interpret provides you with a set of _backoffice_ views in order
to manage your translations, and to perform some operations with them. You can
access it to the following path in your app (unless you define some `scope`,
see later):

    http://localhost:3000/interpret

### Overview

This view shows all the translations organized by their keys, in a tree
structure as if they were folders and files. If you're used to the typical
filesystem architecture it's pretty simple.

Here you can edit your translations using
[best_in_place](https://github.com/bernat/best_in_place), such amazing
in-place edition tool by [bernat](https://github.com/bernat).

### Tools

Here you have some tools you can use to work with the translations:

- Export: Clicking the **download** link you will get a typical rails locale file
  for the current language. It's generated with
  [ya2yaml](https://github.com/kch/ya2yaml) so it _may_ be safe to
  use with utf8.

- Import: With the **upload** option you can select a locale file from your
  computer and it will be used to perform a massive translations update. To be
  precise, for each translation you have in that file it will either:
    1. Update that translation if it already exists, or
    2. Create that translation if not


- Update: This action will perform an update from your `.yml` locale files.
  It's described in an earlier section of this readme.

- Dump: Dump the contents of your `.yml` locale files into I18n backend. All
  contents will be overwritten, so be cautious!


All of these operations can be very expensive if you have a large number of
translations, some optimization work is still required!

### Search

You can search by translation key or value, or both of them. The results will
be shown in the same way as in Overview, so you can also edit them from there.



Configuration
=============

To configure Interpret create an initializer file and put in there something
like this:

    Interpret.configure do |config|
      config.parent_controller = "admin/base_controller"
      # Some other configuration options
    end

The following sections describe in detail all the configuration options
available.


Registered environments
-----------------------

Interpret is intended to be used along with I18n active-record backend in
order to provide live edition capabilities for your translations. It will
automatically register the I18n.backend to the active-record one, with Memoize
and Flatten, if the current Rails environment is included in the
`registered_envs` list. By default i's initialized to the following:

    Interpret.registered_envs = [:production, :staging]


You can override it in order to activate it also in development:

    Interpret.configure do |config|
      config.registered_envs << :development
      # ...
    end

Or to disable it if you only want to use Interpret as a translation tool:

    Interpret.configure do |config|
      config.registered_envs = []
      # ...
    end



Adding authorization and custom filters
----------------------------------------

If you want to add some authorization control over Interpret backoffice, or
any custom filters, you can use the `Interpret.parent_controller` option. This
will make all the Interpret controllers to inherit from it, so you can check
for user authentication or whatever:

    Interpret.configure do |config|
      config.parent_controller = "admin/base_controller"
      # ...
    end

For instance, the above code will make Interpret use `Admin::BaseController`
as a base class for all their controllers, and you can put in there any
`before_filter` you want to check for the current logged in user permissions.
It's likely you already have some controller like this to act as a base for
all your existing _admin_ or _backoffice_ controllers.



Custom layouts
--------------

In order to integrate the Interpret views into your existing backoffice, you
can define your own layout to be used by Interpret:

    Interpret.configure do |config|
      config.layout = "backoffice"
      # ...
    end

Then Interpret will use the `layouts/backoffice.html.<wathever>` layout.

If you want further customizations, you can edit the css file Interpret use,
it's in `public/stylesheets/interpret_style.css`. Be aware that this file will
be overwritten the next time you run a `rails g interpret:setup`.

For now there is no generator to copy all the views into your app, but you can
do it yourself by-hand if you want to also customize them.

Remember to load the Interpret stylesheet if you use your own layout:

    = stylesheet_link_tag "interpret_style"


Routes scope
------------

You can make Interpret build their routes inside a scope of your choice:

    Interpret.configure do |config|
      config.scope = "(:locale)"
      # ...
    end

The above code for instance will produce better looking urls inside
interpret, as the current locale will be a prefix of the route instead of a
GET parameter.



Authentication
--------------

You can allow Interpret to know who is the current logged in user by setting
the following:

    Interpret.configure do |config|
      config.current_user = "current_user"
      # ...
    end

If the `Interpret.current_user` option is setted, Interpret will use it in
their controllers and views to retrieve the current user, and log their name
(or whatever string returned by calling `to_s` on it) into the log messages
every time a translation is modified.



Roles
-----

Once you have configured a `current_user` function, Interpret can work with
two different roles. Use the following configuration option:

    Interpret.configure do |config|
      config.current_user = "current_user"
      config.admin = "interpret_admin?"
      # ...
    end

In this example, Interpret will call `current_user.interpret_admin?` to know
if the current logged in user is an interpret admin or not. Depending on the
result of this call Interpret allow more or less functionalities. If you
don't set any `admin` method, all users will be _admins_ inside Interpret. The
same happens if you don't set the `current_user` option. The following roles
are available:

### Editor

When the result is evaluated to false, the user is considered an **editor**.
This role is for an user who is intended to make translations, but no to
_administrate_ the site.

- It will be able to edit translations.
- It won't be able to use any of the **Tools**.
- It won't be able to modify any `protected` translation.

### Admin

When the result is evaluated to true, then the user is considered an
**admin**, so it can:

- Do everything described in the **Built-in Backoffice** section.
- Mark some translations as `protected`, which means only editable by
  admins. This can be used to prevent non-technical people to mess up with
  interpolated translations and things like this.



Live translation edition
------------------------

This feature will let you edit your translations and contents directly from
your application views. This way the edition work is much more user-friendly,
since you're changing what your are seeing. To do so, you will need to do two
things:

1. Let Interpret know about who is logged in, setting the `current_user`
   option.

2. Also set an `admin` option, to discriminate which users are _interpret
   admins_.

3. Use the following helper in your main layout (or all layouts your
   application use):

      `= interpret_live_edition`

   You should use it at the bottom of your `body` block.

4. Set the `Interpret.live_edit` variable to **true**, to enable live edition.

From there, if the current logged in user is an admin, he will be able to
translate contents in live. Note that this is NOT per user, it's a global
setting. Also note that only `admins` can use it. We know about this
limitations and we will improve this functionality in the future for sure.

You also need to take care about caching, obviously this will not work with
cached views.


Caching
-------

Interpret register the I18n activerecord backend with Flatten and Memoize, so
it takes care to reload the I18n backend every time a translation is edited,
created or destroyed. Unfortunately I18n only provides a global method
`.reload!` to expire the cache, so we can't be more precise about what exactly
translation we want to expire, without patching I18n itself at least.

Besides that, if you're using any kind of caching technique you should use the
following:

    Interpret.configure do |config|
      config.sweeper = "my_sweeper"
      # ...
    end

Using the above code you tell Interpret to register the `MySweeper` class as
an observer to `Interpret::Translation`, so you will be able to run expiration
logic when a translation changes. With this, you sweeper is the entirely
responsible to expire caching, and it's responsible to run an
`I18n.backend.reload!` too, unless you inherit from the given
`Interpret::ExpirationObserver` class.

If you want some help with that, the recommended way to run custom expiration
logic is to build your sweeper class like the following:

    class MySweeper < Interpret::ExpirationObserver
      def expire_cache(key)
        # run your expiration logic
      end
    end


One parameter will be passed to your `expire_cache` method, a string
containing the key of the affected translation. It's your business to find
out which page or fragment you have to expire from here.

Also take note that your _sweeper_ class is in fact an observer, not a
Rails sweeper. I've initially implemented this using real sweepers, but I
simply don't like the idea to bind the expiration logic to the controllers.
And Interpret can't afford it since it needs to expire the cache from a rake
task, for example, to run an `update` after a deployment.

So, you won't be able to use the default expire methods rails provides you,
since they are only available from within a controller. You will need to find
out a more **raw** way to expire your cache.


Rake tasks
----------

Interpret comes with two rake tasks, which are simply interfaces to run the
same `update` and `dump` actions you can run from the **Tools** section of the
backoffice.

    rake interpret:update
    rake interpret:dump

The `update` task is what you may want to run after a deployment, for what
Interpret already has a capistrano recipe...


Capistrano recipe
-----------------

Interpret also have a capistrano recipe to run the `update` rake task after
updating code. You only need to require this file in your `deploy.rb`:

    require 'interpret/capistrano'


Soft behavior
--------------

Using this option you choose between give a full control to Interpret over
the I18n translations or not. It defaults to `false` and you can change it
with:

    Interpret.configure do |config|
      config.soft = true
      # ...
    end

- When `soft` is set to false: Then Interpret is the _owner_ of all I18n
  translations, in the sense that it hasn't to be worried about creating or
  deleting translations. This way, if you remove a key from the `.yml` locale
  file Interpret will remove that translation from the I18n backend when you
  run an `update`.

- When `soft` is set to true: Then Interpret will be more cautious with your
  translations, and won't remove any of them even though if you have removed
  the key in the `.yml` file. This is intented to be used when you have a
  situation where your I18n translations are used by some _other means_.
  Initially I've implemented this to make Interpret compatible with
  [Armot](https://github.com/rogercampos/armot), a tool for handle model
  translations directly with I18n activerecord backend.

  In this case, if some translation exists in the I18n backend but not in `.yml`
  files, Interpret has no way to know if it's because you have removed them or
  because it's a translation handled outside Interpret. So, you will end up
  with unused translations in your database.


Logger
------

Updating, removing or creating a translation will result in a new entry in the
log file `log/interpret.log`. The user who made the modification will be also
registered in the log entry, if `current_user` is available.

This can be used as a sort-of backup system, to restore the old contents of a
certain translation. It won't be very difficult to write some script to do
this, but by now it's not included in Interpret.


Final notes
===========

Thanks to [NodeThirtyThree](http://nodethirtythree.com) for their website
templates released under CreativeCommons 3.0 license, one of which is used
here.

This piece of software is on a very early stage of development, so use it at your
own risk!
