Writing a React project in Typescript has been pretty darn fun. The compiler can be quite tricky at times, but the reward for sticking with it is the confidence that a lot (but not all) of the typical errors seen in Javascript development won't come up at all. Undefined is not a function? Not too likely in Typescript. All of the common errors that have something to do with trying to snap two components together incorrectly is pointed out to you as you type it. And since reading stack traces on vanilla JS compiled from ES6 can be a bit daunting, I prefer to just sort out those issues as I write them.

One challenge I gave myself in my quest to learn Typescript is to implement a pomodoro app. One essential component in that would of course be a `Timer`. Here's how I did mine:

# Outline

To start, let's think about home of the user stories related to the `Timer`

 - As a user, I can start a timer for an amount of time I chose.
 - As a user, I can stop the timer.
 - As a user, I can start another timer for a different task causing the currently running timer to stop
 - When the timer runs out, a sound is played and the user is prompted to write a reflection

To achieve this, we'll need several components working together:
 - a `Task`
 - a `StartButton`
 - a `StopButton`
 - and the `Timer`

In this app, a task represents a single task or project at work. Many pomodoros can be run for a task. A user can have many tasks, but can only run a single pomodoro at a time. If a pomodoro is running, and another one is started, the first pomodoro is ended early.

# `Task`

A `Task` is going to be a stateless functional component and accepts the following props

 - the `id` of the task
 - the `name` of the task
 - data on the current `runningTask` from the redux provider (stored inside an object called `pomodoros`)
 - a to function to handle starting a task on the task called `onStartPomodoro`
 - a similar function to handle stoping a pomodoro on the task called `onStopPomodoro`

Here's a simplified implementation

```
import * as React from 'react';
import StartButton from './StartButton'
import StopButton from './StopButton'
import {TaskI} from '../../interfaces/task'
import Timer from '../containers/Timer'

interface TaskProps extends TaskI {
  key: number,
  pomodoros: {
    runningTask: Number
  },
  onStartPomodoro: Function,
  onStopPomodoro: Function
}

const Task: React.SFC<TaskProps> = ({ id, name, classes, pomodoros, onStartPomodoro, onStopPomodoro}) => {

  const isRunning = pomodoros.runningTask === id
  const button = isRunning ?
    <StopButton stop={onStopPomodoro} /> :
    <StartButton start={onStartPomodoro} taskId={id} />

  return(
    <div className="task">
      <h2 className="task__name">{name}</h2>
      <div className="task__button">
        {button}
      </div>
      {isRunning && <Timer minutes="25" seconds="0"/>}
    </div>
  )
}

export default Task;
```

Here's what this component does: if the task is running a pomodor0 (determined by comparing the task id with the `runningTask` value in the redux store) the task will be rendering the timer and a `StopButton`, otherwise a `StartButton`.

# `StopButton` and `StartButton`

The `StopButton` isn't much
```
import * as React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import IconButton from '@material-ui/core/IconButton';

interface I {
  stop: Function
}

const StopButton: React.SFC<I> = ({ stop }) => {
  return (
    <IconButton color="secondary" aria-label="Stop Pomodoro" onClick={() => stop()}>
      <FontAwesomeIcon icon="stop" style={{ color: 'black' }} />
    </IconButton>
  )
}

export default StopButton
```

It accepts one prop, a function called `stop` which tells the redux store that the current task isn't running anymore. I'm using Google's material theme and a font awesome icon. When the icon is clicked the function is fired. That's pretty much it!

The `StartButton` is quite similar. When the start button is click, the passed `start` function tells the redux store that the current task wants to start a pomodoro.
```
import * as React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import IconButton from '@material-ui/core/IconButton';

interface I {
  taskId: Number,
  start: Function
}

const StartButton: React.SFC<I> = ({taskId, start}) => {
  return(
    <IconButton color="secondary" aria-label="Start Pomodoro" onClick={() => start(taskId)}>
      <FontAwesomeIcon icon="play" style={{color: 'black'}}/>
    </IconButton>
  )
}

export default StartButton
```

Those two buttons let us toggle a task's state between running a pomodoro and not. We also can have multiple tasks but only one can be running a pomodoro at a given time.

# `Timer`

Finally we come to the `Timer` component itself. The `Timer` is responsible for displaying the time remaining and playinga sound when its done.

It accepts two props: the `minutes` and `seconds` of the pomodoro. Since the component also needs to deal with time, I decided to make it stateful. Its internal state will be:
 - The `timeLeft` expressed as a string. Example `25:00`
 - The exact time when timer will be `doneAt`
 - if the timer is `finished`

Here's what it looks like
```
import * as React from 'react'
import PomodoroI from '../../interfaces/pomodoro'
import * as moment from 'moment';
import Typography from '@material-ui/core/Typography';
import Sound from 'react-sound';
const pomodoroDone = require('../../media/pomodoroDone.mp3')

interface TimerProps {
  minutes: Number,
  seconds: Number,
}

interface TimerState {
  timeLeft: String,
  doneAt: moment.Moment,
  finished: Boolean,
}

class Timer extends React.Component<TimerProps, TimerState> {
  timerHandle: NodeJS.Timer

  constructor(p: TimerProps, s: TimerState) {
    super(p, s);
    const {minutes, seconds} = this.props;
    const timeLeft = moment.utc(moment.duration({ minutes: minutes, seconds: seconds } as moment.DurationInputObject).asMilliseconds()).format("mm:ss")
    this.state = { 
      timeLeft: timeLeft,
      doneAt: moment()
        .add(minutes as unknown as moment.unitOfTime.DurationConstructor, 'minutes')
        .add(seconds as unknown as moment.unitOfTime.DurationConstructor, 'seconds'),
      finished: false,
    }
    this.timerHandle = setInterval(this.tick.bind(this), 100)
  }

  componentWillUnmount() {
    clearInterval(this.timerHandle)
  }

  tick() {
    const timeLeft = this.state.doneAt.diff(moment())
    if (timeLeft > 0 ) {
      this.setState({
        timeLeft: moment.utc(timeLeft).format('mm:ss')
      })
    } else {
      this.wrapUp()
    }
  }
  wrapUp() {
    clearInterval(this.timerHandle)
    this.setState({finished: true})
  }

  render() {
    const soundPlayStatus = this.state.running ? Sound.status.STOPPED : Sound.status.PLAYING
    return(
      <div>
        <Typography variant = "display1">
          {this.state.timeLeft}
        </Typography >
        <Sound url={pomodoroDone} playStatus={soundPlayStatus} />
      </div>
    )
  }
}

export default Timer
```

When the component is set up, we use the moment.js library to compute the initial state. When then use `setInterval` to call the `tick` method. Every 100 miliseconds, we recompute the `timeLeft`, and updated the `timeLeft`. The effect is a timer ticking down to zero.

As an alternative, I could, have instead of using a `doneAt` state, stored `timeLeft` as a moment.js time and decremented it by 1 second each second. While that would have probobly worked fine as well, it seemed to me that I would be reimplementing something that the system clock does perfectly well already. This implementation establishes a concrete end time and then, when its time to update, computes time based on that fixed time.

When the time is up, we call the `wrapUp` method which toggles `finished` to `true` which in turn causes a sound to play. I've not yet implemented the functionality to prompt the user to write a reflection, but that workflow would be triggered here as well.

Finally, there's one more thing we need to consider. What happens when the user starts another `Timer`, thus causing this `Timer` to unmount? It turns out that React gets sad when there is a `setInterval` handler attached to a component that goes away. To remedy this, we implement `componentWillUnmount` and clear the interval.
