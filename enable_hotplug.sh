#!/bin/bash

cp /proc/sys/kernel/hotplug /bin/
chmod +x /bin/hotplug

echo /sbin/mdev > /proc/sys/kernel/hotplug

# mdev -s
touch /dev/mdev.log

mkdir -p /etc/hotplug/usb
cat > /etc/hotplug/usb/udisk_insert<<EOF
#!/bin/sh  
echo "usbdisk insert!" > /dev/console
if [ -e "/dev/\$MDEV"  ]  ; then
    mkdir -p /mnt/usbdisk/\$MDEV
    mount /dev/\$MDEV /mnt/usbdisk/\$MDEV
    echo "/dev/\$MDEV mounted in /mnt/usbdisk/\$MDEV" > /dev/console
fi  
EOF

cat > /etc/hotplug/usb/udisk_remove<<EOF
#!/bin/sh
echo "usbdisk remove!" > /dev/console
umount -l /mnt/usbdisk/sd*
rm -rf /mnt/usbdisk/sd*
EOF

chmod 755 /etc/hotplug/usb/*

cat >> /etc/mdev.conf <<EOF

#usb devices
sd[a-z][0-9]      0:0 666        @/etc/hotplug/usb/udisk_insert
sd[a-z]           0:0 666        $/etc/hotplug/usb/udisk_remove

EOF

sed -i "s/sda1/#sda1/g" /etc/mdev.conf

mkdir -p /etc/hotplug/sd
cat > /etc/hotplug/sd/sd_insert <<EOF
#!/bin/sh
echo "sd card insert!" > /dev/console
if [ -e "/dev/\$MDEV"  ]; then  
    mkdir -p /mnt/sdcard/\$MDEV
    mount -rw /dev/\$MDEV /mnt/sdcard/\$MDEV
    echo "/dev/\$MDEV mounted in /mnt/sdcard/\$MDEV" >/dev/console
fi
EOF

cat > /etc/hotplug/sd/sd_remove <<EOF
#!/bin/sh
echo "sd card remove!" > /dev/console
umount -l /mnt/sdcard/*
rm -rf /mnt/sdcard/*
EOF

chmod 755 /etc/hotplug/sd/*

cat >> /etc/mdev.conf <<EOF

#tf card devices
mmcblk0p[0-9]     0:0 666        @/etc/hotplug/sd/sd_insert
mmcblk0           0:0 666        $/etc/hotplug/sd/sd_remove

EOF

sed -i "s/mmcblk0p1/#mmcblk0p1/g" /etc/mdev.conf

