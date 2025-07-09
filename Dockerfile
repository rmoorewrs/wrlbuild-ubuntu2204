FROM ubuntu:24.04

ARG UNAME=wrlbuild
ARG GID=1001
ARG UID=1001

RUN \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confnew" -qy install --no-install-recommends \
    texi2html \
    chrpath \
    diffstat \
    subversion \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libsdl1.2-dev \
    texinfo \
    gawk \
    gcc \
    gcc-multilib \
    help2man \
    g++ \
    git-core \
    bash cpio \
    python3 python3-pip python3-pexpect debianutils iputils-ping locales \
    diffutils xz-utils make file screen sudo wget time patch openssh-client \
    curl \
    vim-tiny \
    less \
    iproute2 \
    iputils-ping \
    bzip2 \
    uuid-runtime \
    rsync \
    strace \
    sysstat \
    dumb-init && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man && \
    rm -rf /usr/share/doc && \
    rm -rf /usr/share/grub2 && \
    rm -rf /usr/share/texmf/fonts && \
    rm -rf /usr/share/texmf/doc && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# add user to sudoers after sudo is installed
RUN groupadd --gid $GID -o $UNAME
RUN useradd --home-dir /home/$UNAME --uid $UID --gid $GID --shell /bin/bash $UNAME && \
	echo "$UNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


ENTRYPOINT ["/usr/bin/dumb-init"]

CMD ["/bin/bash"]

USER $UNAME
