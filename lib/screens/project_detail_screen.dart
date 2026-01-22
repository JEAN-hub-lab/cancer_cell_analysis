import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import 'upload_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;
  final String projectName;
  final String cellLine; // รับค่า
  final String drugName; // รับค่า

  const ProjectDetailScreen({
    super.key, 
    required this.projectId, 
    required this.projectName,
    required this.cellLine,
    required this.drugName,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: Column(
                  children: [
                    Text(projectName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text("$cellLine : $drugName", style: const TextStyle(color: Colors.cyanAccent, fontSize: 12)),
                  ],
                ),
                centerTitle: true,
                backgroundColor: const Color(0xFF0F2027),
                pinned: true,
                floating: true,
                snap: true,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.cyanAccent),
                bottom: const TabBar(
                  indicatorColor: Colors.cyanAccent,
                  labelColor: Colors.cyanAccent,
                  unselectedLabelColor: Colors.white54,
                  indicatorWeight: 3,
                  tabs: [Tab(icon: Icon(Icons.show_chart), text: "Analytics"), Tab(icon: Icon(Icons.table_chart), text: "Data Logs")],
                ),
              ),
            ];
          },
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)]),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseService().getProjectData(projectId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
                var docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text("No Experiments Yet", style: TextStyle(color: Colors.white54)));
                
                return TabBarView(children: [_buildGraphsView(docs), _buildDataLogsView(context, docs)]);
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.cyanAccent,
          foregroundColor: Colors.black87,
          icon: const Icon(Icons.add_a_photo),
          label: const Text("Add Data", style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            // ส่งค่า Fixed ไปหน้า Upload
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => UploadScreen(projectId: projectId, cellLine: cellLine, drugName: drugName)
            ));
          },
        ),
      ),
    );
  }

  Widget _buildGraphsView(List<QueryDocumentSnapshot> docs) {
    List<FlSpot> countSpots = [];
    List<FlSpot> sizeSpots = [];
    for (var doc in docs) {
      double conc = (doc['concentration'] as num).toDouble();
      countSpots.add(FlSpot(conc, (doc['colonyCount'] as num).toDouble()));
      sizeSpots.add(FlSpot(conc, (doc['avgSize'] as num).toDouble()));
    }
    countSpots.sort((a, b) => a.x.compareTo(b.x));
    sizeSpots.sort((a, b) => a.x.compareTo(b.x));

    return ListView(padding: const EdgeInsets.all(20), children: [_chartCard("Colony Count vs Concentration", countSpots, Colors.cyanAccent), const SizedBox(height: 20), _chartCard("Avg Size vs Concentration", sizeSpots, Colors.orangeAccent), const SizedBox(height: 80)]);
  }

  Widget _chartCard(String title, List<FlSpot> spots, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 350,
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          Expanded(child: LineChart(LineChartData(gridData: FlGridData(show: true, drawVerticalLine: false), titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text("${v.toInt()}", style: const TextStyle(color: Colors.white54, fontSize: 10)))), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) => Text("${v.toInt()}", style: const TextStyle(color: Colors.white54, fontSize: 10)))), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))), borderData: FlBorderData(show: false), lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: color, barWidth: 3, dotData: FlDotData(show: true), belowBarData: BarAreaData(show: true, color: color.withOpacity(0.15)))]))),
        ],
      ),
    );
  }

  Widget _buildDataLogsView(BuildContext context, List<QueryDocumentSnapshot> docs) {
    docs.sort((a, b) => (a['concentration'] as num).compareTo(b['concentration'] as num));
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: docs.length + 1,
      itemBuilder: (context, index) {
        if (index == docs.length) return const SizedBox(height: 80);
        var data = docs[index];
        String dateStr = data['timestamp'] != null ? DateFormat('dd/MM HH:mm').format((data['timestamp'] as Timestamp).toDate()) : '-';
        return Card(
          color: Colors.white.withOpacity(0.05),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.white10, child: Text("${data['concentration']}", style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12))),
            title: Text("${data['colonyCount']} Colonies", style: const TextStyle(color: Colors.white)),
            subtitle: Text("Size: ${(data['avgSize'] as num).toStringAsFixed(1)} | $dateStr", style: const TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                 IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _confirmDeleteData(context, data.id)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteData(BuildContext context, String docId) {
    showDialog(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF203A43), title: const Text("Delete Data?", style: TextStyle(color: Colors.white)), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () async { final nav = Navigator.of(ctx); await DatabaseService().deleteExperimentData(projectId, docId); nav.pop(); }, child: const Text("Delete"))]));
  }
}