# Testing mixins in Ruby

I've started working on [this tutorial](http://tutorials.jumpstartlab.com/topics/decorators.html) to learn more about the decorator pattern. One interesting topic that came up was the concept of creating decorations which can be mixed in to a decorator, rather than using inheritance. Wanting to use TDD where ever possible I set out to write some tests first. I got stuck there for a bit, so I thought I should write out my solution here.

Here is a module of a couple deocrations that could be mixed in to a decorator.

```
module IconLinkDecorations
  def delete_icon(link_text = nil)
    h.link_to icon_tag('cancel.png', link_text),
              h.polymorphic_path(object),
              method: :delete,
              confirm: "Delete '#{object}'?"
  end

  def edit_icon(link_text = nil)
    h.link_to icon_tag('page_edit.png', link_text),
              h.edit_polymorphic_path(object)
  end

  private

  # renders an icon with a label
  def icon_tag(file_name, text)
    image = h.image_tag(file_name)
    image += " #{text}" if text.present?
    image
  end
end
```

Its a few methods related to rendering an icon related to resource reciving the mixin. But how do we test it? If this was a decorator, we could make assertions against an instance of the class.  This isn't a class at all though, its a collection of methods that can be added to a class. One option would be to test a class that consumes this module, but that doesn't feel right: **we want a true unit test or tests that examine this module in isolation from any other part of the system**

After some research, here's what I came up with: **create a dead simple class that will consume the module and then test that**. For example:

```
class DummyObject
  include IconLinkDecorations
  def initialize(helper_double, object_double)
    @helper_double = helper_double
    @object_double = object_double
  end

  def h
    @helper_double
  end

  def object
    @object_double
  end
end
```

This is `DummyObject` which we will be feeding our decorations and then making sure they work properly. Consumers of `IconLinkDecorations` are expected to have two members: `h` which points to the rails helper and `object` which references the object being decorated. We'll use test doubles for these members to avoid having to pull them into the test as well. Again, we want to isolate this module from other parts of the system.

Next, we can create mocks for the expected behavior of `h` and `object` and then just ensure that the proper messages are passed with the expected arguments. For example:

```
describe IconLinkDecorations do
  let(:helper_double) { double('helper_double') }
  let(:object_double) { 'my object' }
  let(:image) { 'my image' }
  let(:path) { double('path') }
  let(:obj) { DummyObject.new helper_double, object_double }
  describe '#delete_icon' do
    let(:options) { { method: :delete, confirm: "Delete 'my object'?" } }

    before(:each) do
      expect(helper_double).to receive(:polymorphic_path)
        .with(object_double)
        .and_return(path)
    end

    it 'displays a delete icon with text' do
      extra_text = 'my extra text'
      expect(helper_double).to receive(:link_to)
        .with("#{image} #{extra_text}", path, options)

      expect(helper_double).to receive(:image_tag)
        .with('cancel.png')
        .and_return(image)

      obj.delete_icon extra_text
    end
  end
end
```

How do we test `#delete_icon`? We ensure that:
 - that `h.image_tag` is called with `cancel.png`
 - that `h.polymophic_path` is called with `object`.
 - that `h.link_to` is called with
   -  the result of the private method `icon_tag`
   -  the result of the call to `polymorphic_path`
   -  an options hash

There is no need to examine the return value of `delete_icon`. If we can make sure that the right methods are called with the right arguments, we can be sure this module is doing its job. All of the methods listed above are not implemented in this module and therefore shouldn't be tested here.
