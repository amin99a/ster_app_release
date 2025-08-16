import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/host_request.dart';
import '../services/host_service.dart';
import '../services/auth_service.dart';
import '../widgets/floating_header.dart';
import '../widgets/host_request_details_modal.dart';
import '../widgets/host_request_card.dart';
import '../services/context_aware_service.dart';

class AdminHostApprovalScreen extends StatefulWidget {
  const AdminHostApprovalScreen({super.key});

  @override
  State<AdminHostApprovalScreen> createState() => _AdminHostApprovalScreenState();
}

class _AdminHostApprovalScreenState extends State<AdminHostApprovalScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late HostService _hostService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _hostService = context.read<HostService>();
    _authService = context.read<AuthService>();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // First check database setup
      _hostService.checkDatabaseSetup();
      // Then load host requests
      _loadHostRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHostRequests() async {
    await _hostService.loadHostRequests();
  }

  Future<void> _approveHostRequest(HostRequest request) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      _showSnackBar('Authentication error', Colors.red);
      return;
    }

    // Confirm approval
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Host Request'),
        content: Text('Approve ${request.userName} as host?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Approve')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final success = await _hostService.approveHostRequest(
        request.id,
        currentUser.id,
        currentUser.name,
      );

      if (success) {
        // Track host_request_decision: approved
        try {
          ContextAwareService().trackEvent(
            eventName: 'host_request_decision',
            service: 'HostService',
            operation: 'approve_host_request',
            metadata: {
              'request_id': request.id,
              'decision': 'approved',
              'user_id': request.userId,
              'admin_id': currentUser.id,
            },
          );
        } catch (_) {}
        _showSnackBar('Host request approved successfully', Colors.green);
      } else {
        _showSnackBar('Failed to approve host request', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Failed to approve host request: $e', Colors.red);
    }
  }

  Future<void> _rejectHostRequest(HostRequest request, String reason) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      _showSnackBar('Authentication error', Colors.red);
      return;
    }

    try {
      final success = await _hostService.rejectHostRequest(
        request.id,
        currentUser.id,
        currentUser.name,
        reason,
      );

      if (success) {
        // Track host_request_decision: rejected
        try {
          ContextAwareService().trackEvent(
            eventName: 'host_request_decision',
            service: 'HostService',
            operation: 'reject_host_request',
            metadata: {
              'request_id': request.id,
              'decision': 'rejected',
              'user_id': request.userId,
              'admin_id': currentUser.id,
              'reason': reason,
            },
          );
        } catch (_) {}
        _showSnackBar('Host request rejected', Colors.orange);
      } else {
        _showSnackBar('Failed to reject host request', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Failed to reject host request: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showHostRequestDetails(HostRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HostRequestDetailsModal(
        request: request,
        onApprove: () => _approveHostRequest(request),
        onReject: (reason) => _rejectHostRequest(request, reason),
      ),
    );
  }

  void _showRejectDialog(HostRequest request) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reject Host Request',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to reject ${request.userName}\'s host application?',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectHostRequest(request, reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Reject',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Status bar spacing
          SizedBox(height: MediaQuery.of(context).padding.top),
          // App-matching header
          Container(
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF353935),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Host Request Approval',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        'Review and manage host applications',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    _hostService.loadHostRequests();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.bug_report, color: Colors.white),
                  onPressed: () async {
                    final success = await _hostService.testDatabaseConnection();
                    if (success) {
                      _showSnackBar('Database connection test: SUCCESS', Colors.green);
                    } else {
                      _showSnackBar('Database connection test: FAILED', Colors.red);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.table_chart, color: Colors.white),
                  onPressed: () async {
                    await _hostService.debugTableStructure();
                    _showSnackBar('Check console for table structure', Colors.blue);
                  },
                ),
              ],
            ),
          ),
          // TabBar with icons
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue,
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pending, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Pending',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Approved',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cancel, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Rejected',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // PHASE 5: Test loading/error states
                Consumer<HostService>(
                  builder: (context, hostService, child) {
                    if (hostService.isLoading) {
                      return Container(
                        color: Colors.blue[100],
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('PHASE 5: Loading State'),
                            ],
                          ),
                        ),
                      );
                    }

                    if (hostService.error != null) {
                      return Container(
                        color: Colors.red[100],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'PHASE 5: Error State\n${hostService.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                                         // Load real host requests
                     final requests = hostService.pendingRequests;
                     
                     if (requests.isEmpty) {
                       return Container(
                         color: Colors.grey[50],
                         child: const Center(
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(
                                 Icons.inbox_outlined,
                                 size: 64,
                                 color: Colors.grey,
                               ),
                               SizedBox(height: 16),
                               Text(
                                 'No pending host requests',
                                 style: TextStyle(
                                   fontSize: 16,
                                   color: Colors.grey,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       );
                     }

                     return RefreshIndicator(
                       onRefresh: () async {
                         await hostService.loadHostRequests();
                       },
                       child: ListView.builder(
                         padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                         itemCount: requests.length,
                         itemBuilder: (context, index) {
                           final request = requests[index];
                           final isLastItem = index == requests.length - 1;
                           return Padding(
                             padding: EdgeInsets.only(
                               bottom: isLastItem ? 24 : 0
                             ),
                             child: HostRequestCard(
                               request: request,
                               status: request.status.name,
                               onTap: () {
                                 _showHostRequestDetails(request);
                               },
                               onApprove: () {
                                 _approveHostRequest(request);
                               },
                               onReject: () {
                                 _showRejectDialog(request);
                               },
                             ),
                           );
                         },
                       ),
                     );
                  },
                ),
                                 // Approved tab
                 Consumer<HostService>(
                   builder: (context, hostService, child) {
                     final requests = hostService.approvedRequests;
                     
                     if (requests.isEmpty) {
                       return Container(
                         color: Colors.grey[50],
                         child: const Center(
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(
                                 Icons.check_circle_outline,
                                 size: 64,
                                 color: Colors.grey,
                               ),
                               SizedBox(height: 16),
                               Text(
                                 'No approved host requests',
                                 style: TextStyle(
                                   fontSize: 16,
                                   color: Colors.grey,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       );
                     }

                     return RefreshIndicator(
                       onRefresh: () async {
                         await hostService.loadHostRequests();
                       },
                       child: ListView.builder(
                         padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                         itemCount: requests.length,
                         itemBuilder: (context, index) {
                           final request = requests[index];
                           final isLastItem = index == requests.length - 1;
                           return Padding(
                             padding: EdgeInsets.only(
                               bottom: isLastItem ? 24 : 0
                             ),
                             child: HostRequestCard(
                               request: request,
                               status: request.status.name,
                               onTap: () {
                                 _showHostRequestDetails(request);
                               },
                             ),
                           );
                         },
                       ),
                     );
                   },
                 ),
                 // Rejected tab
                 Consumer<HostService>(
                   builder: (context, hostService, child) {
                     final requests = hostService.rejectedRequests;
                     
                     if (requests.isEmpty) {
                       return Container(
                         color: Colors.grey[50],
                         child: const Center(
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(
                                 Icons.cancel_outlined,
                                 size: 64,
                                 color: Colors.grey,
                               ),
                               SizedBox(height: 16),
                               Text(
                                 'No rejected host requests',
                                 style: TextStyle(
                                   fontSize: 16,
                                   color: Colors.grey,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       );
                     }

                     return RefreshIndicator(
                       onRefresh: () async {
                         await hostService.loadHostRequests();
                       },
                       child: ListView.builder(
                         padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                         itemCount: requests.length,
                         itemBuilder: (context, index) {
                           final request = requests[index];
                           final isLastItem = index == requests.length - 1;
                           return Padding(
                             padding: EdgeInsets.only(
                               bottom: isLastItem ? 24 : 0
                             ),
                             child: HostRequestCard(
                               request: request,
                               status: request.status.name,
                               onTap: () {
                                 _showHostRequestDetails(request);
                               },
                             ),
                           );
                         },
                       ),
                     );
                   },
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostRequestList(List<HostRequest> requests, String status) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'pending'
                  ? Icons.pending_actions
                  : status == 'approved'
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${status} host requests',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status == 'pending'
                  ? 'New host applications will appear here'
                  : 'All ${status} host requests will be listed here',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHostRequests,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          final isLastItem = index == requests.length - 1;
          return Padding(
            padding: EdgeInsets.only(
              bottom: isLastItem ? 24 : 0
            ),
            child: HostRequestCard(
              request: request,
              status: status,
              onTap: () => _showHostRequestDetails(request),
              onApprove: status == 'pending' ? () => _approveHostRequest(request) : null,
              onReject: status == 'pending' ? () => _showRejectDialog(request) : null,
            ),
          );
        },
      ),
    );
  }
}
