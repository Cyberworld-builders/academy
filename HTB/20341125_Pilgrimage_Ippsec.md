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

## Notes

### Introduction

Hey there, YouTube! It's Ippsec, and today we're tackling the Pilgrimage challenge from Hack The Box. Now, this box really underscores the importance of Reconnaissance, because while many elements appear vulnerable at first glance, they often conceal subtler weaknesses.

Take, for example, the website. It's running a PHP image upload script, which might lead you to assume you can upload PHP files and execute them. However, there's a twist. By exposing the "dogit" directory, you can uncover a source code leak. This exposes the ImageMagick version, revealing a CVE that grants code execution on the box.

Now, once you've gained access, keep an eye out for a process utilizing INotify Wait. This acts as a hook, monitoring directory activity. When files are created, a bash script kicks in to perform malware scans. Upon closer inspection, the bash script might seem to harbor a command injection vulnerability. But it's not quite that simple.

In reality, the vulnerability lies within the version of Binwalk being used. This flaw allows for the writing of files to the operating system. With this understanding, let's dive right in!
