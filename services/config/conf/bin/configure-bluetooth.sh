#! /bin/bash

# enable bluetooth for uid 1000

ssh -q -o 'StrictHostKeyChecking no' -p 22222 root@${HOST_IP} << 'EOF'
if [ -f /etc/dbus-1/system.d/bluetooth.conf ] \
   && ! grep -q '<policy user="1000">' /etc/dbus-1/system.d/bluetooth.conf 
then
    echo add uid 1000 to bluetooth.conf on host
    mount -o remount,rw /
    cd /etc/dbus-1/system.d
    cp /etc/passwd /etc/passwd.bak
    echo 'iot:x:1000:100::/home/iot:/bin/sh' >>/etc/passwd
    sed -i.bak 's|</busconfig>|  <policy user="1000"> \
    <allow own="org.bluez"/> \
    <allow send_destination="org.bluez"/> \
    <allow send_interface="org.bluez.GattCharacteristic1"/> \
    <allow send_interface="org.bluez.GattDescriptor1"/> \
    <allow send_interface="org.freedesktop.DBus.ObjectManager"/> \
    <allow send_interface="org.freedesktop.DBus.Properties"/> \
  </policy> \
</busconfig>|' bluetooth.conf
    mount -o remount,r /
fi
echo bluetooth enabled for uid 1000
EOF
