import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help / FAQ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildFAQItem(
              'How do I create an account?',
              'To create an account, click on the "Signup" button in the drawer or on the login screen. Fill in your details and follow the instructions to verify your email address.',
            ),
            _buildFAQItem(
              'How can I list my laptop for sale?',
              'After logging in, navigate to the "Sell" section and click on "List a Laptop". Fill in all the required details about your laptop, upload clear photos, and set your price. Your listing will be reviewed and then published.',
            ),
            _buildFAQItem(
              'Is my payment information secure?',
              'Yes, we use industry-standard encryption to protect your payment information. All transactions are processed through secure payment gateways, and we never store your credit card details on our servers.',
            ),
            _buildFAQItem(
              'How do I track my order?',
              'You can track your order by going to "My Orders" in your profile. There you will find the status of your order and a tracking number if it has been shipped.',
            ),
            _buildFAQItem(
              'What is your return policy?',
              'We offer a 30-day return policy for most items. The product must be in its original condition with all accessories and packaging. Please check our full return policy for more details.',
            ),
            _buildFAQItem(
              'How can I contact customer support?',
              'You can reach our customer support team through the "Contact Us" form in the app, by emailing support@laptopharbor.com, or by calling our helpline at +1 (123) 456-7890.',
            ),
            const SizedBox(height: 30),
            const Text(
              'Need More Help?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'If you couldn\'t find the answer to your question, please don\'t hesitate to contact our support team. We\'re here to help!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.headset_mic, size: 50, color: Colors.blue),
                  const SizedBox(height: 10),
                  const Text(
                    'Contact Support',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to contact form or open email client
                    },
                    child: const Text('Get in Touch'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'User Guides',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildGuideItem(
              'Getting Started Guide',
              'Learn the basics of using Laptop Harbor',
              Icons.play_circle,
            ),
            _buildGuideItem(
              'How to Buy',
              'Step-by-step guide to purchasing a laptop',
              Icons.shopping_cart,
            ),
            _buildGuideItem(
              'How to Sell',
              'Tips and tricks for selling your laptop',
              Icons.sell,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(padding: const EdgeInsets.all(16.0), child: Text(answer)),
      ],
    );
  }

  Widget _buildGuideItem(String title, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to the guide
        },
      ),
    );
  }
}
