The Adaptor pattern is a way to make two objects work together even if they don't have compatable interfaces. An obivous analogy can be found with most people who use a Macintosh computer. I have a Macbook with usb-c ports and a monitor that uses HDMI. My mac can't talk to my monitor as is. It needs an adaptor to bridge the gap!

# Color Cannon

The `ColorCannon` class is a simple object that when given an array of colors can fire them off one by one or in rapid fire.

```ruby
require './color_cannon'
require './color_cannon_adaptor'

# using the color cannon the way it was first imagined. With an array of colors
canon = ColorCannon.new(['#DD4686', '#A1E237', '#01FEC5'])
canon.fire_all

# Boom! Here's #DD4686
# Boom! Here's #A1E237
# Boom! Here's #01FEC5
```


Cool! I'd like to load it up with some random colors from the [GitHub hex bot](https://github.com/noops-challenge/hexbot/). But there's one problem: the API returns an complex object with colors and color cannon needs a simple array. To make it work we have some options.

 1. We could convert the data to the format needed by `ColorCannon`

This is certinaly valid, but imagine that we have colors coming from lots of different sources. Does `ColorCannon` need to be able to handle all of them? This would violate the Single Responsability Pinciple. The `ColorCannon` should be concerned with firing colors, not with a sprawling problem of converting data formats.

 2. We could extend the `ColorCannon` class to accept the data we're getting from the API.

There's nothing wrong with this either, but that could get messy. Again, imagine colors coming from lots of different sources.

3. We could write an adaptor

The adaptor is an entierly seperate class who responsability is to help two classes that are other wise compatable be able to talk to each other. In this case we need to make a string representation of json work with the `ColorCannon`

```ruby
# here we are fetching colors that come to us in a non compatable format. An adaptor encapsulates the conversion to make them compatable.
require 'net/http'
colors_json_str = Net::HTTP.get(URI.parse('https://api.noopschallenge.com/hexbot?count=3'))
colors = ColorCannonAdaptor.new(colors_json_str)
canon = ColorCannon.new(colors)
canon.fire_all

# Boom! Here's #1B6497.
# Boom! Here's #AC1344.
# Boom! Here's #F234D0.
```

