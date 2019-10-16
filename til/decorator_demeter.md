# Decorators and the Law of Demeter

The basic definition of a decorator is creating a new object that implements the same interface as an existing object but has different responsibilities. Perhaps the most familiar example of the decorator pattern in the Ruby/Rails world is using a decorator to wrap an active record object to handle presentation concerns. This is done to keep models from getting too big and being responsible for too much. The draper gem is a popular choice for this, but I thought I would implement a dead simple decorator for my own learning.

Let's say we're building a good ole' simple CMS. We start out with a table called `articles`

```
rails g model article title body:text published_at:datetime
```

Let's say I want a method called `age` which will print out a human friendly string about how long ago the article was published. For example "Published 1 day ago". This is a good candidate for a method that should exist in a decorator and not the main object because this is primarily a presentation concern. So let's create that.

The first thing I want is a method on all active record objects called `decorate` which returns the corresponding decorator.

```ruby
# app/models/application_record.rb
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def decorate
    "#{self.class}Decorator".constantize.new(self)
  end
end
```

Here I'm using a little meta programing to instantiate a new decorator based on the class name of the called instance. If this was going into production I might consider moving `decorate` into a module and mixing it into the models that I want to have this power, but for simplicity I'm leaving it here for now.

Next I'm going to make a `BaseDecorator`

```ruby
# app/decorators/base_decorator.rb
require 'delegate'

class BaseDecorator
  attr_reader :object

  # dynamically assign what methods are delegated from the base object
  def self.delegate_methods(*methods)
    methods.each { |method| delegate method, to: :object }
  end

  def initialize(base_object)
    @object = base_object
  end
end
```

At a minimum each decorator exposes a reference (`.object`) to its underlying object. It also provides an interface for decorators to specify what methods on the base object will be delegated to the decorator. This is where the the decorator pattern starts to make a lot of sense. Having to constantly reference `object` in order then access the API of the underlying active record object is not great design. Aside from the fact that its annoying, it violates the Law of Demeter or talking to strangers. check out [this great article](https://dev.to/carlillo/demeters-law-dont-talk-to-strangers-10ep) by Carlos Caballero which explains it. In a nutshell, to quote from the article, respecting this law is generally a good idea because:

> Dependencies between classes and coupling are reduced.
> Reuse the classes with ease.
> The code is easier to test.
> The code is more maintainable and flexible to changes.

Reflecting on the Law of Demeter, it might be a good idea to remove public access to the `object` method on `BaseDecorator`, leaving it as an implementation detail. Draper made the decision to keep `.object` available, deciding to let the programmer make the call if they want to break the law. The decision of whether or not to expose `object` publicly is a good discussion worth having when designing a decorator API. 

I also created a class method `delegate_methods` which allows classes to specify what methods on the base class will be delegated to the decorator. The method uses some rails magic to let calls to a specified method pass through to the main object. Again, given the Law of Demeter, delegation is a better strategy than publicly exposing the underlying object

Now that I've got the base class for my decorators, here's the `ArticleDecorator`

```ruby
# app/decorators/article_decorator.rb
class ArticleDecorator < BaseDecorator
  # returns a humanized string describing how long ago the article was published
  delegate_methods :published_at
  include ActionView::Helpers::DateHelper
  def age
    "Published #{time_ago_in_words(published_at)} ago"
  end
end
```

The end result is a decorator object that is able to fulfil its obligations strictly related to the presentation layer:

```
irb(main):001:0> a = Article.first
  Article Load (0.4ms)  SELECT  "articles".* FROM "articles" ORDER BY "articles"."id" ASC LIMIT ?  [["LIMIT", 1]]
=> #<Article id: 1, title: "First Post", body: "blah blah blah", published_at: "2019-09-11 00:08:34", created_at: "2019-09-12 00:08:34", updated_at: "2019-09-12 00:08:34">
irb(main):002:0> a_dec = a.decorate
=> #<ArticleDecorator:0x00007feca3a577c8 @object=#<Article id: 1, title: "First Post", body: "blah blah blah", published_at: "2019-09-11 00:08:34", created_at: "2019-09-12 00:08:34", updated_at: "2019-09-12 00:08:34">>
irb(main):003:0> a_dec.age
=> "Published 2 days ago"
irb(main):004:0> a_dec.published_at
=> Wed, 11 Sep 2019 00:08:34 UTC +00:00
```
