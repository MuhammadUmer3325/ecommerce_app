import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laptop_harbor/core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App Logo and Name Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.laptop_mac,
                      size: 60,
                      color: Colors.blue[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Laptop Harbor",
                    style: GoogleFonts.orbitron(
                      color: AppColors.dark,
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // About Section
            _buildSectionCard(
              title: 'About',
              content:
                  'Laptop Harbor is your one-stop destination for all things laptop. '
                  'Whether you\'re looking for a new device, need repairs, or want '
                  'to sell your old laptop, we\'ve got you covered.',
              icon: Icons.info_outline,
            ),

            // Features Section
            _buildSectionCard(
              title: 'Key Features',
              content: '',
              icon: Icons.star_outline,
              child: Column(
                children: [
                  _buildFeatureItem('Browse and compare laptops'),
                  _buildFeatureItem('Read and write reviews'),
                  _buildFeatureItem('Find repair services'),
                  _buildFeatureItem('Buy and sell used laptops'),
                ],
              ),
            ),

            // Contact Section
            _buildSectionCard(
              title: 'Contact Us',
              content: '',
              icon: Icons.contact_mail_outlined,
              child: Column(
                children: [
                  _buildContactItem(
                    Icons.email_outlined,
                    'Email',
                    'support@laptopharbor.com',
                    'mailto:support@laptopharbor.com',
                  ),
                  _buildContactItem(
                    Icons.phone_outlined,
                    'Phone',
                    '+1 (123) 456-7890',
                    'tel:+1234567890',
                  ),
                  _buildContactItem(
                    Icons.language_outlined,
                    'Website',
                    'www.laptopharbor.com',
                    'https://www.laptopharbor.com',
                  ),
                ],
              ),
            ),

            // Social Media Section
            _buildSectionCard(
              title: 'Follow Us',
              content: '',
              icon: Icons.share_outlined,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSocialButton(
                    Icons.facebook,
                    'Facebook',
                    'https://www.facebook.com/laptopharbor',
                  ),
                  _buildSocialButton(
                    Icons.camera_alt,
                    'Instagram',
                    'https://www.instagram.com/laptopharbor',
                  ),
                  _buildSocialButton(
                    Icons.message,
                    'Twitter',
                    'https://www.twitter.com/laptopharbor',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: const Text(
                '© 2023 Laptop Harbor. All rights reserved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
    Widget? child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue[600], size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 15),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
          if (child != null) ...[const SizedBox(height: 15), child],
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[500], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    String url,
  ) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue[600], size: 20),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.launch, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.blue[600], size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
