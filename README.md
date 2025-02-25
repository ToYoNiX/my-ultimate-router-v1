The provided firmwares include the listed packages, as detailed in the 'Installed Packages' text file.

# **The Ultimate Router Setup**

## **My Goals**

When I set out to build my ideal router, I had a few key requirements:

- A low-power device capable of remote access to services like **Ollama** and **Nextcloud** from anywhere.

Initially, I considered using a low-power PC with additional NICs, running a **Proxmox** hypervisor to virtualize the firewall and host various containers and VMs. This approach is well-documented in [this video](https://www.youtube.com/watch?v=8QTdW0Q8U3E) on building an "ultimate" router.

However, this method presented several challenges:

### **Challenges**

1. **Hardware Availability & Cost**
    
    - In Egypt, **thin clients** and **SFF prebuilt systems** are available, but **NICs** are scarce and expensive.
2. **Virtualization Complexity**
    
    - Virtualizing router software is **not beginner-friendly** and has **security/performance risks**, as discussed in:
        - [Should You Virtualize Your pfSense Firewall?](https://www.youtube.com/watch?v=aKK4ojdkk3M)
        - [THE FORBIDDEN ROUTER](https://www.youtube.com/watch?v=r9fWuT5Io5Q)
3. **Running Ollama in a Virtualized Environment**
    
    - Running [Ollama](https://ollama.com/) alongside a virtualized firewall **may not be practical**.
    - While Ollama has **unofficial Vulkan support**, it’s still in development.
    - A dedicated **AMD APU (like the 4650G)** would be a better fit, as seen in [this video](https://www.youtube.com/watch?v=N8fWIh1V-YM).

### **Rethinking the Approach**

Since a **hypervisor-based** setup wasn’t viable, I shifted my focus to utilizing my **existing hardware** efficiently. My main PC already runs **Ollama** and other services, so I needed a way to **access these resources remotely** without keeping my system powered on 24/7.

## **The New Solution: A VPN Router**

I decided to set up a **VPN-enabled router** that allows me to:

- **Wake my PC remotely** when needed (Wake-on-LAN).
- **Reduce power consumption** by keeping the main system off when not in use.
- **Leverage my NVIDIA GPU** for full Ollama support when the system is on.

### **Avoiding Public IP-Based VPNs**

Public IPs in Egypt are expensive, so I opted for a **zero-config VPN** that:

- Works like a virtual router over **HTTPS**.
- Eliminates the need for a **public IP** or complex port forwarding.

I tested several solutions and settled on:

- **Zerotier** → For accessing my router remotely.
- **Tailscale** → For everything else (though my router’s storage limitations prevent installation).

---

## **Choosing the Router & Software**

I chose **OpenWRT** as my router OS because it’s:

✅ **Open-source**  
✅ **Actively maintained**  
✅ **Widely supported**

### **Finding a Compatible Router**

1. Check the [OpenWRT Hardware Table](https://openwrt.org/toh/start) for supported devices.
2. Use the [Firmware Selector](https://firmware-selector.openwrt.org/) for installation details.

### **My Choice: TP-Link Archer C6 V3.20**

- **Affordable** (~$50 in Egypt).
- **Strong OpenWRT community support**.

---

## **Setting Up the Router**

### **⚠️ Disclaimer**

**I am not responsible for bricked routers!** If anything goes wrong, refer to the [OpenWRT documentation](https://openwrt.org/docs/start) for recovery steps.

### **Installation Steps**

#### **1. Install OpenWRT**

- Download the latest firmware for your router from [OpenWRT’s official page](https://openwrt.org/).
- Follow the **official installation guide**.

#### **2. Install Required Packages**

- **Use `opkg` to install packages**, but be mindful of storage limits.
- Instead of manual installs, use the **Firmware Selector** to build a custom firmware image.

---

## **Installed Packages & Configuration**

### **Installed Packages**

I installed the following tools to enable VPN, ad-blocking, and Wake-on-LAN:

```sh
# VPN (Zerotier)
zerotier 

# Ad Blocking
gawk grep sed coreutils-sort adblock-fast luci-app-adblock-fast

# Wake-on-LAN
luci-app-wol etherwake
```

### **Ad Blocker Setup**

1. Open **LuCI (OpenWRT Web Interface)**.
2. Navigate to **Services → Adblock Fast**.
3. Enable the service.
4. Choose a **block list** (I selected **AdGuard CNAMETRACKER**).

### **VPN Setup (Zerotier)**

1. **Create a Zerotier account & network**.
2. Follow this [OpenWRT wiki guide](https://openwrt.org/docs/guide-user/services/vpn/zerotier) to install and configure Zerotier.
3. Adjust firewall settings to allow LuCI access via VPN:

```sh
# Allow LuCI via Zerotier
uci add firewall rule
uci set firewall.@rule[-1].name='Allow-LuCI-ZeroTier'
uci set firewall.@rule[-1].src='vpn'
uci set firewall.@rule[-1].dest_port='80'
uci set firewall.@rule[-1].proto='tcp'
uci set firewall.@rule[-1].target='ACCEPT'

uci add firewall rule
uci set firewall.@rule[-1].name='Allow-LuCI-ZeroTier-SSL'
uci set firewall.@rule[-1].src='vpn'
uci set firewall.@rule[-1].dest_port='443'
uci set firewall.@rule[-1].proto='tcp'
uci set firewall.@rule[-1].target='ACCEPT'

uci commit firewall
/etc/init.d/firewall restart
```

### **Wake-on-LAN (WOL) Configuration**

No additional setup is needed on the router, but **WOL must be enabled on your PC**.

I followed the **Arch Wiki guide**:

- [Wake-on-LAN (Arch Wiki)](https://wiki.archlinux.org/title/Wake-on-LAN)
- Since I use **GNOME with NetworkManager**, I followed [this section](https://wiki.archlinux.org/title/Wake-on-LAN#NetworkManager).
- One important note: **WOL works as long as the PC remains connected to power**. If the power supply is completely cut (e.g., unplugging or a power outage), you'll need to turn the PC on manually once before WOL becomes functional again.

---

## **Final Thoughts**

This setup provides a **low-power, remote-accessible router** that meets all my needs:

✅ **Secure and private remote access** without requiring a public IP.  
✅ **Energy efficiency**, keeping my PC off when not in use.  
✅ **Full GPU support for Ollama** when powered on.

By leveraging **OpenWRT**, **Zerotier**, and **Wake-on-LAN**, I built an ideal remote-access setup without unnecessary cost or complexity. 🚀

### **Challenges & Future Improvements**

While the setup works well, I encountered a few issues:

- **DNS Problems:** At times, the router became unresponsive due to a DNS resolver issue. Thanks to [Ahmed Saed](https://github.com/Ahmedsaed), I learned how to troubleshoot it. After testing, [Omar Asaad](https://github.com/Hero-Xero) found that **Cloudflare’s `1.0.0.1` DNS** provided the best stability.
- **WOL Limitations:** If there’s a power outage, the PC must be turned on manually before WOL works again. This isn’t an issue when I’m home, but it’s inconvenient when I’m away. A **UPS (Uninterruptible Power Supply)** would solve this, so it’s my next planned upgrade.

# Final Result
![Final Result](/home/assem/Documents/Github/my-ultimate-router-v1/final-result.mp4)

That’s it! I hope this helps someone trying to set up a similar system. 🚀
