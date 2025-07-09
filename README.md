# wrlbuild-ubuntu1804

This dockerfile builds an image capable of building older versions of Wind River Linux LTS on newer Linux hosts, based on Ubuntu 18.04

## Requirements
You must have docker installed and be able to run it without root privelege. i.e. you should be a member of the 'docker' group and be able to run the following without `sudo`
```
$ docker run --rm hello-world
```
---

## Container Build instructions:

Enter the directory with the `Dockerfile` and run:
```
$ . ./build.sh
```
Or just open a shell in the same directory as the `Dockerfile` and run
```
docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) \
    -f Dockerfile -t wrlbuild-ubuntu1804 .
```

---



### Next, Create an alias in `~/.bash_aliases`

This assumes you have a local mirror of the Wind River Linux repo, so replace the `/path/to/LTS18_MIRROR` with your local mirror path (not including the wrlinux-x directory in the path)

If you clone directly from the Wind River git repo, then ignore the WRL_MIRROR.

Examples:
```
alias lts18shell='export WRL_MIRROR=/path/to/LTS18_mirror; docker run --rm -it --workdir $(pwd) -u wrlbuild -e WRL_MIRROR=$WRL_MIRROR -e UID=$(id -u) -e GID=$(id -g) -e LANG=en_US.UTF-8 -v $WRL_MIRROR:$WRL_MIRROR -v $(pwd):$(pwd) wrlbuild-ubuntu1804'
alias lts19shell='export WRL_MIRROR=/path/to/LTS19_mirror; docker run --rm -it --workdir $(pwd) -u wrlbuild -e WRL_MIRROR=$WRL_MIRROR -e UID=$(id -u) -e GID=$(id -g) -e LANG=en_US.UTF-8 -v $WRL_MIRROR:$WRL_MIRROR -v $(pwd):$(pwd) wrlbuild-ubuntu1804'
```
> Note: Remember to source `~/.bash_aliases` the first time after adding alias.

---

## How to use
- run `lts18shell` (for example)
- proceed to build your WRL LTS/Yocto platform per normal use, for example:
```
$ mkdir myproj && cd myproj
$ lts18shell
wrlbuild@eee4d9ac3be1:/home/rmoore/myproj$ git clone --branch WRLINUX_10_18_LTS $WRL_MIRROR/wrlinux-x
wrlbuild@eee4d9ac3be1:/home/rmoore/myproj$ ./wrlinux-x/setup.sh --machines=qemux86-64 --distros=wrlinux --accept-eula=yes
```
- exit the shell when you're done
- invoke the shell whenever you need to build WR Linux


---

### Getting `runqemu` to work in the docker shell
Some changes are required to run `runqemu` in the build container. 

First, use this as your alias
```
alias lts18tun='export WRL_MIRROR=/opt/wr/wrl/lts18/mirror; docker run --rm -it --privileged -v /sbin/iptables:/sbin/iptables -v /dev/net/tun:/dev/net/tun --workdir $(pwd) -u wrlbuild -e WRL_MIRROR=$WRL_MIRROR -e UID=$(id -u) -e GID=$(id -g) -e LANG=en_US.UTF-8 -v $WRL_MIRROR:$WRL_MIRROR -v $(pwd):$(pwd) wrlbuild-ubuntu1804'

```

Next, in order to launch the qemu image you just built, do something like this:
```
runqemu qemuarma9 slirp nographic qemuparams="-m 1024 -netdev user,id=mynet0,net=10.10.11.0/24,dhcpstart=10.10.11.200"

or

runqemu qemuarm64 slirp nographic qemuparams="-m 4096 -netdev user,id=mynet0,net=10.10.11.0/24,dhcpstart=10.10.11.200"

```
Note: if you get error messages about device `net0` being unavailable, you might have to go into `<proj_dir>/tmp_glibc/deploy/images/qemuarma9/` and edit the appropriate `.conf` file, replacing `net0` with `mynet0` or similar.


## Limitations
- can't execute `runqemu` due to lack of `tun` mapping into the container
```
test alias, mapping in /dev/net/tun:

alias lts18tun='export WRL_MIRROR=/opt/wr/wrl/lts18/mirror; docker run --rm -it --privileged -v /sbin/iptables:/sbin/iptables -v /dev/net/tun:/dev/net/tun --workdir $(pwd) -u wrlbuild -e WRL_MIRROR=$WRL_MIRROR -e UID=$(id -u) -e GID=$(id -g) -e LANG=en_US.UTF-8 -v $WRL_MIRROR:$WRL_MIRROR -v $(pwd):$(pwd) wrlbuild-ubuntu1804'
```

### Alternative to Alias: Create a bash function in `~/.bashrc`

Example:
```
lts18shell() {
    export WRL_MIRROR=/path/to/LTS18mirror;   
    docker run --rm -it \
    -w $(pwd) -u wrlbuild \
    -e WRL_MIRROR=${WRL_MIRROR} \
    -e UID=1000 -e GID=1000 \
    -e LANG=en_US.UTF-8 \
    -v ${WRL_MIRROR}:${WRL_MIRROR} \
    -v $(pwd):$(pwd) \
    wrlbuild-ubuntu1804
}
```
> Note: set WRL_MIRROR to the location of the local mirror for your version of WR Linux, or do it inside of the alias or function. Remember to source `~/.bashrc` the first time after adding function.
