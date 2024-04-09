#!bin/sh

Lib=("os-prober" "grub")


if [ "$EUID" -ne 0 ]; then
	echo "Run this sript as sudo"
	exit 1
fi	

check_dependencies()
{
	read -p "Do you want to install missing libraries? [Y/n]: " answer
	answer=${answer:Y}
	[[ $answer =~ [Yy] ]] && apt-get install ${Lib[@]}
	if [ -f /etc/default/grub ]; then
		cat /etc/default/grub | grep -q "GRUB_DISABLE_OS_PROBER=false"
		if [ $? -eq 0 ]; then
			echo "GRUB OS_PROBER already set to false";
		else
			echo "Setting GRUB OS_PROBER to false"
			sed -i 's/GRUB_DISABLE_OS_PROBER=true/GRUB_DISABLE_OS_PROBER=false/';
		fi
	fi
}

installation()
{
	check_dependencies
	echo "Detecting os on your system..."
	sleep 1
	os-prober
	echo "Adding others os to grub..."
	grub-mkconfig -o /boot/grub/grub.cfg
}

installation
echo "You can reboot now :)"
