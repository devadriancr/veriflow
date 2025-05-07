import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:veriflow/models/record_model.dart';
import 'package:veriflow/services/database_helper.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  _RecordsScreenState createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  late Future<List<RecordModel>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _refreshRecords();
  }

  void _refreshRecords() {
    setState(() {
      _recordsFuture = DatabaseHelper.instance.getAllRecords();
    });
  }

  Widget _buildStatusIndicator(bool status) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color:
            status ? Colors.green.withAlpha(0x33) : Colors.red.withAlpha(0x33),
        shape: BoxShape.circle,
      ),
      child: Icon(
        status ? Icons.check : Icons.close,
        color: status ? Colors.green : Colors.red,
        size: 16,
      ),
    );
  }

  Widget _buildCompactInfoItem(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordItem(RecordModel record) {
    final formattedDate = DateFormat('dd-MM-yy - HH:mm:ss').format(
      DateTime.parse(record.creationDate).toLocal(),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusIndicator(record.status),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildCompactInfoItem(
                    Icons.local_shipping, record.containerCode),
                const SizedBox(height: 6),
                _buildCompactInfoItem(Icons.article, record.visualAidCode),
                const SizedBox(height: 6),
                _buildCompactInfoItem(Icons.local_offer, record.finalLabelCode),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay registros',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 24),
          const SizedBox(height: 16),
          const Text('Error al cargar datos'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshRecords,
            child: const Text('Reintentar'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HISTORIAL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRecords,
            tooltip: 'Actualizar',
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshRecords(),
        child: FutureBuilder<List<RecordModel>>(
          future: _recordsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorState();
            }

            final records = snapshot.data ?? [];

            if (records.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: records.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) => _buildRecordItem(records[index]),
            );
          },
        ),
      ),
    );
  }
}
