init:
	./init.sh
run:
	qemu-system-x86_64 -m 1024 -nographic -kernel ./linux/arch/x86_64/boot/bzImage  -initrd ./initrd.img -append "console=ttyS0 root=/dev/mem0 rdinit=/sbin/init"

kill:
	killall qemu-system-x86_64
