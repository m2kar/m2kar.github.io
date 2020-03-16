---
title: "安装ubuntu docker完整版"
date: 2020-03-16
description: "安装ubuntu docker完整版"
tags: ["tmux","linux","ssh","运维"]
categories: ["运维"]
---

# 安装ubuntu docker完整版

困扰了很久怎么安装ubuntu docker的完整版，后来发现从ssh登陆进docker镜像的时候有提示，可以用一条命令完美安装ubuntu的完整版。

## 命令
```bash
unminimize
```

## 执行效果

```bash
➜  ~ unminimize
This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

This script restores content and packages that are found on a default
Ubuntu server system in order to make this system more suitable for
interactive use.

Reinstallation of packages may fail due to changes to the system
configuration, the presence of third-party packages, or for other
reasons.

This operation may take some time.

Would you like to continue? 
```

大功告成！


## 脚本内容
发现并不是每个ubuntu 版本都有这个脚本，所以把这个脚本贴出来了。

脚本位于 `/usr/local/sbin/unminimize`。

具体内容如下：
```bash
#!/bin/sh

set -e

echo "This system has been minimized by removing packages and content that are"
echo "not required on a system that users do not log into."
echo ""
echo "This script restores content and packages that are found on a default"
echo "Ubuntu server system in order to make this system more suitable for"
echo "interactive use."
echo ""
echo "Reinstallation of packages may fail due to changes to the system"
echo "configuration, the presence of third-party packages, or for other"
echo "reasons."
echo ""
echo "This operation may take some time."
echo ""
read -p "Would you like to continue? [y/N]" REPLY
echo    # (optional) move to a new line
if [ "$REPLY" != "y" ] && [ "$REPLY" != "Y" ]
then
    exit 1
fi

if [ -f /etc/dpkg/dpkg.cfg.d/excludes ] || [ -f /etc/dpkg/dpkg.cfg.d/excludes.dpkg-tmp ]; then
    echo "Re-enabling installation of all documentation in dpkg..."
    if [ -f /etc/dpkg/dpkg.cfg.d/excludes ]; then
        mv /etc/dpkg/dpkg.cfg.d/excludes /etc/dpkg/dpkg.cfg.d/excludes.dpkg-tmp
    fi
    echo "Updating package list and upgrading packages..."
    apt-get update
    # apt-get upgrade asks for confirmation before upgrading packages to let the user stop here
    apt-get upgrade
    echo "Restoring system documentation..."
    echo "Reinstalling packages with files in /usr/share/man/ ..."
    # Reinstallation takes place in two steps because a single dpkg --verified
    # command generates very long parameter list for "xargs dpkg -S" and may go
    # over ARG_MAX. Since many packages have man pages the second download
    # handles a much smaller amount of packages.
    dpkg -S /usr/share/man/ |sed 's|, |\n|g;s|: [^:]*$||' | DEBIAN_FRONTEND=noninteractive xargs apt-get install --reinstall -y
    echo "Reinstalling packages with system documentation in /usr/share/doc/ .."
    # This step processes the packages which still have missing documentation
    dpkg --verify --verify-format rpm | awk '/..5......   \/usr\/share\/doc/ {print $2}' | sed 's|/[^/]*$||' | sort |uniq \
         | xargs dpkg -S | sed 's|, |\n|g;s|: [^:]*$||' | uniq | DEBIAN_FRONTEND=noninteractive xargs apt-get install --reinstall -y
    if dpkg --verify --verify-format rpm | awk '/..5......   \/usr\/share\/doc/ {exit 1}'; then
        echo "Documentation has been restored successfully."
        rm /etc/dpkg/dpkg.cfg.d/excludes.dpkg-tmp
    else
        echo "There are still files missing from /usr/share/doc/:"
        dpkg --verify --verify-format rpm | awk '/..5......   \/usr\/share\/doc/ {print " " $2}'
        echo "You may want to try running this script again or you can remove"
        echo "/etc/dpkg/dpkg.cfg.d/excludes.dpkg-tmp and restore the files manually."
    fi
fi

if ! dpkg-query --show --showformat='${db:Status-Status}\n' ubuntu-minimal 2> /dev/null | grep -q '^installed$'; then
    echo "Installing ubuntu-minimal package to provide the familiar Ubuntu minimal system..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-minimal ubuntu-standard
fi

if dpkg-query --show --showformat='${db:Status-Status}\n' ubuntu-server 2> /dev/null | grep -q '^installed$' \
   && ! dpkg-query --show --showformat='${db:Status-Status}\n' landscape-common 2> /dev/null | grep -q '^installed$'; then
    echo "Installing ubuntu-server recommends..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y landscape-common
fi

# unminimization succeeded, there is no need to mention it in motd
rm -f /etc/update-motd.d/60-unminimize

```


-------

- 欢迎评论以及发邮件和作者交流心得。
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar,您的打赏是我创作的重要源泉](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: [m2kar.cn#gmail.com](mailto:m2kar.cn@gmail.com)
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://m2kar.blog.csdn.net)
