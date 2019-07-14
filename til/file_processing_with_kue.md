For a recent [side project](https://github.com/jstoebel/svg_gallery), I've been learning more about using Apollo and Graphql to upload files, and using a Kue job queue to process them. Here are some of my notes:

I came across [this tweet](https://codepen.io/ainalem/full/aLKxjm/) demonstrating how to use an svg trace of an image as a placeholder while waiting for the actual image to load. The idea here being that its a better experience if you can show the user a preview of the image they'll recive ASAP while they wait for an image to load. Fortunatly, someone has worked out all of this code in the form of a [webpack loader](https://github.com/EmilTholin/image-trace-loader). It was a small task to covert that over to a function to allow for converting images at [run time](https://github.com/jstoebel/svg_gallery/blob/master/src/lib/traceImage.ts). My initial design was:

 - User uploads an image
 - Process image, return svg string
 - save image metadata, including its svg representation to database
 - Return http response

I quickly found out however that this is a pretty expensive operation. Testing with a 1.6Mb file, takes several seconds to process the image and return the resulting svg string. Much too long for a request/response cycle. Time to use a job queue! A job queue would let us do the following instead

 - User uploads an image
 - Save image meta data (sans svg string) to database
 - Hand processing of svg off to seperate process 
 - return http response
 - Job completes and reutrns svg string to main process
 - Save svg string to database

Kue is a library that leverages the power of Redis which gives us a way for seperate processes to communicate with each other. Here's how it works:

## Creating Jobs

We first create a job queue:

```
import kue from 'kue'
const jobs = kue.createQueue();
```

When a user uploads their file, we are ready to add a job to the queue:

```
const job = jobs.create('svg_trace', {imagePath: fullImagePath});
```

`create` is a method on a job queue that here is taking a couple of arguments. The first is the name of the job (we'll need this name to fetch the job later) and any data the job will need.

Next I will probobly want to attach some event listeners to my job. This will allow the parent process to recive notifications when key events in the job occur. 

```
job.on( 'progress', (progress: number, svg: string) => {
  console.log( 'Job complete' );
  image.update({svg}).then(() => {
    console.log('updated image with svg');
  }).catch((err) => {
    console.log(err);
  })
}).on( 'error', function () {
  console.log( 'Job failed' );
})
```

The job is listening for the `progress` event, expecting to be sent the resulting svg string when it does. It then adds that svg string to the database.

I'm also listening for `error`s in the job and logging them if they occur.

Here's a [list of all of the events](https://github.com/Automattic/kue#job-events) you can subscribe to.

You may have noticed that there is an event called `complete` and are asking yourself "why use `progress` when the job is done?" The reason is that, for some reason the `complete` event does not allow for sending data to the parent process but `progress` does. Since we need to return the svg string (that's the whole point!) `progress` it is!

Finally we have to save the job

```
job.save();
```

## Processing Jobs

In a different file, I'm going to create another job queue to process jobs

```
import kue from 'kue';
import traceImage from './src/lib/traceImage';

const queue = kue.createQueue();

queue.process('svg_trace', 1, async (job, done) => {
  console.log('starting to process', job.data);
  const svg = await traceImage(job.data.imagePath)
  console.log('done with traceImage', svg.length);
  job.progress(1, 1, svg) // progress event passes svg string back to parent process
  done()
})
```

This queue will look for jobs called `svg_trace` and begin working on them. The `job` object has a member `data` which contains the data we provided when setting up the job. We also have to call `done` when the job is done.

The important thing to remember is that job processing should be run in a seperate process. This will allow us to run expensive operations without holding up the request/response cycle in the main process.