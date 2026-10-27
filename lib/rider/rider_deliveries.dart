import 'package:flutter/material.dart';

import 'models/rider_delivery_model.dart';
import 'widgets/rider_map.dart';
import 'widgets/rider_ui.dart';

class RiderDeliveries extends StatelessWidget {
  final List<RiderDelivery> orders;
  final ValueChanged<RiderDelivery> onAdvanceDelivery;
  final VoidCallback onOpenWorkflow;
  final VoidCallback onOpenHistory;
  final ValueChanged<RiderDelivery> onMarkSuccessful;
  final void Function(RiderDelivery delivery, String reason) onMarkFailed;
  final ValueChanged<RiderDelivery> onReschedule;
  final ValueChanged<RiderDelivery> onReturnToSorting;
  final ValueChanged<RiderDelivery> onBuyerConfirmed;

  RiderDeliveries({
    super.key,
    required this.orders,
    required this.onAdvanceDelivery,
    required this.onOpenWorkflow,
    required this.onOpenHistory,
    required this.onMarkSuccessful,
    required this.onMarkFailed,
    required this.onReschedule,
    required this.onReturnToSorting,
    required this.onBuyerConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    final active = orders.where((order) => order.isActiveDelivery).toList();
    return Scaffold(
      backgroundColor: RiderColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 74,
        titleSpacing: 16,
        title: RiderHeaderTitle(title: 'Active Route', subtitle: 'Sorting Center → Customer'),
        actions: [IconButton(tooltip: 'Delivery history', onPressed: onOpenHistory, icon: Icon(Icons.history_rounded)), SizedBox(width: 8)],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(14, 14, 14, 26),
        children: [
          _routeBanner(),
          SizedBox(height: 14),
          if (active.isEmpty)
            RiderEmptyState(icon: Icons.route_outlined, title: 'No last-mile delivery yet', message: 'A parcel must first reach the sorting center before a customer delivery assignment becomes active.')
          else
            ...active.map((order) => Padding(padding: EdgeInsets.only(bottom: 14), child: _deliveryFlow(context, order))),
        ],
      ),
    );
  }

