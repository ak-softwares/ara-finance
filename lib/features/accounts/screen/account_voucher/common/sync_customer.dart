import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/navigation_bar/appbar.dart';
import '../../../../../common/widgets/custom_shape/containers/rounded_container.dart';
import '../../../../../common/widgets/shimmers/shimmer_effect.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controller/customer/sync_customer_controller.dart';

class SyncCustomerScreen extends StatelessWidget {
  const SyncCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is initialized
    Get.put(SyncCustomerController());

    return Scaffold(
      appBar: AppAppBar(title: 'Sync Customers'),
      body: SingleChildScrollView(
        child: GetBuilder<SyncCustomerController>(
          builder: (controller) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSyncOptionCard(
                    context: context,
                    icon: Icons.person_add,
                    title: 'Add New Customers',
                    description: 'Add new customers from local to WooCommerce',
                    onTap: controller.startAddCustomers,
                    isActive: !controller.isSyncing,
                  ),
                  const SizedBox(height: 20),
                  _buildSyncOptionCard(
                    context: context,
                    icon: Icons.person_search,
                    title: 'Find Existing Customers',
                    description: 'Check if customers exist in WooCommerce',
                    onTap: controller.startCheckCustomers,
                    isActive: !controller.isSyncing,
                  ),
                  const SizedBox(height: 30),

                  // Enhanced progress section with status visibility
                  if (controller.isSyncing || controller.status == SyncStatus.completed)
                    _buildProgressSection(controller),

                  // Error display
                  if (controller.hasError)
                    RoundedContainer(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: AppColors.error.withOpacity(0.1),
                      child: Text(
                        controller.errorMessage,
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSyncOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GetBuilder<SyncCustomerController>(
      builder: (controller) {
        return Card(
          elevation: 4,
          color: Theme.of(context).colorScheme.surface,
          child: InkWell(
            onTap: isActive ? onTap : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(icon, size: 40, color: isActive ? AppColors.primaryColor : Colors.grey),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Theme.of(context).colorScheme.onSurface : Colors.grey,
                              ),
                            ),
                            if (title.contains('Add'))
                              IconButton(
                                icon: Icon(Icons.refresh, size: 20),
                                color: AppColors.primaryColor,
                                onPressed: isActive ? controller.getTotalCustomersCount : null,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: isActive ? Theme.of(context).colorScheme.onSurfaceVariant : Colors.grey,
                          ),
                        ),
                        if (title.contains('Add'))
                          Obx(() {
                            if (controller.isGettingCount.value) {
                              return const Padding(
                                padding: EdgeInsets.only(top: AppSizes.sm),
                                child: ShimmerEffect(height: 14, width: 150),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(top: AppSizes.sm),
                                child: Text(
                                  '${controller.newCustomersCount} new customers available',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                          }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection(SyncCustomerController controller) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with sync type and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.syncType == SyncType.add
                      ? 'Adding Customers'
                      : controller.syncType == SyncType.check
                      ? 'Checking Customers'
                      : 'Updating Customers',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  backgroundColor: _getStatusColor(controller.status),
                  label: Text(
                    controller.status.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            LinearProgressIndicator(
              value: controller.progress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
            const SizedBox(height: 8),

            // Progress text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(controller.progress * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  '${controller.processedItems} of ${controller.totalItems}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current activity details
            if (controller.currentCustomerName.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusMessage(controller.status),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.currentCustomerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Cancel button (only during active sync)
            if (controller.isSyncing)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => controller.cancelSync(),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),

            // Success message (when completed)
            if (controller.status == SyncStatus.completed)
              RoundedContainer(
                padding: const EdgeInsets.all(8),
                backgroundColor: Colors.green.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.syncType == SyncType.add
                            ? 'Successfully added ${controller.processedItems} customers'
                            : 'Successfully checked ${controller.processedItems} customers',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.checking:
        return Colors.blue;
      case SyncStatus.fetching:
        return Colors.orange;
      case SyncStatus.pushing:
        return Colors.purple;
      case SyncStatus.completed:
        return Colors.green;
      case SyncStatus.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusMessage(SyncStatus status) {
    switch (status) {
      case SyncStatus.checking:
        return 'Preparing sync...';
      case SyncStatus.fetching:
        return 'Fetching customers from WooCommerce...';
      case SyncStatus.pushing:
        return 'Processing customers:';
      case SyncStatus.completed:
        return 'Sync completed:';
      case SyncStatus.failed:
        return 'Sync failed:';
      default:
        return 'Current status:';
    }
  }
}