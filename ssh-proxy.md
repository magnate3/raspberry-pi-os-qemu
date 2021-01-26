# Access the CS servers 

  * [Terminal over SSH](#terminal-over-ssh)
    * [1\. Use key\-based authentication in lieu of password](#1-use-key-based-authentication-in-lieu-of-password)
    * [2\. Connect to CS servers using one line of command](#2-connect-to-cs-servers-using-one-line-of-command)
    * [3\. Save connection info in SSH config](#3-save-connection-info-in-ssh-config)
  * [Remote development with VSCode](#remote-development-with-vscode)
      * [Launch a terminal](#launch-a-terminal)
      
      * [File browsing &amp; editing](#file-browsing--editing)

This document describes server resources and how to connect for development. 

|                          | Projects    | hardware specs                                | OS               |
| ------------------------ | ----------- | --------------------------------------------- | ---------------- |
| granger1.cs.virginia.edu | p1,p3,p4    | Dual Xeon 2630v4 Broadwell (10c20t), 20 cores | Ubuntu 20.04 LTS |
| labsrv06.cs.virginia.edu | p1,p2,p3,p4 | Single Xeon Silver 4410 CPU (8c16t), 8 cores  | Ubuntu 20.04 LTS |

Using your CS credentials (not the UVA ones). See [wiki page](https://www.cs.virginia.edu/wiki/doku.php?id=compute_resources). Contact felixlin@ if you do not have CS credentials. 

These servers are behind the campus firewall. You need to first SSH to **portal.cs.virginia.edu**, and from there SSH over to the CS servers, e.g. labsrv06. This is described [here](https://www.cs.virginia.edu/wiki/doku.php?id=linux_ssh_access). 

<img src="images/servers.png" alt="image-20210124164456011" style="zoom:50%;" />

## Terminal over SSH

```
$ ssh xl6yq@portal.cs.virginia.edu
(type in password...)
Warning: No xauth data; using fake authentication data for X11 forwarding.
Last login: Sun Jan 24 16:48:29 2021 from c-71-62-166-85.hsd1.va.comcast.net
********************************** **********************
Type "module avail" to see software available.
See: www.cs.virginia.edu/computing for more information.

$ ssh xl6yq@granger1.cs.virginia.edu
(type in password...)
Welcome to Ubuntu 20.04 LTS (GNU/Linux 5.4.0-45-generic x86_64)
```

SSH Connecting to CS servers can be automated. 

![](images/ssh-proxy.gif)

The picture shows the final results: From a local terminal (e.g. my minibox), connecting to a CS server by simply typing `ssh granger1`. Read on for how to configure.

### 1. Use key-based authentication in lieu of password 

Applicable local environment: Linux, Windows (WSL)

The pub key on your local machine is at `~/.ssh/id_rsa.pub`. Check out the file & its content. If it does not exist, generate a pub key by running `ssh-keygen`. 

```
# on the local console (Linux or WSL)
$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/xzl/.ssh/id_rsa):
```

Now, append your pubic key to both portal and granger1 (`~/.ssh/authorized_keys`). 

Don't do this manually. Instead, do so by the command `ssh-copy-id`. For instance: 

```
# copy the pubkey from your local machine to portal
$ ssh-copy-id xl6yq@portal.cs.virginia.edu
(... type in password ...)

# connect to "portal", it should no longer ask for password
$ ssh xl6yq@portal.cs.virginia.edu

# now we are on "portal", copy the pubkey to the cs server
$ ssh-copy-id xl6yq@granger1.cs.virginia.edu
(... type in password ...)

# it should no longer ask for password
$ ssh xl6yq@granger1.cs.virginia.edu
```

If things do not work, e.g. servers keep asking for passwords even after copying ssh key over, chances are that these keys do not have right file permissions on your local machine filesystem or on the server filesystem. A quick Googling can yield quick fixes. 

### 2. Connect to CS servers using one line of command

```
$ ssh -l USERNAME granger1.cs.virginia.edu -J portal.cs.virginia.edu
```
The -J option is available with your local ssh client OpenSSH >= 7.3p1. See [here](https://unix.stackexchange.com/questions/423205/can-i-access-ssh-server-by-using-another-ssh-server-as-intermediary/423211#423211) for more details. For instance, my version: 

```
$ ssh -V
OpenSSH_7.6p1 Ubuntu-4ubuntu0.3, OpenSSL 1.0.2n  7 Dec 2017
```

### 3. Save connection info in SSH config

Append the following to your ssh client configuration (`~/.ssh/config`). **Replace USERNAME with your actual username**: 

```
Host granger1
   User USERNAME
   HostName granger1.cs.virginia.edu
   ProxyJump USERNAME@portal.cs.virginia.edu:22
```
With the configuration, your local ssh client knows that when connecting  to host `granger1`, use `portal` as the jump proxy. So you can directly connect to `granger1` from your local machine: 
```
$ ssh granger1
```

## Remote development with VSCode 

Many students may prefer VSCode. Here is how to make it work for our kernel hacking. 

End results: being able to develop, compile, and do version control from VSCode. See an example screenshot below. 

![image-20210124192213976](vscode-remote-files)

So we will use VSCode's official Remote.SSH extension. I do not recommend 3rd party extensions, e.g. sftp. 

An official tutorial is [here](https://code.visualstudio.com/docs/remote/ssh). 

tl;dr: VSCode will connect to the CS server (Linux) using SSH under the hood. To do so you install the "Remote development" [package](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) which will install the "Remote.SSH" extension for VSCode. 

#### Windows caveat 1: ssh keys

The extension (Remote.SSH) will invoke Window's ssh client (`c:\Windows\System32\OpenSSH\ssh.exe`), which different from the ssh client that you run in WSL. The Window's ssh client expects its config file at `C:\Users\%USERNAME%\.ssh\config`. If you haven't generated your SSH keys so far, you can do so by launching a PowerShell console and run `ssh-keygen` there. 

| ![](powershell.png) | ![](powershell-sshkeygen.png) | ![](wslroot.png)  |
| ------------------- | ----------------------------- | ----------------- |
| *Launch PowerShell* | *ssh-keygen in PowerShell*    | *Access WSL root* |

Or, you can you copy existing ssh keys and config (e.g. from WSL `~/.ssh/`) to the location mentioned above. Btw, the way to access WSL's root filesystem is to type `\\wsl$` in the explorer address bar. See the figure above. 

#### Windows caveat 2: an outdated ssh client 

The current VSCode has a bug that breaks ssh with jumphost. You have to manually fix it by following [this](https://github.com/microsoft/vscode-remote-release/issues/18#issuecomment-507258777). In a nutshell, manual download a newer win32 ssh to overwrite the one shipping with Win 10 (it's a good idea to save a back up). Window's security mechanism is in your way. Work around it. 

| <img src="images/vscode-ssh-override.png" alt="image-20210124190827946" style="zoom:50%;" /> | <img src="images/win-ssh-version.png" alt="image-20210124190904980" style="zoom: 67%;" /> |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| *Turning off protection on ssh.exe (see link above)*         | *The newer ssh client manually installed*                    |



Now, you should be good to go with VSCode. 

Make sure you have the Remote.SSH extension installed. Click "Remote Explorer" on the left bar. The extension will pick up your ssh config file (again that's `C:/Users/%USERNAME%/.ssh/config`) and present a list of hosts recognized. Click one to connect to it. The extension will copy a bunch of stuffs to the host and launch some daemon on the host. Then you are connected. 

#### Launch a terminal

After connection, click "remote" on the left bar to bring up a remote terminal, in which you can execute commands to build projects, etc. Make sure to click the "+" sign to create a new terminal. 

![image-20210124192109456](images/vscode-remote-terminal.png)

#### File browsing & editing

Then you will specify a remote folder on the server to "open": 

![image-20210124192002504](images/vscode-remote-folder.png)

To browse & edit files on the server, click "explorer" on the left bar

![image-20210124192213976](images/vscode-remote-files.png)

Click  "source control" on the left bar for a handy git interface. 