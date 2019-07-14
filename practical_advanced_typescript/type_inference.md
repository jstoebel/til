*infer type in switch statements*

Let's say I have a switch statement that is switching on an argument's type:

```
export interface Action {
  type: string;
}

export class Add implements Action {
  readonly type: string = "Add";
  constructor(public payload: string) {}
}

export class RemoveAll implements Action {
  readonly type : string= "Remove All";
}

interface ITodoState {
  todos: string[];
}

function todoReducer(
  action: Action,
  state: ITodoState = { todos: [] }
): ITodoState {
  switch (action.type) {
    case "Add": {
      return {
        todos: [...state.todos, action.payload]
      };
    }
    case "Remove All": {
      return {
        todos: []
      };
    }
  }
  return state;
}
```

The intention is to say "if the action is of type Add do x, but if its RemoveAll do y". The problem is that we've not been explicit enough for the compiler to know that the first branch will only work with type `Add`. We're checking the value of `action.type` sure, but typescript is being told that the `type` field is a `string`. Not specific enough. Also what if there were another type that also had `Add` for its value in `type`.

To help the compiler we need to do two things. First we need to change `readonly type: string = "Add";` to `readonly type = "Add";`. This tells typescript that `type` is of type "Add"` since its value can't be updated.

Second, the function signature isn't specific enough either:
```
function todoReducer(
  action: Action,
  state: ITodoState = { todos: [] }
)
```

In this simple example `Add` and `RemoveAll` are the only two types that implement `Action`, but there could be others!  We need to tell TS that `Add` or `RemoveAll` are the only possible types to be passed in

```
type Actions = Add | RemoveAll // not the `s` at the end.

//...

function todoReducer(
  action: Actions,
  state: ITodoState = { todos: [] }
)
```

*using `never`*

to continue the example above, we can use `never` in a default block to let TS know to throw an error if neither branch is used

```

default: {
  const x: never = action;
}

```

In my opinion this feels a little clumsy, but it gets the job done: a compile time error if TS knows its possible to reach this code.