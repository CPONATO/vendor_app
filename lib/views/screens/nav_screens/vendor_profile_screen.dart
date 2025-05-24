import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor_store_ap/controllers/vendor_auth_controller.dart';
import 'package:vendor_store_ap/provider/vendor_provider.dart';
import 'package:vendor_store_ap/services/manage_http_response.dart';
import 'package:vendor_store_ap/models/vendor.dart';

class VendorProfileScreen extends ConsumerStatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  ConsumerState<VendorProfileScreen> createState() =>
      _VendorProfileScreenState();
}

class _VendorProfileScreenState extends ConsumerState<VendorProfileScreen> {
  //define avaluenotifier to manathe image state
  final ValueNotifier<File?> imageNotifier = ValueNotifier<File?>(null);
  final ImagePicker picker = ImagePicker();
  //function to pick  image
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imageNotifier.value = File(pickedFile.path);
    } else {
      showSnackBar(context, "No image picked");
    }
  }

  final VendorAuthController _authController = VendorAuthController();
  bool _hasInitialized = false;

  void showEditProfileDialong(BuildContext context) {
    final user = ref.read(vendorProvider);
    final TextEditingController storeDescriptionController =
        TextEditingController();

    storeDescriptionController.text = user?.storeDescription ?? "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Edit Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //display and update image
              ValueListenableBuilder(
                valueListenable: imageNotifier,
                builder: (context, value, child) {
                  return InkWell(
                    onTap: () {
                      pickImage();
                    },
                    child:
                        value != null
                            ? CircleAvatar(
                              radius: 50,
                              backgroundImage: FileImage(value),
                            )
                            : CircleAvatar(
                              radius: 20,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Icon(CupertinoIcons.photo, size: 24),
                              ),
                            ),
                  );
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: storeDescriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Store Description",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                await _authController.updateVendorData(
                  context: context,
                  id: ref.read(vendorProvider)!.id,
                  storeImage: imageNotifier.value,
                  storeDescription: storeDescriptionController.text,
                  ref: ref,
                );
                Navigator.of(context).pop;
              },
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeVendorData();
  }

  void _initializeVendorData() {
    final vendor = ref.read(vendorProvider);
    if (vendor != null && !_hasInitialized) {
      _hasInitialized = true;
      // Fetch vendor statistics khi màn hình được load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // TODO: Fetch các thống kê vendor
        // ref.read(vendorStatisticsProvider.notifier).fetchStatistics(vendor.id, context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendor = ref.watch(vendorProvider);

    if (vendor == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green[800],
        title: const Text(
          'Vendor Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              // Navigate to vendor settings if needed
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Refresh vendor statistics
              // TODO: Implement refresh
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            height: 4.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[300]!, Colors.green[500]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context, vendor),
            const SizedBox(height: 16),

            // Vendor Statistics Section
            _buildSectionTitle('Store Information'),
            _buildStoreInfoCard(context, vendor),
            const SizedBox(height: 16),

            _buildSectionTitle('Business Address'),
            _buildAddressCard(context, vendor, ref),
            const SizedBox(height: 16),

            _buildSectionTitle('Security'),
            _buildSecurityCard(context),
            const SizedBox(height: 16),

            _buildSectionTitle('Support'),
            _buildVendorSupportCard(context),
            const SizedBox(height: 24),

            _buildSignOutButton(context),
            const SizedBox(height: 12),
            _buildDeleteAccountButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Vendor vendor) {
    final user = ref.read(vendorProvider);

    // ===== DEBUG UI =====
    print("=== UI DEBUG ===");
    print("Vendor storeImage: '${user?.storeImage}'");
    print("Is empty: ${user?.storeImage?.isEmpty ?? true}");
    print("===============");
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Align(
                alignment: Alignment(0, -0.53),
                child: CircleAvatar(
                  radius: 65,
                  backgroundImage:
                      user!.storeImage != ""
                          ? NetworkImage(user.storeImage!)
                          : NetworkImage('https://picsum.photos/200'),
                ),
              ),

              // Camera icon for editing
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => showEditProfileDialong(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      CupertinoIcons.camera_fill,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  vendor.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    'Vendor',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStoreInfoCard(BuildContext context, dynamic vendor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(
            title: 'Store Name',
            subtitle: vendor.fullName,
            icon: CupertinoIcons.building_2_fill,
            iconColor: Colors.green[700]!,
            onTap: () {
              // Navigate to edit store name
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            title: 'Email',
            subtitle: vendor.email,
            icon: CupertinoIcons.mail_solid,
            iconColor: Colors.blue[700]!,
            onTap: () {
              // Navigate to email settings
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            title: 'Store Status',
            subtitle: 'Active',
            icon: CupertinoIcons.checkmark_seal_fill,
            iconColor: Colors.green[700]!,
            onTap: () {
              // Toggle store status
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    dynamic vendor,
    WidgetRef ref,
  ) {
    final hasAddress =
        vendor.state.isNotEmpty ||
        vendor.city.isNotEmpty ||
        vendor.locality.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate to vendor address screen
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => const VendorAddressScreen(),
            //   ),
            // );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.location_solid,
                    color: Colors.green[700],
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasAddress
                            ? 'Business Address'
                            : 'Add Business Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: hasAddress ? Colors.black : Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (hasAddress)
                        Text(
                          '${vendor.locality}, ${vendor.city}, ${vendor.state}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        )
                      else
                        Text(
                          'Tap to add your business address',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(
            title: 'Change Password',
            subtitle: 'Update your account password',
            icon: CupertinoIcons.lock_fill,
            iconColor: Colors.red[700]!,
            onTap: () {
              // Navigate to change password screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVendorSupportCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(
            title: 'Vendor Support',
            subtitle: 'Get help with your store',
            icon: CupertinoIcons.chat_bubble_text_fill,
            iconColor: Colors.teal[700]!,
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('Vendor Support'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildContactItem(
                            icon: Icons.email,
                            title: 'Email',
                            details: 'vendor.support@riel.com',
                          ),
                          SizedBox(height: 16),
                          _buildContactItem(
                            icon: Icons.phone,
                            title: 'Phone',
                            details: '+84 888-456-789',
                          ),
                          SizedBox(height: 16),
                          _buildContactItem(
                            icon: Icons.schedule,
                            title: 'Support Hours',
                            details: 'Monday to Friday, 8AM - 6PM',
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Close'),
                        ),
                      ],
                    ),
              );
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            title: 'Vendor Guidelines',
            subtitle: 'Rules and best practices',
            icon: CupertinoIcons.book_fill,
            iconColor: Colors.blue[700]!,
            onTap: () {
              // Navigate to vendor guidelines
            },
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String details,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[700], size: 24),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            Text(
              details,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Confirm Sign Out'),
                  content: const Text(
                    'Are you sure you want to sign out from your vendor account?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _authController.signOutUSer(context: context);
                      },
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
          );
        },
        icon: const Icon(Icons.logout),
        label: const Text(
          'Sign Out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    final vendor = ref.read(vendorProvider);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Delete Vendor Account'),
                  content: const Text(
                    'Are you sure you want to delete your vendor account? This action cannot be undone and all your store data, products, and order history will be permanently removed.',
                    style: TextStyle(color: Colors.black87),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // TODO: Implement vendor account deletion
                        _authController.deleteAccoumt(
                          context: context,
                          id: vendor!.id,
                          ref: ref,
                        );
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
          );
        },
        icon: const Icon(Icons.delete_forever),
        label: const Text(
          'Delete Vendor Account',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[800],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
