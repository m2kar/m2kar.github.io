---
title: "lvm磁盘备份、替代、和修复方案"
date: 2020-10-17
description: "lvm磁盘备份、替代、和修复方案"
tags: ["linux","lvm","运维"]
categories: ["运维"]
---


# lvm磁盘备份、替代、和修复方案

## 创建lvm组VG0和分区LVA并挂载到/A
> Make lvm volume group VG0 and partition LVA and mount to /A

```bash
root@vm-ubu:/home/rui# lvmdiskscan 
 /dev/loop0 [   14.50 MiB] 
 /dev/loop1 [   140.66 MiB] 
 /dev/sda1 [   <80.00 GiB] 
 /dev/loop2 [   <90.99 MiB] 
 /dev/loop3 [   <12.99 MiB] 
 /dev/loop4 [   <34.54 MiB] 
 /dev/loop5 [   <2.25 MiB] 
 /dev/loop6 [   <3.70 MiB] 
 /dev/sdb  [    2.00 GiB] 
 /dev/sdc  [    2.00 GiB] 
 2 disks
 8 partitions
 0 LVM physical volume whole disks
 0 LVM physical volumes

root@vm-ubu:/home/rui# pvcreate /dev/sdb
 Physical volume "/dev/sdb" successfully created.
 
root@vm-ubu:/home/rui# vgcreate VG0 /dev/sdb 
 Volume group "VG0" successfully created
 
root@vm-ubu:/home/rui# lvcreate -L 1G VG0 -n LVA
 Logical volume "LVA" created.
 
root@vm-ubu:/home/rui# mkfs.ext4 /dev/mapper/VG0-LVA 
mke2fs 1.44.1 (24-Mar-2018)
Creating filesystem with 262144 4k blocks and 65536 inodes
Filesystem UUID: d2d61132-f79c-486f-a391-8471288bd20e
Superblock backups stored on blocks: 
32768, 98304, 163840, 229376
 
Allocating group tables: done              
Writing inode tables: done              
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
 
root@vm-ubu:/home/rui# mkdir /A
root@vm-ubu:/home/rui# mount /dev/mapper/VG0-LVA /A
root@vm-ubu:/home/rui# seq 100 | xargs -i dd if=/dev/urandom of=/A/{}.dat bs=1024 count=1
```

## 备份分区LVA到A.img
> Backup partition LVA to img file A.img

```bash
root@vm-ubu:/home/rui# apt install gddrescue

root@vm-ubu:/home/rui# ddrescue -d -f -r3 /dev/mapper/VG0-LVA /data/A.img "rescue.$(date).log"
GNU ddrescue 1.22
   ipos:  1073 MB, non-trimmed:    0 B, current rate:  181 MB/s
   opos:  1073 MB, non-scraped:    0 B, average rate:  214 MB/s
non-tried:    0 B, bad-sector:    0 B,  error rate:    0 B/s
 rescued:  1073 MB,  bad areas:    0,    run time:     4s
pct rescued: 100.00%, read errors:    0, remaining time:     n/a
               time since last successful read:     n/a
Finished                   
root@vm-ubu:/home/rui# 
```

## 挂载A.img作为内存设备，并替换掉旧的/A
> Mount A.img as loop device and replace old mount /A

```bash
root@vm-ubu:/home/rui# losetup -P /dev/loop52 /data/
A.img    lost+found/ 
root@vm-ubu:/home/rui# losetup -P /dev/loop52 /data/A.img 
root@vm-ubu:/home/rui# umount /A
root@vm-ubu:/home/rui# mount /dev/loop52 /A
root@vm-ubu:/home/rui# ls A
ls: cannot access 'A': No such file or directory
root@vm-ubu:/home/rui# ls /A
100.dat 15.dat 20.dat 26.dat 31.dat 37.dat 42.dat 48.dat 53.dat 59.dat 
root@vm-ubu:/home/rui# 
```

 

## 删除分区
> Delete partition A

```bash
root@vm-ubu:/home/rui# lvremove /dev/mapper/VG0-LVA 
Do you really want to remove and DISCARD active logical volume VG0/LVA? [y/n]: y
 Logical volume "LVA" successfully removed
```

 

## 恢复A.img到新的lvm分区 LVA，并挂载到/A
> Recovery A.img to new lvm Partition A , Mount A to /A and replace loop device A.img

```bash
root@vm-ubu:/home/rui# fdisk -l /dev/loop52 
Disk /dev/loop52: 1 GiB, 1073741824 bytes, 2097152 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
root@vm-ubu:/home/rui# lvcreate -L 1073741824 bytes VG0 -n LVA
 Volume group "bytes" not found
 Cannot process volume group bytes
 
root@vm-ubu:/home/rui# lvcreate -L 1073741824bytes VG0 -n LVA
WARNING: ext4 signature detected on /dev/VG0/LVA at offset 1080. Wipe it? [y/n]: ^C Interrupted...
 Aborted wiping of ext4.
 1 existing signature left on the device.
 Logical volume "LVA" created.

root@vm-ubu:/home/rui# mkdir /A2
root@vm-ubu:/home/rui# sudo mount /dev/mapper/VG0-LVA /A2/
mount: /A2: wrong fs type, bad option, bad superblock on /dev/mapper/VG0-LVA, missing codepage or helper program, or other error.
root@vm-ubu:/home/rui# ddrescue -d -f -r3 /data/A.img /dev/mapper/VG0-LVA rescue_from_img.log
GNU ddrescue 1.22
   ipos:  1073 MB, non-trimmed:    0 B, current rate:  266 MB/s
   opos:  1073 MB, non-scraped:    0 B, average rate:  357 MB/s
non-tried:    0 B, bad-sector:    0 B,  error rate:    0 B/s
 rescued:  1073 MB,  bad areas:    0,    run time:     2s
pct rescued: 100.00%, read errors:    0, remaining time:     n/a
               time since last successful read:     n/a
Finished                   
root@vm-ubu:/home/rui# sudo mount /dev/mapper/VG0-LVA /A2/
root@vm-ubu:/home/rui# ls /A2/
100.dat 15.dat 20.dat 26.dat 31.dat 37.dat 42.dat 48.dat 53.dat 59.dat 
root@vm-ubu:/home/rui# 
```
## 在线缩容

```bash
root@vm-ubu:/home/rui# lvresize -L -300M --resizefs /dev/mapper/VG0-LVA 
Do you want to unmount "/A2" ? [Y|n] y
fsck from util-linux 2.31.1
/dev/mapper/VG0-LVA: 111/65536 files (0.0% non-contiguous), 13055/262144 blocks
resize2fs 1.44.1 (24-Mar-2018)
Resizing the filesystem on /dev/mapper/VG0-LVA to 185344 (4k) blocks.
The filesystem on /dev/mapper/VG0-LVA is now 185344 (4k) blocks long.
 
 Size of logical volume VG0/LVA changed from 1.00 GiB (256 extents) to 724.00 MiB (181 extents).
 Logical volume VG0/LVA successfully resized.
root@vm-ubu:/home/rui# 
root@vm-ubu:/home/rui# ls /A2/
100.dat 15.dat 20.dat 26.dat 31.dat 37.dat 42.dat 48.dat 53.dat 59.dat 
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
