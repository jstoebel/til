Typescript, while useful tool, can also present its own frustrations. One such example happened to me recently, when I was trying to write a function that has to be able to accept more than one type as a parameter:

Specifically, I was writing a reducer for notifications in my app. One action `ADD_NOTIFICATION` accepts an object as its payload and appends it to an array. The other, `REMOVE_NOTIFICATION` accepts a number and removes the coorsponding object by index. Here was my first attempt:

```
import { Reducer, Action } from 'redux';
import { NotificationI } from '../interfaces/notification'
import C from '../constants';

const initialState = []

interface actionI {
  type: String,
  payload: NotificationI | number
}

const reducer: Reducer<NotificationI[]> = (state = initialState, action: actionI) => {
  const {payload} = action
  switch (action.type) {
    case C.ADD_NOTIFICATION:
      // payload is an object, so append it to the array and return
      return state.concat(payload)
    case C.REMOVE_NOTIFICATION:
      // payload is a number. 
      // Find the object by index, splice it out and return the resulting array.
      const newNotifications = state.slice()
      return newNotifications.splice(payload, 1)
  }
  return state;
}

export default reducer
```

Makes sense right? In the first case of the switch statement, treat `payload` like an object, In the second, treat it like a number. The idea comes as second nature to me coming from dynamicly typed programing. The philosophy there is _we never know what type something is. Just proceed forward and let me know at runtime if we tried to do something with an object that it can't do._ So for example, if we tried to pass an object as payload to `REMOVE_NOTIFICATION` we would get an error when trying to pass it into `.splice` since `.splice` expects a number. Typically in dynamic languages we protect ourselves from this danger by covering our code with tests. This is a perfectly acceptable approach, but Typescript is more picky than that.

Lets go back to where we defined the interface for `action`:

```
interface actionI {
  type: String,
  payload: NotificationI | number
}
```

That pipe operator is telling the compiler "payload will be either a notification object or a number. The compiler is ok with not being sure what type an argument will be. What it is not ok with is the possability the we might end up trying to do something with the argument that makes no sense (such as pass an object to `splice`). The compiler complains:
```
Argument of type 'number | NotificationI' is not assignable to parameter of type 'number'.
  Type 'NotificationI' is not assignable to type 'number'.
```

Basically its saying "I know you _said_ payload could be a `number` but you also said it might be a notification. And if it is, we'll crash when trying to pass it into `splice`.

Fortunatly, there's a way to keep the compiler happy: type guards. Here's an example:

```
function isNotification(payload: NotificationI | Number): payload is NotificationI {
  // message is a member of the notification object
  return (<NotificationI>payload).message !== undefined;
}
```

A type guard is special function because it returns a special type called a type predicate. Basically the compiler will understand this function as one that when fed either a notificaiton or number, it will return `true` if that object is a notification, `false` if it isn't. Type guards are a tool to disambiguate the program and keep the compiler calm. We use them like we would any conditional:

```
const reducer: Reducer<NotificationI[]> = (state = initialState, action: actionI) => {
  const {payload} = action
  switch (action.type) {
    case C.ADD_NOTIFICATION:
      if (isNotification(payload)) {
        return state.concat(payload)
      }
    case C.REMOVE_NOTIFICATION:
      if (!isNotification(payload)) {
        const newNotifications = state.slice()
        return newNotifications.splice(payload, 1)
      }
  }
  return state;
}
```

Now the compiler is not confused. It knows for certain that the first case statement is dealing with a notification object and in the second its dealing with a number.
