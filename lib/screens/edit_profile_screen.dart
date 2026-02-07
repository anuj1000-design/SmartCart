import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state_provider.dart';
import '../widgets/ui_components.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String _selectedEmoji = "";

  final List<String> _avatarEmojis = [
    "👤",
    "😊",
    "😎",
    "🤓",
    "🥳",
    "😇",
    "🤩",
    "🧐",
    "👨",
    "👩",
    "👨‍💼",
    "👩‍💼",
    "👨‍🎓",
    "👩‍🎓",
    "🧑‍💻",
    "👨‍🍳",
    "🦸",
    "🦹",
    "🧙",
    "🧚",
    "🧛",
    "🧜",
    "🧝",
    "🧞",
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    _nameController = TextEditingController(text: appState.userProfile.name);
    _emailController = TextEditingController(text: appState.userProfile.email);
    _phoneController = TextEditingController(text: appState.userProfile.phone);
    _selectedEmoji = appState.userProfile.avatarEmoji;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Name cannot be empty")));
      return;
    }
    appState.updateProfile(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      avatarEmoji: _selectedEmoji,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully!")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              "Save",
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ScreenFade(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _selectedEmoji,
                          style: const TextStyle(fontSize: 50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Choose Your Avatar",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 280,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _avatarEmojis.length,
                  itemBuilder: (context, index) {
                    final emoji = _avatarEmojis[index];
                    final isSelected = emoji == _selectedEmoji;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedEmoji = emoji),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary.withValues(alpha: 0.3)
                              : AppTheme.darkCard.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.darkBorder,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Personal Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
