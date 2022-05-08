
.PHONY: all ping role-init

all:
	ansible-playbook site.yml

ping:
	ansible all -m ping

role-init:
	mkdir -p roles
	ansible-galaxy install YasuhiroABE.myfavorite-setting

setup-local:
	sudo apt install pxelinux syslinux-common

setup-filedir:
	ansible all -m file -b -a "path=/app/ub2204/casper state=directory mode=0755 owner=root group=root"
	ansible all -m file -b -a "path=/app/ub2204/pxelinux.cfg state=directory mode=0755 owner=root group=root"
	ansible all -m file -b -a "path=/app/www state=directory mode=0755 owner=root group=root"
	ansible all -m get_url -b -a "url=https://releases.ubuntu.com/22.04/ubuntu-22.04-live-server-amd64.iso dest=/app/www/ mode=644"
	ansible all -m file -b -a "path=/mnt/iso state=directory mode=0755 owner=root group=root"
	ansible all -m command -b -a "mount -o loop,ro /app/www/ubuntu-22.04-live-server-amd64.iso /mnt/iso"
	ansible all -m copy -b -a "remote_src=yes src=/mnt/iso/casper/vmlinuz dest=/app/ub2204/casper/vmlinuz mode=0644 owner=root group=root"
	ansible all -m copy -b -a "remote_src=yes src=/mnt/iso/casper/initrd dest=/app/ub2204/casper/initrd mode=0644 owner=root group=root"
	ansible all -m command -b -a "umount /mnt/iso"

setup-dnsmasq:
	ansible all -m apt -b -a "name=dnsmasq update_cache=yes"
	ansible all -m apt -b -a "name=pxelinux update_cache=yes"
	ansible all -m apt -b -a "name=syslinux-common update_cache=yes"
	ansible all -m systemd -b -a "name=systemd-resolved.service enabled=no state=stopped"
	ansible all -m file -b -a "path=/etc/resolv.conf state=absent"
	ansible all -m copy -b -a "src=files/etc.resolv.conf dest=/etc/resolv.conf mode=0644 owner=root group=root"
	ansible all -m systemd -b -a "name=dnsmasq.service enabled=yes state=started"
	ansible all -m file -b -a "src=/usr/lib/PXELINUX/pxelinux.0 dest=/app/ub2204/pxelinux.0 state=link owner=root group=root"
	ansible all -m file -b -a "src=/usr/lib/syslinux/modules/bios/ldlinux.c32 dest=/app/ub2204/ldlinux.c32 state=link owner=root group=root"
	ansible all -m file -b -a "path=/etc/netplan/00-installer-config.yaml state=absent"

setup-nginx:
	ansible all -m apt -b -a "name=nginx update_cache=yes"
	ansible all -m systemd -b -a "name=nginx.service enabled=yes state=started"

restart-dnsmasq:
	ansible all -m systemd -b -a "name=dnsmasq.service state=restarted"

clean:
	find . -name '*~' -type f -exec rm {} \; -print
