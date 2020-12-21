---
title: "用Docker定制Ubuntu启动光盘镜像"
date: 2020-12-21
description: "用Docker定制Ubuntu启动光盘"
tags: ["tmux","linux","ssh","运维"]
categories: ["运维"]
typora-copy-images-to: upload
---


# 用Docker定制Ubuntu启动光盘镜像

ubuntu 启动光盘镜像通常用于安装Ubuntu，但也可以用于其他一些情况，包括没有持久性的预配置桌面和用于安装的自定义iso。传统上，这些都是用[chroots](https://help.ubuntu.com/community/LiveCDCustomizationFromScratch)制作的。还有一些图形化工具也可以制作，比如[Cubic](https://launchpad.net/cubic)，这使得这个过程更容易。
但是，这个过程没有任何内置的“检查点”，所以很难迭代。不过，Docker的[镜像创建系统](https://docs.docker.com/develop/develop-images/baseimages/)是其中一个做得很好的工具. 本文将介绍如何使用该系统创建ubuntu 启动光盘镜像。

## 构建环境

本工具需要一个支持[squashfs-tools-ng](https://github.com/AgentD/squashfs-tools-ng)工具的Linux发行版，用来解包和重打包ISO镜像。截止本文创作时，Ubuntu 20.04LTS时是最好的支持该工具的Ubuntu发行版。因此本工具采取了一个Ubuntu 20.04LTS的虚拟机作为构建环境。

[Docker](https://docs.docker.com/engine/install/ubuntu/) 当然是必不可少的.

```bash
# 安装docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh
```

用下面的命令安装其他的依赖包。

```sh
sudo apt-get install p7zip-full grub2-common mtools xorriso squashfs-tools-ng
```

最后，需要下载基础的Ubuntu启动光盘镜像。下载地址在https://ubuntu.com/download/desktop。 (此过程可能也适用于其他Ubuntu版本（例如服务器版本），但是通常有更好的方法来部署服务器。)

## 创建Docker基础映像

ISO通过引导Linux内核，挂载squashfs映像并从中启动Ubuntu来工作。 因此，我们需要从ISO中获取该squashfs映像并从中创建一个Docker基础映像。

运行以下命令以从ISO中提取squashfs映像：

```sh
# UBUNTU_ISO_PATH=path to the Ubuntu live ISO downloaded earlier
7z e -o. "$UBUNTU_ISO_PATH" casper/filesystem.squashfs
```

然后将该squashfs映像导入Docker：

```sh
sqfs2tar filesystem.squashfs | sudo docker import - "ubuntulive:base"
```

这将需要几分钟才能完成。

## Customising using a Dockerfile

现在，squashfs映像可作为Docker中的映像使用，我们可以构建一个对其进行修改的[Dockerfile](https://docs.docker.com/engine/reference/builder/)。

```dockerfile
# 在上一节中，我们将squashfs映像导入Docker中，镜像名为'ubuntulive:base'
FROM ubuntulive:base

# 设置环境变量，以便apt非交互地安装软件包
# 这些变量将仅在Docker中设置，而不在安装镜像中设置
ENV DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical

# 进行一些修改，例如 安装谷歌浏览器
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get update
RUN apt-get install -y google-chrome-stable

# 安装重新包装ISO所需的软件包（我们将使用此映像重新包装自身）
# 安装BIOS支持：grub-pc-bin
# 安装EFI支持：grub-egi-amd64-bin and grub-efi-amd64-signed 
# 构建ISO：grub2-common, mtools and xorriso
# 其中xorriso在universe源
RUN add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
RUN apt-get install -y grub2-common grub-pc-bin grub-efi-amd64-bin grub-efi-amd64-signed mtools xorriso

# 删除过时的软件包和任何临时状态
RUN apt-get autoremove -y && apt-get clean
RUN rm -rf \
    /tmp/* \
    /boot/* \
    /var/backups/* \
    /var/log/* \
    /var/run/* \
    /var/crash/* \
    /var/lib/apt/lists/* \
    ~/.bash_history
```

在尝试构建自定义映像之前，请运行以下命令从构建上下文中排除squashfs映像和ISO，以节省时间。

```sh
echo "**/*.squashfs" >> .dockerignore
echo "**/*.iso" >> .dockerignore
```

现在，要构建您的自定义图像，请运行。

```sh
sudo docker build -t ubuntulive:image .
```

如果您对输出不满意或发生错误，请修改Dockerfile并再次运行以上命令以重试。 通过复制docker build输出中的最后一个成功的Image ID并运行其实例，还可以随时探索映像和/或测试命令。 例如：`sudo docker run -it --rm IMAGE_ID /bin/bash`.

## 重新打包squashfs映像

完成`docker build`后，提取Docker镜像并将其转换回squashfs镜像。

```sh
# run an instance of the Docker image
CONTAINER_ID=$(sudo docker run -d ubuntulive:image /usr/bin/tail -f /dev/null)
# delete the auto-created .dockerenv marker file so it doesn't end up in the squashfs image
sudo docker exec "${CONTAINER_ID}" rm /.dockerenv
# extract the Docker image contents to a tarball
sudo docker cp "${CONTAINER_ID}:/" - > newfilesystem.tar
# get the package listing for installation from ISO
sudo docker exec "${CONTAINER_ID}" dpkg-query -W --showformat='${Package} ${Version}\n' > newfilesystem.manifest
# kill the container instance of the Docker image
sudo docker rm -f "${CONTAINER_ID}"
# convert the image tarball into a squashfs image
tar2sqfs --quiet newfilesystem.squashfs < newfilesystem.tar
```

## 重新打包ISO映像

现在我们有了新的squashfs镜像，下一步将重新打包ISO镜像。

```sh
# create a directory to build the ISO from
mkdir iso

# extract the contents of the ISO to the directory, except the original squashfs image
# UBUNTU_ISO_PATH=path to the Ubuntu live ISO downloaded earlier
7z x '-xr!filesystem.squashfs' -oiso "$UBUNTU_ISO_PATH"

# copy our custom squashfs image and manifest into place
cp newfilesystem.squashfs iso/casper/filesystem.squashfs
stat --printf="%s" iso/casper/filesystem.squashfs > iso/casper/filesystem.size
cp newfilesystem.manifest iso/casper/filesystem.manifest

# update state files
(cd iso; find . -type f -print0 | xargs -0 md5sum | grep -v "\./md5sum.txt" > md5sum.txt)

# remove obsolete files
rm iso/casper/filesystem.squashfs.gpg

# build the ISO image using the image itself
sudo docker run \
    -it \
    --rm \
    -v "$(pwd):/app" \
    ubuntulive:image \
    grub-mkrescue -v -o /app/ubuntulive.iso /app/iso/ -- -volid UbuntuLive
```

大功告成！ 重新打包的自定义Ubuntu启动光盘镜像现在可以在`./ubuntulive.iso`中找到。 使用[GNOME Boxes](https://help.gnome.org/users/gnome-boxes/stable/)或其他VM工具对其进行测试，或使用`dd`或GUI工具（例如[balenaEtcher](https://www.balena.io/etcher/)）将其转变为可启动的USB驱动器。

## 注意事项

- 我没有使用这些ISO进行安装，因此自定义后我还没有测试过部分功能
- 在安装过程中与systemd交互的软件包将失败，因为Docker环境中没有运行systemd实例。 这仅是非标准包装的问题； 所有Ubuntu / Debian软件包都可以正确处理这种情况
- 用于引导的内核映像是ISO的一部分，不会通过此过程从Dockerfile中进行更新（例如，通过`apt`）。 要更新内核映像，请下载新的Ubuntu live ISO，然后重复所有步骤，包括重新创建Docker基本映像。 如果未重新创建Docker基本映像，则它可能与内核映像版本不同步，并且ISO不会启动。


## 参考
[1]: https://slai.github.io/posts/customising-ubuntu-live-isos-with-docker/



- 欢迎评论以及发邮件和作者交流心得。
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar,您的打赏是我创作的重要源泉](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: [m2kar.cn#gmail.com](mailto:m2kar.cn@gmail.com)
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://m2kar.blog.csdn.net)