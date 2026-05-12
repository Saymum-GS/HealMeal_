import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'lab_data.dart';
import 'widgets/lab_order_list.dart';

class LabOrdersScreen extends StatelessWidget {
  const LabOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: const Text('Lab Test Orders'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: <Tab>[
              Tab(text: 'Upcoming'),
              Tab(text: 'Processing'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            LabOrderList(
              items: initialLabOrders.where((item) => item.status == 'upcoming').toList(),
            ),
            LabOrderList(
              items: initialLabOrders.where((item) => item.status == 'processing').toList(),
            ),
            LabOrderList(
              items: initialLabOrders.where((item) => item.status == 'completed').toList(),
            ),
            LabOrderList(
              items: initialLabOrders.where((item) => item.status == 'cancelled').toList(),
            ),
          ],
        ),
      ),
    );
  }
}
class LabBookingsScreen extends LabOrdersScreen {
  const LabBookingsScreen({super.key});
}

class LabTestOrdersScreen extends LabOrdersScreen {
  const LabTestOrdersScreen({super.key});
}
