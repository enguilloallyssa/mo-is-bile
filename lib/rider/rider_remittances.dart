
import 'package:flutter/material.dart';

import 'widgets/rider_ui.dart';

class RiderRemittances extends StatefulWidget {
  const RiderRemittances({super.key});

  @override
  State<RiderRemittances> createState() =>
      _RiderRemittancesState();
}

class _RiderRemittancesState extends State<RiderRemittances> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RiderColors.bg,
      appBar: AppBar(
        backgroundColor: RiderColors.surface,
        foregroundColor: RiderColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'COD Cash Remittance',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
        children: [
          _hero(),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _metric(
                  'Eligible COD Cash',
                  'Not loaded',
                  Icons.payments_outlined,
                  RiderColors.goldDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metric(
                  'Cash Batches',
                  'Not loaded',
                  Icons.inventory_2_outlined,
                  RiderColors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _section(
            'Eligible COD Parcels',
            'Delivered COD parcels ready for cash turnover.',
          ),
          const SizedBox(height: 12),
          _eligibleParcels(),
          const SizedBox(height: 24),
          _section(
            'Prepare Cash Batch',
            'Select delivered parcels to prepare physical cash.',
          ),
          const SizedBox(height: 12),
          _prepareBatch(),
          const SizedBox(height: 24),
          _section(
            'Recent Cash Batches',
            'Review batches and their verified QR codes.',
          ),
          const SizedBox(height: 12),
          _recentBatches(),
          const SizedBox(height: 20),
          _notice(
            'COD remittance records, parcel selection, '
            'batch creation, and QR verification must '
            'come from Laravel. No cash transfer or '
            'remittance is performed by this screen.',
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: RiderColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white70,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'CASH COLLECTION OPERATIONS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Text(
            'COD Remittance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 9),
          Text(
            'Prepare your collected COD cash for '
            'physical handover to SARI Logistics.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          SizedBox(height: 19),
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Physical cash turnover only',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: RiderColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 13),
          Text(
            value,
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: RiderColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            color: RiderColors.muted,
            fontSize: 11,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _eligibleParcels() {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: RiderColors.muted,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'No eligible parcels loaded',
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Delivered COD parcels will appear here '
            'after connecting the Laravel Rider API.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _prepareBatch() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detail(
            'Selected Parcels',
            'None selected',
          ),
          Divider(
            height: 27,
            color: RiderColors.border,
          ),
          _detail(
            'Selected Cash to Hand Over',
            'Not available',
          ),
          const SizedBox(height: 16),
          _notice(
            'Bring the full COD cash. Do not deduct '
            'your rider earnings or fees from collected cash.',
          ),
          const SizedBox(height: 17),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.lock_outline),
              label: const Text('Prepare Cash Remittance'),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'Batch preparation will be enabled after '
            'Laravel validates the selected COD parcels.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentBatches() {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(
            Icons.qr_code_2_rounded,
            size: 43,
            color: RiderColors.blue,
          ),
          const SizedBox(height: 13),
          Text(
            'No cash batches loaded',
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Once a cash remittance batch has been '
            'created in Laravel, its status, expected '
            'cash amount, and server-issued QR '
            'can be displayed here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 11,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.qr_code_rounded),
            label: const Text('Show Remittance QR'),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: RiderColors.text,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _notice(String message) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: RiderColors.goldSoft,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 19,
            color: RiderColors.goldDark,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: RiderColors.text,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: RiderColors.surface,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: RiderColors.border),
    );
  }
}