  Widget _routeBanner() {
    return Container(
      padding: EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [RiderColors.blueSoft, RiderColors.surfaceElevated],
        ),
        border: Border.all(color: RiderColors.blue.withValues(alpha: .30)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(radius: 22, backgroundColor: RiderColors.blue, child: Icon(Icons.route_rounded, color: Colors.white)),
        SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Last-mile delivery', style: TextStyle(color: RiderColors.text, fontSize: 16, fontWeight: FontWeight.w900)),
          SizedBox(height: 4),
          Text('Pick up the sorted parcel, mark it out for delivery, then record a successful or failed customer handoff.', style: TextStyle(color: RiderColors.muted, fontSize: 11, height: 1.4)),
        ])),
      ]),
    );
  }

  Widget _deliveryFlow(BuildContext context, RiderDelivery order) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (order.showDeliveryMap) ...[RiderMap(delivery: order, height: 275), SizedBox(height: 10)],
      RiderSurface(
        padding: EdgeInsets.zero,
        shadow: true,
        child: Column(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 13),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(order.orderNumber, style: TextStyle(color: RiderColors.text, fontSize: 16, fontWeight: FontWeight.w900)),
                  SizedBox(height: 3),
                  Text('${order.buyerName} • ${order.packageCode}', style: TextStyle(color: RiderColors.muted, fontSize: 10.5)),
                ])),
                RiderStatusPill(label: order.statusLabel, color: riderStatusColor(order.status), background: riderStatusSoftColor(order.status)),
              ]),
              SizedBox(height: 15),
              _deliveryStepper(order),
              SizedBox(height: 15),
              _addressCard(order),
              SizedBox(height: 12),
              Text(order.actionMessage, style: TextStyle(color: RiderColors.muted, fontSize: 11, height: 1.45)),
              if (order.failureReason != null && order.status == 'delivery_failed') ...[
                SizedBox(height: 10),
                Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: RiderColors.redSoft, borderRadius: BorderRadius.circular(13)), child: Row(children: [
                  Icon(Icons.report_gmailerrorred_rounded, color: RiderColors.red),
                  SizedBox(width: 8),
                  Expanded(child: Text('Reason: ${order.failureReason}', style: TextStyle(color: RiderColors.red, fontSize: 11, fontWeight: FontWeight.w700))),
                ])),
              ],
            ]),
          ),
          _actionArea(context, order),
        ]),
      ),
    ]);
  }

  Widget _deliveryStepper(RiderDelivery order) {
    const labels = ['Assigned','Picked','Out','Customer','Done'];
    int current;
    switch (order.status) {
      case 'delivery_assigned': current = 0; break;
      case 'delivery_accepted':
      case 'parcel_released': current = 1; break;
      case 'out_for_delivery': current = 2; break;
      case 'arrived_buyer':
      case 'delivery_failed': current = 3; break;
      default: current = 4;
    }
    return Row(children: [
      for (var i = 0; i < labels.length; i++) ...[
        Expanded(child: Column(children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: i < current ? RiderColors.green : (i == current ? RiderColors.blue : RiderColors.border), shape: BoxShape.circle), child: Icon(i < current ? Icons.check_rounded : Icons.circle, color: i <= current ? Colors.white : RiderColors.muted, size: i < current ? 16 : 7)),
          SizedBox(height: 5),
          Text(labels[i], textAlign: TextAlign.center, style: TextStyle(color: i == current ? RiderColors.blue : RiderColors.muted, fontSize: 8.5, fontWeight: i == current ? FontWeight.w900 : FontWeight.w600)),
        ])),
        if (i != labels.length - 1) Container(width: 10, height: 2, margin: EdgeInsets.only(bottom: 18), color: i < current ? RiderColors.green : RiderColors.border),
      ],
    ]);
  }

  Widget _addressCard(RiderDelivery order) {
    return Container(
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(color: RiderColors.surfaceSoft, borderRadius: BorderRadius.circular(15), border: Border.all(color: RiderColors.border)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(radius: 20, backgroundColor: RiderColors.greenSoft, child: Icon(Icons.home_outlined, color: RiderColors.green)),
        SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('DELIVERY ADDRESS', style: TextStyle(color: RiderColors.green, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .6)),
          SizedBox(height: 3),
          Text(order.buyerName, style: TextStyle(color: RiderColors.text, fontSize: 12.5, fontWeight: FontWeight.w800)),
          SizedBox(height: 2),
          Text(order.buyerAddress, style: TextStyle(color: RiderColors.muted, fontSize: 10.5, height: 1.35)),
        ])),
      ]),
    );
  }

  Widget _actionArea(BuildContext context, RiderDelivery order) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(15, 12, 15, 15),
      decoration: BoxDecoration(color: RiderColors.surfaceSoft, borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)), border: Border(top: BorderSide(color: RiderColors.border))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (order.status == 'arrived_buyer') ...[
          Row(children: [
            Expanded(child: ElevatedButton.icon(onPressed: () => onMarkSuccessful(order), style: ElevatedButton.styleFrom(backgroundColor: RiderColors.green, foregroundColor: Colors.white, minimumSize: Size.fromHeight(47), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), icon: Icon(Icons.check_circle_outline, size: 18), label: Text('Successful', style: TextStyle(fontWeight: FontWeight.w800)))),
            SizedBox(width: 9),
            Expanded(child: OutlinedButton.icon(onPressed: () => _showFailureSheet(context, order), style: OutlinedButton.styleFrom(foregroundColor: RiderColors.red, minimumSize: Size.fromHeight(47), side: BorderSide(color: RiderColors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), icon: Icon(Icons.close_rounded, size: 18), label: Text('Failed', style: TextStyle(fontWeight: FontWeight.w800)))),
          ]),
        ] else if (order.status == 'delivery_failed') ...[
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: () => onReschedule(order), style: ElevatedButton.styleFrom(backgroundColor: RiderColors.blue, foregroundColor: Colors.white, minimumSize: Size.fromHeight(46), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text('Reschedule', style: TextStyle(fontWeight: FontWeight.w800)))),
            SizedBox(width: 9),
            Expanded(child: OutlinedButton(onPressed: () => onReturnToSorting(order), style: OutlinedButton.styleFrom(minimumSize: Size.fromHeight(46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text('Return Parcel', style: TextStyle(fontWeight: FontWeight.w800)))),
          ]),
        ] else if (order.status == 'delivered') ...[
          Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: RiderColors.greenSoft, borderRadius: BorderRadius.circular(13)), child: Row(children: [
            Icon(Icons.hourglass_top_rounded, color: RiderColors.green),
            SizedBox(width: 8),
            Expanded(child: Text('Delivered. Waiting for the buyer to confirm receipt.', style: TextStyle(color: RiderColors.green, fontSize: 11, fontWeight: FontWeight.w700))),
          ])),
          SizedBox(height: 9),
          OutlinedButton(onPressed: () => onBuyerConfirmed(order), child: Text('Demo: Buyer Confirmed Receipt', style: TextStyle(fontWeight: FontWeight.w800))),
        ] else if (order.nextStatus != null) ...[
          ElevatedButton(onPressed: () => onAdvanceDelivery(order), style: ElevatedButton.styleFrom(backgroundColor: RiderColors.blue, foregroundColor: Colors.white, minimumSize: Size.fromHeight(47), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text(order.actionLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
        ],
        SizedBox(height: 5),
        TextButton(onPressed: onOpenWorkflow, child: Text('Back to dashboard')),
      ]),
    );
  }

  void _showFailureSheet(BuildContext context, RiderDelivery order) {
    const reasons = ['Customer not available','Customer refused parcel','Wrong / unreachable address','Unable to contact customer','Parcel issue or damage','Other delivery issue'];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        String selected = reasons.first;
        return StatefulBuilder(builder: (context, setModalState) {
          return SafeArea(
            child: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.fromLTRB(18, 12, 18, 18),
              decoration: BoxDecoration(color: RiderColors.surface, borderRadius: BorderRadius.circular(24)),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: RiderColors.border, borderRadius: BorderRadius.circular(99)))),
                SizedBox(height: 17),
                Text('Why did delivery fail?', style: TextStyle(color: RiderColors.text, fontSize: 19, fontWeight: FontWeight.w900)),
                SizedBox(height: 5),
                Text('Choose the closest reason. This will be sent to Logistics when the API is connected.', style: TextStyle(color: RiderColors.muted, fontSize: 11, height: 1.4)),
                SizedBox(height: 12),
                for (final reason in reasons)
                  RadioListTile<String>(
                    value: reason,
                    groupValue: selected,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(reason, style: TextStyle(fontSize: 12)),
                    onChanged: (value) { if (value != null) setModalState(() => selected = value); },
                  ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () { Navigator.pop(sheetContext); onMarkFailed(order, selected); },
                  style: ElevatedButton.styleFrom(backgroundColor: RiderColors.red, foregroundColor: Colors.white, minimumSize: Size.fromHeight(48), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Text('Record Failed Delivery', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
          );
        });
      },
    );
  }
}
