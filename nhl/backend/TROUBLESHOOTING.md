# Troubleshooting Guide

## NHL API Connection Issues

### Error: `Cannot resolve hostname "statsapi.web.nhl.com"`

This error indicates that your system cannot resolve the DNS for the NHL API endpoint. This is typically a network/DNS configuration issue.

#### Quick Fixes:

1. **Check Internet Connection**
   ```bash
   ping -c 3 8.8.8.8
   ```

2. **Test DNS Resolution**
   ```bash
   nslookup statsapi.web.nhl.com
   # Or with Google DNS:
   nslookup statsapi.web.nhl.com 8.8.8.8
   ```

3. **Try Different DNS Servers**
   
   **On macOS:**
   - System Preferences → Network → Advanced → DNS
   - Add DNS servers: `8.8.8.8` (Google) or `1.1.1.1` (Cloudflare)
   - Click OK and Apply

4. **Flush DNS Cache (macOS)**
   ```bash
   sudo dscacheutil -flushcache
   sudo killall -HUP mDNSResponder
   ```

5. **Check Firewall/Proxy Settings**
   - Ensure no firewall is blocking the connection
   - If behind a corporate proxy, configure proxy settings
   - Check VPN settings if using one

6. **Test API Endpoint Manually**
   ```bash
   curl -v "https://statsapi.web.nhl.com/api/v1/schedule?date=2024-11-23"
   ```

#### If Domain Still Doesn't Resolve:

The domain `statsapi.web.nhl.com` may have been deprecated. Check:
- [NHL Stats API Documentation](https://gitlab.com/dword4/nhlapi) for updated endpoints
- NHL developer resources for current API information

#### Network Diagnostics:

```bash
# Check if domain resolves with different DNS
dig statsapi.web.nhl.com @8.8.8.8
dig statsapi.web.nhl.com @1.1.1.1

# Test connectivity
ping statsapi.web.nhl.com

# Check routing
traceroute statsapi.web.nhl.com
```

## Android Installation Issues

### Error: `INSTALL_FAILED_USER_RESTRICTED`

This error occurs on Android devices (especially Xiaomi/Redmi) when installation via USB is restricted.

#### Solution for Redmi/Xiaomi Devices:

1. **Enable Developer Options**
   - Settings → About phone → Tap "MIUI version" 7 times

2. **Configure Developer Settings**
   - Settings → Additional settings → Developer options
   - Enable "USB debugging"
   - Enable "Install via USB"
   - Enable "USB debugging (Security settings)"

3. **Disable MIUI Optimization** (if needed)
   - In Developer options, disable "MIUI Optimization"
   - Restart device

4. **Allow Installation Permissions**
   - Settings → Apps → Manage apps → Security
   - Permissions → Enable "Install apps"

5. **Clear Security App Cache** (if still failing)
   ```bash
   adb shell pm clear com.miui.securitycenter
   adb shell pm clear com.android.systemui
   adb reboot
   ```

6. **Manual Installation Alternative**
   ```bash
   # Copy APK to device
   adb push build/app/outputs/flutter-apk/app-debug.apk /sdcard/Download/
   # Then install manually from device file manager
   ```

## Backend Issues

### Error: "Could not load the default credentials"

- Verify `GOOGLE_APPLICATION_CREDENTIALS` path in `.env` is correct
- Ensure `service-account-key.json` exists
- Check file permissions

### Error: "Permission denied" (Firestore)

- Verify service account has Firestore write permissions
- Check Firestore security rules are deployed
- Ensure Firebase project ID is correct

## Flutter App Issues

### Error: "Firebase not initialized"

- Run `flutterfire configure` in the `app/` directory
- Verify `firebase_options.dart` exists
- Check Firebase project configuration

### No Data Showing

- Ensure backend has run and populated Firestore
- Check Firestore Console for data
- Verify app is connected to correct Firebase project
- Check network connectivity in app

