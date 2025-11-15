# Windows VM Setup Guide for NixOS (virt-manager)

This guide walks you through setting up a Windows VM using virt-manager on NixOS.

## Prerequisites

Make sure you've enabled the virtualization module in your flake configuration.

## Step 1: Get Windows ISO

Download Windows ISO from Microsoft:
- **Windows 11**: ttps://www.microsoft.com/software-download/windows11
- **Windows 10**: https://www.microsoft.com/software-download/windows10

## Step 2: Launch virt-manager

```bash
virt-manager
```

Or search for "Virtual Machine Manager" in your application launcher.

## Step 3: Create New VM

1. **Click** "Create a new virtual machine" (or File → New Virtual Machine)

2. **Choose installation method**:
   - Select "Local install media (ISO image or CDROM)"
   - Click "Forward"

3. **Choose ISO**:
   - Click "Browse" → "Browse Local"
   - Select your Windows ISO
   - It should auto-detect "Microsoft Windows 11" (or 10)
   - Click "Forward"

4. **Memory and CPU**:
   - **RAM**: 4096 MB minimum, 8192 MB recommended
   - **CPUs**: 2-4 cores (depends on your system)
   - Click "Forward"

5. **Storage**:
   - Create disk: **40-60 GB** minimum for Windows
   - Click "Forward"

6. **Final step**:
   - Name your VM (e.g., "Windows 11")
   - ✅ **Check** "Customize configuration before install"
   - Click "Finish"

## Step 4: Important Configuration (Before Starting)

This is where you optimize for performance:

### For Windows 11 (Required)

1. **Overview** → Firmware: Change to **UEFI x86_64: /usr/share/OVMF/...**
2. **Add Hardware** → TPM → Type: **Emulated** → Model: **TIS** → Version: **2.0**

### For Better Performance (All Windows versions)

1. **CPUs**:
   - ✅ Check "Copy host CPU configuration"
   - Or manually select: **host-passthrough**

2. **Boot Options**:
   - ✅ Enable boot menu
   - Move "SATA CDROM" to top for first boot

3. **Display**:
   - Type: **Spice**
   - ✅ Check "Listen type: None"
   - ✅ Check "OpenGL"
   - ✅ Select your GPU

4. **Video**:
   - Model: **Virtio** (best performance)
   - OR **QXL** (if Virtio has issues)

### Add VirtIO Drivers (Important!)

Windows needs VirtIO drivers for best performance. Add the drivers ISO:

1. Click **"Add Hardware"** → **Storage**
2. Device type: **CDROM device**
3. Select: **`/nix/store/.../virtio-win.iso`**
   - You can find it with: `ls -la /run/current-system/sw/share/virtio`
4. Click "Finish"

## Step 5: Install Windows

1. Click **"Begin Installation"**
2. Windows installer will start
3. **When asked "Where to install?"**:
   - Click "Load driver"
   - Browse the VirtIO CD → `viostor/w11/amd64` (or w10)
   - Install the storage driver
   - Now you'll see the disk, select it and continue

4. Complete Windows installation normally

## Step 6: Install VirtIO Drivers (After Windows Boots)

Once Windows is installed:
1. Open File Explorer → VirtIO CD drive
2. Run `virtio-win-gt-x64.exe` (guest tools installer)
3. This installs all drivers: network, display, balloon, etc.

## Step 7: Optimization (Optional)

After installation:
1. **Shut down VM**
2. In virt-manager, change:
   - **Disk**: Bus: **VirtIO** (was SATA) for better performance
   - **Network**: Device model: **virtio** (if not already)
3. **Start VM**

## Quick Commands

```bash
# Start VM
virsh start "Windows 11"

# List VMs
virsh list --all

# Stop VM gracefully
virsh shutdown "Windows 11"

# Force stop
virsh destroy "Windows 11"

# Delete VM (careful!)
virsh undefine "Windows 11" --remove-all-storage
```

## Tips

- **Snapshots**: Right-click VM → Snapshots → Create snapshot (save states!)
- **Shared folders**: Add Hardware → Filesystem (mount host folders in VM)
- **Clipboard sharing**: Works automatically with SPICE + guest tools
- **Full screen**: View → Full Screen (or F11)
- **Performance**: After setup, VMs are stored in `/var/lib/libvirt/images/`

- **reaching nixos localhost**: Usually in 192.168.122.1
If not verify with:  
On the NixOS host:
  virsh net-dumpxml default | grep "ip address"

  Or in Windows VM:
  ipconfig
  Look for "Default Gateway" - that's the host


## Troubleshooting

### VM won't start
- Check virtualization is enabled in BIOS (Intel VT-x or AMD-V)
- Verify you're in libvirtd group: `groups | grep libvirtd`
- Restart libvirtd: `sudo systemctl restart libvirtd`

### No network in VM
- Make sure virtio network driver is installed in Windows
- Check "default" network is active: `virsh net-list --all`
- Start it: `virsh net-start default`

### Poor performance
- Ensure you're using VirtIO drivers (not SATA/IDE)
- Enable CPU host-passthrough
- Use Spice display with OpenGL
- Allocate more RAM/CPUs if available
