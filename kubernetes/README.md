# Kubernetes

## Notes
- 

## Commands

### Run a Docker Image
```sh
docker run <image>:<tag>
```


## Exercises

### Run a Docker Image
```sh
docker run busybox echo "Hello World"
```

#### Response
```
Unable to find image 'busybox:latest' locally
latest: Pulling from library/busybox
c34182c7a03d: Pull complete 
Digest: sha256:5eef5ed34e1e1ff0a4ae850395cbf665c4de6b4b83a32a0bc7bcb998e24e7bbb
Status: Downloaded newer image for busybox:latest
Hello World
```

### Create a Simple Node App

>  The code is simple: it listens on port 8080 and responds with the hostname of the server. 
 Now, let’s create a Dockerfile to build the image: 
 // Path: academy/apps_hello-node/Dockerfile

```js
// app.js

const http = require('http');
const os = require('os');

console.log("Kubia server starting...");

var handler = function(request, response) {
  console.log("Received request from " + request.connection.remoteAddress);
  response.writeHead(200);
  response.end("You've hit " + os.hostname() + "\n");
}

var www = http.createServer(handler);
www.listen(8080);
```