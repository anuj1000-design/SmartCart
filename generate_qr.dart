import 'dart:io';

void main() {
  // Replace with your Firebase Hosting URL
  String apkUrl = 'https://your-project.firebaseapp.com/download/smartcart.apk';

  // Generate QR code image (requires qr_flutter)
  // Save as PNG or print to console
  stdout.write('QR Code for APK download: $apkUrl');
  // Use qr_flutter to generate image
}