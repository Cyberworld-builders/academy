# HTB Starting Point
This is a cheat sheet of frequently-used links, commands, tools, etc.

## Commands

### Connect to HTB VPN
You will always begin by connecting to the VPN. I was having issues on my PC with WSL/Ubuntu, but my Mac connected fairly quickly.
```bash
sudo openvpn {MY_OVPN_PROFILE_FILE}
```

### Enumerate Services
Once you are connected, always start by running `nmap` on the target.
```bash
sudo nmap -sC -sV -oA nmap/{BOX_NAME} {TARGET_IP}
```

## Tools

### Nmap

### Gobuster

### Hashcat

