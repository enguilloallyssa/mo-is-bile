import 'package:flutter/material.dart';

import 'models/rider_delivery_model.dart';
import 'widgets/rider_map.dart';
import 'widgets/rider_ui.dart';

class RiderPickups extends StatelessWidget {
  final List<RiderDelivery> orders;
  final ValueChanged<RiderDelivery> onAdvanceDelivery;
  final VoidCallback onOpenWorkflow;

  RiderPickups({super.key, required this.orders, required this.onAdvanceDelivery, required this.onOpenWorkflow});

  @override
  Widget build(BuildContext context) {
    final pickupOrders = orders.where((order) => order.isPickupFlow).toList();
    return Scaffold(
      backgroundColor: RiderColors.bg,
      appBar: AppBar(toolbarHeight: 70, title: RiderHeaderTitle(title: 'Pickup Flow', subtitle: 'Seller → Sorting Center')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(14, 14, 14, 26),
        children: [
          _guide(),
          SizedBox(height: 14),
          if (pickupOrders.isEmpty)
            RiderEmptyState(icon: Icons.inventory_2_outlined, title: 'No pickup-stage parcels', message: 'Accepted seller pickup assignments will appear here.')
          else
            ...pickupOrders.map((order) => Padding(padding: EdgeInsets.only(bottom: 14), child: _pickupCard(context, order))),
        ],
      ),
    );
  }

  Widget _guide() {
    return RiderSurface(
      color: RiderColors.goldSoft,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline_rounded, color: RiderColors.goldDark),
        SizedBox(width: 10),
        Expanded(child: Text('Collect the parcel from the seller, verify/scan it, then deliver it to the sorting center. The parcel is not yet a customer delivery at this stage.', style: TextStyle(color: RiderColors.goldDark, fontSize: 11, height: 1.45, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _pickupCard(BuildContext context, RiderDelivery order) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      RiderSurface(
        padding: EdgeInsets.all(16),
        shadow: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: Text(order.orderNumber, style: TextStyle(color: RiderColors.text, fontSize: 16, fontWeight: FontWeight.w900))),
            RiderStatusPill(label: order.statusLabel, color: riderStatusColor(order.status), background: riderStatusSoftColor(order.status)),
          ]),
          SizedBox(height: 5),
          Text('Parcel ${order.packageCode}', style: TextStyle(color: RiderColors.muted, fontSize: 11)),
          SizedBox(height: 16),
          _timeline(order),
          SizedBox(height: 14),
          Text(order.actionMessage, style: TextStyle(color: RiderColors.muted, fontSize: 11, height: 1.45)),
          if (order.nextStatus != null) ...[
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                if (order.status == 'parcel_collected') {
                  _confirmParcel(context, order);
                } else {
                  onAdvanceDelivery(order);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: RiderColors.goldDark, foregroundColor: Colors.white, minimumSize: Size.fromHeight(47), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              icon: Icon(order.status == 'parcel_collected' ? Icons.qr_code_scanner_rounded : Icons.arrow_forward_rounded, size: 19),
              label: Text(order.actionLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          ],
        ]),
      ),
      if (order.showDeliveryMap) ...[SizedBox(height: 10), RiderMap(delivery: order, height: 230)],
    ]);
  }

  Widget _timeline(RiderDelivery order) {
    const labels = ['Assigned','Seller','Parcel','Scan','Sorting'];
    int current;
    switch (order.status) {
      case 'pickup_assigned': current = 0; break;
      case 'pickup_accepted':
      case 'heading_seller':
      case 'arrived_seller': current = 1; break;
      case 'parcel_collected': current = 2; break;
      case 'heading_sorting': current = 3; break;
      default: current = 4;
    }
    return Row(children: [
      for (var i = 0; i < labels.length; i++) ...[
        Expanded(child: Column(children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: i < current ? RiderColors.green : (i == current ? RiderColors.gold : RiderColors.border), shape: BoxShape.circle), child: Icon(i < current ? Icons.check_rounded : Icons.circle, color: i <= current ? Colors.white : RiderColors.muted, size: i < current ? 16 : 7)),
          SizedBox(height: 5),
          Text(labels[i], textAlign: TextAlign.center, style: TextStyle(color: i == current ? RiderColors.goldDark : RiderColors.muted, fontSize: 8.5, fontWeight: i == current ? FontWeight.w900 : FontWeight.w600)),
        ])),
        if (i != labels.length - 1) Container(width: 12, height: 2, margin: EdgeInsets.only(bottom: 18), color: i < current ? RiderColors.green : RiderColors.border),
      ],
    ]);
  }

  void _confirmParcel(BuildContext context, RiderDelivery order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.fromLTRB(18, 12, 18, 18),
          decoration: BoxDecoration(color: RiderColors.surface, borderRadius: BorderRadius.circular(24)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 42, height: 4, decoration: BoxDecoration(color: RiderColors.border, borderRadius: BorderRadius.circular(99))),
            SizedBox(height: 18),
            Container(width: 66, height: 66, decoration: BoxDecoration(color: RiderColors.goldSoft, borderRadius: BorderRadius.circular(20)), child: Icon(Icons.qr_code_scanner_rounded, color: RiderColors.goldDark, size: 34)),
            SizedBox(height: 14),
            Text('Confirm parcel code', style: TextStyle(color: RiderColors.text, fontSize: 19, fontWeight: FontWeight.w900)),
            SizedBox(height: 6),
            Text('Camera scanning can be connected later. For now, verify the printed package code before continuing.', textAlign: TextAlign.center, style: TextStyle(color: RiderColors.muted, fontSize: 11, height: 1.45)),
            SizedBox(height: 14),
            Container(width: double.infinity, padding: EdgeInsets.all(14), decoration: BoxDecoration(color: RiderColors.surfaceSoft, borderRadius: BorderRadius.circular(14), border: Border.all(color: RiderColors.border)), child: Text(order.packageCode, textAlign: TextAlign.center, style: TextStyle(color: RiderColors.text, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1))),
            SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () { Navigator.pop(sheetContext); onAdvanceDelivery(order); },
              style: ElevatedButton.styleFrom(backgroundColor: RiderColors.goldDark, foregroundColor: Colors.white, minimumSize: Size.fromHeight(48), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              icon: Icon(Icons.verified_outlined),
              label: Text('Code Matches • Continue', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
      ),
    );
  }
}
