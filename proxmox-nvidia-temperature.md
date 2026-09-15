# Ampere NVIDIA temperature on Proxmox

The `ampere` guest emits one numeric GPU temperature per line through a
virtio-serial port. VM `100` needs this QEMU channel:

```text
args: -chardev socket,id=nvidia_temp,path=/run/qemu-server/100-nvidia-temperature.sock,server=on,wait=off -device virtio-serial-pci,id=nvidia_temp_controller -device virtserialport,bus=nvidia_temp_controller.0,chardev=nvidia_temp,name=org.neer.nvidia.temperature
```

If VM `100` has no existing `args` setting, configure it with:

```bash
qm set 100 --args '-chardev socket,id=nvidia_temp,path=/run/qemu-server/100-nvidia-temperature.sock,server=on,wait=off -device virtio-serial-pci,id=nvidia_temp_controller -device virtserialport,bus=nvidia_temp_controller.0,chardev=nvidia_temp,name=org.neer.nvidia.temperature'
```

Install the host reader:

```bash
apt install socat
install -m 0644 proxmox-nvidia-temperature.service /etc/systemd/system/nvidia-temperature.service
systemctl daemon-reload
systemctl enable --now nvidia-temperature.service
```

Restart VM `100` after adding the channel. The host reader keeps the current
temperature in `/dev/nvidia-temp` as millidegrees Celsius. If the guest
disconnects or produces no usable temperature, it writes `40000` instead.
The fan controller can read that file directly.
