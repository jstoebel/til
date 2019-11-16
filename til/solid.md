SOLID Ruby by Jim Weirich
https://www.youtube.com/watch?v=dKRbsE061u4

Object Oriented Design is concerned with dependencies

Car --> engine

Car can send messages to engine, engine doesn't know anything about the car

Car --> Vehicle

Car is a type of vehicle and depends on Vehicle existing. Vehicle doesn't know about Car


# Single Responsibility Principle

A class should have only reason to change. If a module or class has two responsibilities, it would need to change when either of those responsibilities changes. If each module has one responsibility they are much more flexible.

If a module's description uses the words `and` or `or` it might be a good hint it is in violation

# Open Closed Principal
Open chest surgery is not needed when putting on a coat

You should be able to extend a classes behavior without modifying it

Let's say there is an open source library and I need it to do something new. I can make my own library that sub classes it and add my own features.

Prefer subclassing or wrapping over reopening of classes! Reopening classes can cause unexpected results

# Dependency Inversion Principle

Would you solder a lamp directly to the electrical wiring in a wall?

Thermostat --> Furnace

The thermostat is hard coded to depend on a furnace object. What we really want is for the thermostat to control anything that has the same interface as the furnace (on and off methods). What if, for example we wanted to wire a thermostat to a lightbulb that turns on when ever the temp goes above a certain temperature.

Thermostat --> OnOffDevice <-- Furnace

We've inverted the dependency. Both classes depend on the interface but they are no longer coupled.

What's an interface? Method signatures without an implementation.

Ruby doesn't do interfaces. If an object responds to `on` and `off`, that's good enough!

Some people want to use `is_a?` to check the type of a dependency. This reintroduces coupling!

Ruby instead uses protocols which are not code but an idea. A list of methods with certain semantics. A furnace conforms to the on/off protocol.

# Listkov Substitution Principal

Derived classes must be substitutable for their base classes.
If it walks like a duck and talks like a duck, treat it like a duck

Let's say there are various implementations of a function to calculate a square root (Math and BetterMath). BetterMath inherits from Math and calculates square root to more decimal places. Since BetterMath can fulfill everything Math can do, then its acceptable. A second subclass LazyMath, which promises fewer decimal places is not acceptable. 

If the new object can fulfill a client's expected contract, it is substitutable

# Interface Segregation Principle

You want me to plug this in where?

Design interfaces that are fine grained. An interface shouldn't imply multiple objects

Ruby: Clients should depend on as narrow a protocol as possible
