# HTB: Napper

## Box Info
- ***OS:*** Windows
- ***Date:*** November 11, 2023

## Getting Started

#### Service Enumeration
Using double-reverse flag.
```bash
sudo nmap -sC -sV -oA nmap/napper -vv 10.10.11.240
```

#### Response
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

