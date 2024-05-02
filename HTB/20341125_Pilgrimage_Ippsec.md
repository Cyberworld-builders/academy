# Pilgrimage
> Hackthebox retired box walkthrough by Ippsec from November 25, 2023

## About this Document

### Purpose

I want to gather some materials to help myself and others who are mostly new to hacking. My approach is to follow retired box walkthroughs step by step and document every command, tool, concept, term, idea, etc. The more walkthroughs I document, I expect to get a feel for how to prioritize what to learn and how much time to invest. As I start to notice trends and patterns, I will go down rabit holes of research into those technologies.

### The "White Rabit" Style of Learning

I like to take an adventurous and curiosity-based approach to learning things. I go deep down rabit holes. I get bored and pivot abruptly. This is an attempt to leave a trail of bread crumbs so that I can codify patterns as they emerge. 

## Ticket Description

[Ticket 11: HTB: Retired Box Walkthrough Study](https://github.com/Cyberworld-builders/academy/issues/11)

Choose a walkthrough of a retired HTB box and break it down step by step. Include a list of software, commands, tools, exploits, protocols and overall IT concepts. Define all of the terms and then expand upon them from a technical perspective. Make sure to include a summary explaining the hack in 3-5 sentences at the top. Just below that show the list of commands. Then a glossary of terms. After that, tell the story of the hack, stopping as needed to explain technical concepts in more depth.

The idea is to keep doing this with retired boxes until strategy and workflow patterns begin to emerge. Over time, as we notice trends, we can develop material that can be reused, inserted and linked to in various forms and contexts.

Here's a good playlist from Ippsec:

[IppSec - Hack the Box - Easy *nix Boxes Walkthroughs](https://www.youtube.com/playlist?list=PLqyUgadpThTKZ_ZOqeNrxair1EeYZAKT5)

## Links, Commands, Tools, Vulnerabilities, Exploits and Technologies

### Links

These are any relevant links.

[Pilgrimage](https://www.youtube.com/watch?v=aaUlHicClrI&list=PLqyUgadpThTKZ_ZOqeNrxair1EeYZAKT5&index=1&t=4s)

### Tools

These are the hacking tools used by the attacker.

- Burp Suite
- Go Buster
- Git Dumper

### Vulnerabilities

These are any known vulnerabilities exploited by the attacker for the hack.

- [CVE-2022-44268](https://nvd.nist.gov/vuln/detail/CVE-2022-44268)

### Exploits

These are the exploits that the attacker used from the community.

- 

### Technologies

These are the technologies used by the target.

- ImageMagick version (7.1.0-49) 
- binwalk 2.3.2
- Nginx
- Ubuntu
- PHP
- Git
- 

### Commands

These are the bash commands run by the attacker.

#### Service Enumeration
```bash
sudo nmap -sC -sV -oA nmap/pilgrimage 10.10.11.219
```

#### Search for a PNG file
```bash
locate -r png
```

#### Copy a file to the current directory
```bash
cp /usr/share/zenity/zenity.png .
```

#### Enumerate valid directories with Gobuster
```bash
gobuster dir -u http://pilgrimage.htb -w /opt/SecLists/Discovery/Web-Content/raft-small-words.txt -x php -o root.gobuster.out
```

## Summary

- 00:00 - Introduction
- 00:55 - Start of nmap
- 03:00 - Uploading an image file and trying to identify how the upload works
- 06:20 - Running Git-Dumper to download the exposed .git directory, taking a look at the source code
- 09:45 - Looking at the ImageMagick version (7.1.0-49) and seeing it is vulnerable to CVE-2022-44268
- 13:30 - Generating a malicious image and downloading the sqlite database
- 19:30 - Doing a PS and seeing inotifywait is being used to run a bash script when files created in web directory
- 21:35 - Showing why the bash script is not vulnerable
- 28:00 - Finding a binwalk exploit for version 2.3.2, which takes advantage of path traversal in PFS files
- 32:50 - Taking a look into the exploit to see how it works
- 35:30 - Showing the PFS File Format

1. Service enumeration
2. Server redirects to domain. Add domain to hosts file.
3. Rerun nmap enumeration command
4. Check out the website in a browser
5. Since it's a file uploading app, search for a png.
6. Copy the last file in the results to the current directory.
7. Before uploading it, prepare to analyze the requests with Burp Suite
8. Used the repeater tab to rapidly repeat the request.
9. Analyzed the response object.
10. Grabbed a link from the web interface once the upload is successful.
11. Noticed it renames the file.
12. Tried uploading a .php file to see if we can hit it.
13. It gets converted back to a png
14. Tried discovering an "uploads" directory.
15. Enumerate valid directories with gobuster.
16. Tried accessing the /tmp/ directory. 404
17. Tried /tmp/ with the known file. 404
18. Considering testing for race conditions but want to save that for the end because we might be able to find out exactly what is happening if we can get the source code.
19. 

## Notes

### Introduction

Hey there, YouTube! It's Ippsec, and today we're tackling the Pilgrimage challenge from Hack The Box. Now, this box really underscores the importance of Reconnaissance, because while many elements appear vulnerable at first glance, they often conceal subtler weaknesses.

Take, for example, the website. It's running a PHP image upload script, which might lead you to assume you can upload PHP files and execute them. However, there's a twist. By exposing the "dogit" directory, you can uncover a source code leak. This exposes the ImageMagick version, revealing a CVE that grants code execution on the box.

Now, once you've gained access, keep an eye out for a process utilizing INotify Wait. This acts as a hook, monitoring directory activity. When files are created, a bash script kicks in to perform malware scans. Upon closer inspection, the bash script might seem to harbor a command injection vulnerability. But it's not quite that simple.

In reality, the vulnerability lies within the version of Binwalk being used. This flaw allows for the writing of files to the operating system. With this understanding, let's dive right in!

### Initial Nmap

Here's a clearer and formatted version of the instruction:

---

**Initial Nmap Command:**

"We're starting off with an Nmap scan. So, we use `-sC` for default scripts and `-sV` to enumerate versions. Then, `-oA` to output in all formats. We'll put the results in the 'nmap' directory and call it 'pilgrimage'. Finally, we specify the IP address as 10.10.11.219. This might take some time to run, so I've already executed it."

```bash
sudo nmap -sC -sV -oA nmap/pilgrimage 10.10.11.219
```

- `sudo`: Executes the Nmap command with administrative privileges, enabling access to lower-level network functions.
- `nmap`: Initiates the Nmap scanning tool.
- `-sC`: Enables default script scanning, which runs a set of scripts designed to detect common vulnerabilities and perform basic enumeration.
- `-sV`: Enables version detection, which attempts to determine the versions of services running on the target machine.
- `-oA nmap/pilgrimage`: Specifies the output format and file name prefix for the scan results. In this case, it saves the results in three formats: normal, grepable, and XML, with the prefix "pilgrimage" in the directory "nmap."
- `10.10.11.219`: Specifies the IP address of the target machine to be scanned.

This command covers script scanning, version enumeration, and outputs the results in multiple formats for further analysis.

https://youtu.be/aaUlHicClrI?si=tdARU-7zzUA4dy_R&t=65

Got it, let's move on to the next section. How about we call this part "Service Enumeration"? Here's the revised content:

---

**Service Enumeration:**

Now that we've laid the groundwork, let's delve into service enumeration. Our initial Nmap scan has likely uncovered a wealth of information about the target machine's running services and their versions. Armed with this knowledge, we can begin to probe deeper into each service to identify potential vulnerabilities.

We'll start by examining each service individually, conducting targeted scans to gather more detailed information. This process involves analyzing banners, checking for known vulnerabilities, and exploring any exposed functionality.

Remember, thorough service enumeration is crucial for identifying potential attack vectors and devising an effective exploitation strategy. So, let's roll up our sleeves and dive into the world of service enumeration!

**Port Enumeration and Host File Configuration:**

From our initial scan results, we've identified just two open ports on the target machine. The first is SSH on Port 22, which reveals that it's running on a Debian server based on the banner information.

The second open port is HTTP on Port 80, indicating an Nginx server. Additionally, the server redirects us to "pilgrimage.htb". To streamline our access, let's add this information to our host file.

We'll use the `sudo` command to edit the host file and map the IP address 10.10.11.219 to the domain name "pilgrimage.htb".

```bash
sudo nano /etc/hosts
```

Then, add the following line:

```
10.10.11.219   pilgrimage.htb
```

This adjustment will simplify our interactions with the target server as we proceed with our reconnaissance and exploitation efforts.

https://youtu.be/aaUlHicClrI?si=UcUnslRZtJe3Bel7&t=102


**Inspecting Requests with Burp Suite:**

Before proceeding with any uploads, it's a good practice to intercept and analyze the requests using Burp Suite. This allows us to gain insight into the data being sent and received between our browser and the server.

Upon intercepting the requests and clicking the "shrink" button on the website, we observe that it initiates an upload process. The request contains a variable to convert, the file name, and the image file itself.

After forwarding the request to the Repeater tab in Burp Suite, we receive a successful response from the server. By examining the response, we find a link to the uploaded file, confirming that the process was indeed successful.

With this understanding, we can proceed confidently with our exploration and potential exploitation of the upload functionality on the website.