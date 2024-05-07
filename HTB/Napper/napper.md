# HTB: Napper

## Box Info
- ***Walkthrough by:*** IppSec
- ***OS:*** Windows
- ***Date:*** November 11, 2023

## Tools Used
- BurpSuite
- Ghidrah
- 

## Known Vulnerabilities Exploited
- 

## Malware Involved
- NapListener
- 

## Related Technology
- Golang
- IIS
- ElasticSearch
- C#
- Dotnet
- Hugo (Site builder for Golang)

## Concepts
- Reverse a Go binary
- 

## Contents
Sure, here's a table of contents for the timestamps:

1. [Introduction](#introduction)
2. [Start of nmap, showing -vv will cause the output to contain TTL](#start-of-nmap)
3. [Checking out the website](#checking-out-the-website)
4. [Doing a VHOST Bruteforce to discover the internal domain and discovering credentials on a blog post](#vhost-bruteforce)
5. [Checking out the NAPListener blog post, which gives us a way to enumerate for the NAPLISTENER Implant](#naplistener-blog-post)
6. [Showing the Backdoor code to discover how it works](#backdoor-code)
7. [Building a DotNet Reverse Shell and renaming the method to Run, then using Mono (mcs) to compile](#dotnet-reverse-shell)
8. [Converting the DLL to base64 and getting NAPLISTENER to execute it](#dll-to-base64)
9. [Discovering a draft blog post talking about them getting rid of laps and building a custom solution that uses elastic](#elastic-blog-post)
10. [Setting up a tunnel with Chisel so we can talk to Elastic](#chisel-tunnel)
11. [Using curl to enumerate Elastic](#curl-enumerate)
12. [Reversing the Golang binary with Ghidra](#golang-reverse)
13. [Creating a Golang Binary to grab a document (seed), then using search to grab the blob, and decrypting it with AES-CFB](#golang-binary)
14. [Connecting to Elastic, using a Proxy](#elastic-proxy)
15. [Grabbing the Seed with the Golang Elastic Library](#grabbing-seed)
16. [Grabbing the Blob with Golang Elastic Library](#grabbing-blob)
17. [Using the Seed to generate our 16 byte key](#generate-16byte-key)
18. [Creating a decrypt function](#decrypt-function)
19. [Getting the PlainText then using RunasCS to get a reverse shell as the Backup User, which is administrator](#plaintext-reverse-shell)

## Timestamps
- [00:00 - Introduction](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=0s)
- [00:55 - Start of nmap, showing -vv will cause the output to contain TTL](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=55s)
- [04:40 - Checking out the website](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=280s)
- [05:23 - Doing a VHOST Bruteforce to discover the internal domain and discovering credentials on a blog post](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=323s)
- [07:30 - Checking out the NAPListener blog post, which gives us a way to enumerate for the NAPLISTENER Implant](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=450s)
- [10:30 - Showing the Backdoor code to discover how it works](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=630s)
- [12:30 - Building a DotNet Reverse Shell and renaming the method to Run, then using Mono (mcs) to compile](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=750s)
- [14:45 - Converting the DLL to base64 and getting NAPLISTENER to execute it](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=885s)
- [19:20 - Discovering a draft blog post talking about them getting rid of laps and building a custom solution that uses elastic](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=1160s)
- [24:00 - Setting up a tunnel with Chisel so we can talk to Elastic](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=1440s)
- [25:55 - Using curl to enumerate Elastic](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=1555s)
- [30:20 - Reversing the Golang binary with Ghidra](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=1820s)
- [42:30 - Creating a Golang Binary to grab a document (seed), then using search to grab the blob, and decrypting it with AES-CFB](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=2550s)
- [47:30 - Connecting to Elastic, using a Proxy](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=2850s)
- [56:00 - Grabbing the Seed with the Golang Elastic Library](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=3360s)
- [1:03:00 - Grabbing the Blob with Golang Elastic Library](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=3780s)
- [1:09:45 - Using the Seed to generate our 16 byte key](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=4185s)
- [1:13:53 - Creating a decrypt function](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=4433s)
- [1:16:30 - Getting the PlainText then using RunasCS to get a reverse shell as the Backup User, which is administrator](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=4590s)

### Introduction
- [00:00 - Introduction](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=0s)

#### Service Enumeration
Using double-verbose flag.
```bash
sudo nmap -sC -sV -oA nmap/napper -vv 10.10.11.240
```

#### Looking at the Results
```bash
less nmap/napper.nmap
```

#### Results
```
Starting Nmap 7.94 ( https://nmap.org ) at 2024-05-06 12:33 CDT
Nmap scan report for 10.10.11.240
Host is up (0.060s latency).
Not shown: 998 filtered tcp ports (no-response)
PORT    STATE SERVICE  VERSION
80/tcp  open  http     Microsoft IIS httpd 10.0
|_http-server-header: Microsoft-IIS/10.0
|_http-title: Did not follow redirect to https://app.napper.htb
443/tcp open  ssl/http Microsoft IIS httpd 10.0
|_http-server-header: Microsoft-IIS/10.0
|_ssl-date: 2024-05-06T17:34:16+00:00; -1s from scanner time.
|_http-title: Research Blog | Home 
|_http-generator: Hugo 0.112.3
| tls-alpn: 
|_  http/1.1
| http-methods: 
|_  Potentially risky methods: TRACE
| ssl-cert: Subject: commonName=app.napper.htb/organizationName=MLopsHub/stateOrProvinceName=California/countryName=US
| Subject Alternative Name: DNS:app.napper.htb
| Not valid before: 2023-06-07T14:58:55
|_Not valid after:  2033-06-04T14:58:55
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
|_clock-skew: -1s

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 26.00 seconds
```

#### Modify Hosts File
```bash
10.10.11.240    app.napper.htb napper.htb ca.napper.htb
```





### Start of nmap, showing -vv will cause the output to contain TTL
- [00:55 - Start of nmap, showing -vv will cause the output to contain TTL](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=55s)

### Checking out the website
- [04:40 - Checking out the website](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=280s)

### Doing a VHOST Bruteforce to discover the internal domain and discovering credentials on a blog post
- [05:23 - Doing a VHOST Bruteforce to discover the internal domain and discovering credentials on a blog post](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=323s)

### Checking out the NAPListener blog post, which gives us a way to enumerate for the NAPLISTENER Implant
- [07:30 - Checking out the NAPListener blog post, which gives us a way to enumerate for the NAPLISTENER Implant](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=450s)

### Showing the Backdoor code to discover how it works
- [10:30 - Showing the Backdoor code to discover how it works](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=630s)

### Building a DotNet Reverse Shell and renaming the method to Run, then using Mono (mcs) to compile
- [12:30 - Building a DotNet Reverse Shell and renaming the method to Run, then using Mono (mcs) to compile](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=750s)

### Converting the DLL to base64 and getting NAPLISTENER to execute it
- [14:45 - Converting the DLL to base64 and getting NAPLISTENER to execute it](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=885s)

### Discovering a draft blog post talking about them getting rid of laps and building a custom solution that uses elastic
- [19:20 - Discovering a draft blog post talking about them getting rid of laps and building a custom solution that uses elastic](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=1160s)

### Setting up a tunnel with Chisel so we can talk to Elastic
- [24:00 - Setting up a tunnel with Chisel so we can talk to Elastic](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=1440s)

### Using curl to enumerate Elastic
- [25:55 - Using curl to enumerate Elastic](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=1555s)

### Reversing the Golang binary with Ghidra
- [30:20 - Reversing the Golang binary with Ghidra](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=1820s)

### Creating a Golang Binary to grab a document (seed), then using search to grab the blob, and decrypting it with AES-CFB
- [42:30 - Creating a Golang Binary to grab a document (seed), then using search to grab the blob, and decrypting it with AES-CFB](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=2550s)

### Connecting to Elastic, using a Proxy
- [47:30 - Connecting to Elastic, using a Proxy](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=2850s)

### Grabbing the Seed with the Golang Elastic Library
- [56:00 - Grabbing the Seed with the Golang Elastic Library](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=3360s)

### Grabbing the Blob with Golang Elastic Library
- [1:03:00 - Grabbing the Blob with Golang Elastic Library](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=3780s)

### Using the Seed to generate our 16 byte key
- [1:09:45 - Using the Seed to generate our 16 byte key](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=4185s)

### Creating a decrypt function
- [1:13:53 - Creating a decrypt function](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=4433s)

### Getting the PlainText then using RunasCS to get a reverse shell as the Backup User, which is administrator
- [1:16:30 - Getting the PlainText then using RunasCS to get a reverse shell as the Backup User, which is administrator](https://www.youtube.com/watch?v=ESXW8jsGkdM&t=4590s)


