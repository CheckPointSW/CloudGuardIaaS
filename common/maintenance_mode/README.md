# Maintenance mode 
The Maintenance Mode boot option is known on UNIX systems as 'single-user mode'. In this mode, a Virtual Machine (VM) boots to run level 1. The local file systems will be mounted, but the network will not be activated.

## Configuration
The configuration below related to Azure and Google Cloud Platform (GCP).
### How to enter maintenance mode
1. Connect to the VM (with SSH client or serial console).
2. Back up /boot/grub/grub.conf
3. Run: cp /boot/grub/grub.conf /boot/grub/grub.conf.backup
4. Copy grub.conf from this directory and place it in /boot/grub/
5. Reboot the VM.
6. After it boots, click on Serial Console to enter maintenance mode.

### How to return to normal mode
1. Connect to the serial console.
2. Rename the backup file as grub.conf
3. Run: mv /boot/grub/grub.conf.backup /boot/grub/grub.conf
4. Reboot the VM.
5. After the boot, your VM is in normal mode.