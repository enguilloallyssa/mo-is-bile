import 'package:flutter/material.dart';

import 'models/rider_delivery_model.dart';
import 'widgets/rider_ui.dart';

class RiderRequests extends StatefulWidget {
  final RiderDelivery? activeOrder;
  final List<RiderDelivery> orders;
  final ValueChanged<RiderDelivery> onAdvanceDelivery;
  final VoidCallback onOpenWorkflow;
  final VoidCallback onOpenPickups;
  final VoidCallback onOpenDelivery;

  RiderRequests({
    super.key,
    required this.activeOrder,
    required this.orders,
    required this.onAdvanceDelivery,
    required this.onOpenWorkflow,
    required this.onOpenPickups,
    required this.onOpenDelivery,
  });

  @override
  State<RiderRequests> createState() => _RiderRequestsState();
}

class _RiderRequestsState extends State<RiderRequests> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final visible = widget.orders.where((order) {
      if (order.isComplete) return false;
      if (_filter == 'Pickup') return order.isPickupFlow;
      if (_filter == 'Delivery') return order.isDeliveryFlow;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: RiderColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 74,
        titleSpacing: 16,
        title: RiderHeaderTitle(title: 'Rider Jobs', subtitle: 'Assigned by SARI Logistics'),
        actions: [
          IconButton(tooltip: 'Pickup queue', onPressed: widget.onOpenPickups, icon: Icon(Icons.inventory_2_outlined)),
          SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: RiderColors.gold,
        onRefresh: () async => Future<void>.delayed(Duration(milliseconds: 350)),
        child: ListView(
          padding: EdgeInsets.fromLTRB(14, 14, 14, 26),
          children: [
            _dispatchBanner(),
            SizedBox(height: 14),
            _filters(),
            SizedBox(height: 14),
            if (visible.isEmpty)
              RiderEmptyState(icon: Icons.assignment_turned_in_outlined, title: 'No jobs in this filter', message: 'New logistics assignments will appear here automatically.')
            else
              ...visible.map((order) => Padding(padding: EdgeInsets.only(bottom: 11), child: _jobCard(order))),
          ],
        ),
      ),
    );
  }

  Widget _dispatchBanner() {
    return Container(
      padding: EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: RiderColors.isDark
              ? [RiderColors.goldSoft, RiderColors.surfaceElevated]
              : [RiderColors.goldSoft, RiderColors.surfaceElevated],
        ),
        border: Border.all(color: RiderColors.gold.withValues(alpha: .35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 22, backgroundColor: RiderColors.gold, child: Icon(Icons.campaign_outlined, color: Colors.white)),
          SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Dispatch Center', style: TextStyle(color: RiderColors.text, fontSize: 16, fontWeight: FontWeight.w900)),
            SizedBox(height: 4),
            Text('Review the parcel, route and fee first. Accept only the job currently assigned to you.', style: TextStyle(color: RiderColors.muted, fontSize: 11, height: 1.4)),
          ])),
        ],
      ),
    );
  }

  Widget _filters() {
    return Row(children: [
      for (final item in const ['All','Pickup','Delivery'])
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: item == 'Delivery' ? 0 : 8),
            child: ChoiceChip(
              label: SizedBox(width: double.infinity, child: Text(item, textAlign: TextAlign.center, style: TextStyle(fontSize: 11))),
              selected: _filter == item,
              onSelected: (_) => setState(() => _filter = item),
              selectedColor: RiderColors.goldSoft,
              backgroundColor: RiderColors.surface,
              side: BorderSide(color: RiderColors.border),
              labelStyle: TextStyle(color: _filter == item ? RiderColors.goldDark : RiderColors.muted, fontWeight: FontWeight.w800),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
    ]);
  }

  Widget _jobCard(RiderDelivery order) {
    final accent = riderStatusColor(order.status);
    return RiderSurface(
      padding: EdgeInsets.zero,
      shadow: order == widget.activeOrder,
      child: Column(children: [
        Padding(
          padding: EdgeInsets.fromLTRB(15, 15, 15, 12),
          child: Column(children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(order.orderNumber, style: TextStyle(color: RiderColors.text, fontSize: 15, fontWeight: FontWeight.w900)),
                SizedBox(height: 3),
                Text('${order.legLabel} • ${order.packageCode}', style: TextStyle(color: RiderColors.muted, fontSize: 10.5)),
              ])),
              RiderStatusPill(label: order.statusLabel, color: accent, background: riderStatusSoftColor(order.status)),
            ]),
            SizedBox(height: 14),
            _locationRow(
              icon: order.isDeliveryFlow ? Icons.warehouse_outlined : Icons.storefront_outlined,
              label: order.isDeliveryFlow ? 'FROM HUB' : 'FROM SELLER',
              name: order.isDeliveryFlow ? order.sortingCenterName : order.pickupName,
              address: order.isDeliveryFlow ? order.sortingCenterAddress : order.pickupAddress,
              color: order.isDeliveryFlow ? RiderColors.blue : RiderColors.gold,
            ),
            Padding(padding: EdgeInsets.only(left: 19), child: SizedBox(height: 14, child: VerticalDivider(color: RiderColors.border, thickness: 1.4))),
            _locationRow(
              icon: order.isDeliveryFlow ? Icons.home_outlined : Icons.warehouse_outlined,
              label: order.isDeliveryFlow ? 'TO CUSTOMER' : 'TO HUB',
              name: order.isDeliveryFlow ? order.buyerName : order.sortingCenterName,
              address: order.isDeliveryFlow ? order.buyerAddress : order.sortingCenterAddress,
              color: order.isDeliveryFlow ? RiderColors.green : RiderColors.blue,
            ),
          ]),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(15, 12, 15, 14),
          decoration: BoxDecoration(color: RiderColors.surfaceSoft, borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)), border: Border(top: BorderSide(color: RiderColors.border))),
          child: Row(children: [
            Expanded(child: Text('Fee ₱${order.deliveryFee.toStringAsFixed(0)}', style: TextStyle(color: RiderColors.green, fontSize: 13, fontWeight: FontWeight.w900))),
            if (order.status == 'arrived_buyer')
              FilledButton(onPressed: widget.onOpenDelivery, style: FilledButton.styleFrom(backgroundColor: RiderColors.blue), child: Text('Record result'))
            else if (order.nextStatus != null)
              FilledButton(onPressed: () => widget.onAdvanceDelivery(order), style: FilledButton.styleFrom(backgroundColor: accent), child: Text(order.actionLabel))
            else
              OutlinedButton(onPressed: widget.onOpenWorkflow, child: Text('Open workflow')),
          ]),
        ),
      ]),
    );
  }

  Widget _locationRow({required IconData icon, required String label, required String name, required String address, required Color color}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withValues(alpha: .11), shape: BoxShape.circle), child: Icon(icon, size: 19, color: color)),
      SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .6)),
        SizedBox(height: 2),
        Text(name, style: TextStyle(color: RiderColors.text, fontSize: 12, fontWeight: FontWeight.w800)),
        SizedBox(height: 2),
        Text(address, style: TextStyle(color: RiderColors.muted, fontSize: 10, height: 1.35)),
      ])),
    ]);
  }
}
