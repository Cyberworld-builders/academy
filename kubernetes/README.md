# Kubernetes

## Notes
- 

## Docker Commands

### Run a Docker Image
```sh
docker run <image>:<tag>
```

### Build a Docker Image
```sh
docker build -t <image>:<tag> .
```

### Run an Image with a Name, Expose a Port

```sh
docker run --name <give-me-a-name> -p <host-port>:<container-port> -d <image>:<tag>
```

### Inspect an Image
```sh
docker inspect <image>:<tag>
```
### Run a Shell in a Container
```sh
docker exec -it <cointainer-name> bash
```

### Stop a Running Container
```sh
docker stop <container-name>
```

### Remove a Container
```sh
docker rm <container-name>
```

## Linux Commands

### List Processes
```sh
ps aux
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

### Create a Dockerfile to run the Node App

```Dockerfile
# Dockerfile
FROM node:12
ADD app.js /app.js
ENTRYPOINT ["node", "app.js"]
```

### Build the Image

```sh
docker build -t kubia .
```
> ***NOTE:***
> One common mistake I see out in the wild is poorly-designed Dockerfiles. There are many developers who are either new to Docker or maybe they just never took the time to do a deep dive into the basics of what Docker does and how it works. It's easy to jam all your steps into a Dockerfile and when it works, it works.

> It is important to take care when designing Dockerfiles. Make sure you are not including unnecessary files. Make sure you are layering your Dockerfiles such that the layers can be stored and re-used instead of forcing your builds to have to create redundant layers.

> This will make your deployments to build faster and use fewer computing resources.

### Run the Node Docker Image
This command runs your image with a name that you specify and exposes a port. It also specifies that it will run detached from the shell. In this example, your node app should display a message to your browser from your node app.
```sh
docker run --name kubia-contaner -p 8080:8080 -d kubia
```

### Curl the App
You can also test it from the shell with `curl`.
```sh
curl localhost:8080
```
#### Response
```
You've hit 64f3e62426a2
```

### Inspect the Image
```sh
docker inspect kubia-container
```

### Run a Shell in Your Container

```sh
docker exec -it kubia-container bash
```

- `-i` makes sure STIDIN is kept open.
- `-t` allocates a pseudo terminall (TTY)

> NOTE: This `bash` process will have the same Linux namespaces as the main container process.

### List the Processes Running in your Container
```sh
ps aux
```

#### Response
```
root@64f3e62426a2:/# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.4 550360 35812 ?        Ssl  19:06   0:00 node app.js
root          13  0.0  0.0   3744  2944 pts/0    Ss   20:53   0:00 bash
root          19  0.0  0.0   5860  2432 pts/0    R+   20:57   0:00 ps aux
```

> NOTE: Each container has its own PID Linux namespace, it's own isolated process tree, and an isolated filesystem. 

### Grep our Node Command from Running Processes
```sh
ps aux | grep app.js
```

```response 
root@64f3e62426a2:/# ps aux | grep app.js
root           1  0.0  0.4 550360 35812 ?        Ssl  19:06   0:00 node app.js
root          21  0.0  0.0   2636  1408 pts/0    S+   21:03   0:00 grep app.js
```
### Stop Your Container
```sh
docker stop kubia-container
```

### Remove Your Container
```sh
docker rm kubia-container
```

