import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import 'upload_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;
  final String projectName;
  final String cellLine;
  final String drugName;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.cellLine,
    required this.drugName,
  });

  // ✅ แก้ไข Dialog ให้รองรับการอัปเดตข้อมูลที่แม่นยำ
  void _showEditProjectDialog(BuildContext context, String currentName, String currentDesc, String currentCell, String currentDrug) {
    final nameCtrl = TextEditingController(text: currentName);
    final descCtrl = TextEditingController(text: currentDesc);
    final cellCtrl = TextEditingController(text: currentCell);
    final drugCtrl = TextEditingController(text: currentDrug);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text("Edit Project Details", style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameCtrl, "Project Name"),
              const SizedBox(height: 10),
              _buildTextField(descCtrl, "Description"),
              const SizedBox(height: 10),
              _buildTextField(cellCtrl, "Cell Line"),
              const SizedBox(height: 10),
              _buildTextField(drugCtrl, "Drug Name"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                await DatabaseService().updateProjectDetails(
                  projectId,
                  nameCtrl.text.trim(),
                  descCtrl.text.trim(),
                  cellCtrl.text.trim(),
                  drugCtrl.text.trim()
                );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.cyanAccent),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ดึง UID ของ User ปัจจุบัน
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // ✅ แก้ไข Stream ให้ชี้ไปที่ Path ของ User (ตาม DatabaseService)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('projects')
                    .doc(projectId)
                    .snapshots(),
                builder: (context, snapshot) {
                  String dName = projectName;
                  String dDesc = "";
                  String dCell = cellLine;
                  String dDrug = drugName;

                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    dName = data['projectName'] ?? data['name'] ?? dName;
                    dDesc = data['description'] ?? "";
                    dCell = data['cellLine'] ?? dCell;
                    dDrug = data['drugName'] ?? dDrug;
                  }

                  return SliverAppBar(
                    expandedHeight: 120,
                    title: Column(
                      children: [
                        Text(dName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        if (dDesc.isNotEmpty)
                          Text(dDesc, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                        Text("$dCell : $dDrug", style: const TextStyle(color: Colors.cyanAccent, fontSize: 12)),
                      ],
                    ),
                    centerTitle: true,
                    backgroundColor: const Color(0xFF0F2027),
                    pinned: true,
                    floating: true,
                    iconTheme: const IconThemeData(color: Colors.cyanAccent),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.cyanAccent),
                        onPressed: () => _showEditProjectDialog(context, dName, dDesc, dCell, dDrug),
                      ),
                    ],
                    bottom: const TabBar(
                      indicatorColor: Colors.cyanAccent,
                      labelColor: Colors.cyanAccent,
                      unselectedLabelColor: Colors.white54,
                      tabs: [
                        Tab(icon: Icon(Icons.show_chart), text: "Analytics"),
                        Tab(icon: Icon(Icons.table_chart), text: "Data Logs")
                      ],
                    ),
                  );
                },
              ),
            ];
          },
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              ),
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
            // ดึงค่าล่าสุดจาก Firestore มาใช้ก่อนส่งไป Upload
            FirebaseFirestore.instance
                .collection('users').doc(uid).collection('projects').doc(projectId).get()
                .then((doc) {
                   String latestCell = cellLine;
                   String latestDrug = drugName;
                   if (doc.exists) {
                     latestCell = doc.data()?['cellLine'] ?? cellLine;
                     latestDrug = doc.data()?['drugName'] ?? drugName;
                   }
                   Navigator.push(context, MaterialPageRoute(
                    builder: (_) => UploadScreen(projectId: projectId, cellLine: latestCell, drugName: latestDrug)
                  ));
                });
          },
        ),
      ),
    );
  }

  Widget _buildGraphsView(List<QueryDocumentSnapshot> docs) {
    List<FlSpot> countSpots = [];
    List<FlSpot> sizeSpots = [];
    
    // กรองข้อมูลและแปลงเป็น Spot สำหรับกราฟ
    for (var doc in docs) {
      double conc = (doc['concentration'] as num).toDouble();
      countSpots.add(FlSpot(conc, (doc['colonyCount'] as num).toDouble()));
      sizeSpots.add(FlSpot(conc, (doc['avgSize'] as num).toDouble()));
    }
    
    countSpots.sort((a, b) => a.x.compareTo(b.x));
    sizeSpots.sort((a, b) => a.x.compareTo(b.x));

    return ListView(
      padding: const EdgeInsets.all(20), 
      children: [
        _chartCard("Colony Count vs Concentration", countSpots, Colors.cyanAccent),
        const SizedBox(height: 20),
        _chartCard("Avg Size vs Concentration", sizeSpots, Colors.orangeAccent),
        const SizedBox(height: 80)
      ]
    );
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
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text("${v.toInt()}", style: const TextStyle(color: Colors.white54, fontSize: 10)))),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) => Text("${v.toInt()}", style: const TextStyle(color: Colors.white54, fontSize: 10)))),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots, 
                    isCurved: true, 
                    color: color, 
                    barWidth: 3, 
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: color.withOpacity(0.15))
                  )
                ]
              )
            )
          ),
        ],
      ),
    );
  }

  Widget _buildDataLogsView(BuildContext context, List<QueryDocumentSnapshot> docs) {
    // เรียงตามความเข้มข้นเพื่อให้ดูง่าย
    var sortedDocs = List.from(docs);
    sortedDocs.sort((a, b) => (a['concentration'] as num).compareTo(b['concentration'] as num));

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: sortedDocs.length + 1,
      itemBuilder: (context, index) {
        if (index == sortedDocs.length) return const SizedBox(height: 80);
        var data = sortedDocs[index];
        String dateStr = data['timestamp'] != null ? DateFormat('dd/MM HH:mm').format((data['timestamp'] as Timestamp).toDate()) : '-';
        
        return Card(
          color: Colors.white.withOpacity(0.05),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white10, 
              child: Text("${data['concentration']}", style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12))
            ),
            title: Text("${data['colonyCount']} Colonies", style: const TextStyle(color: Colors.white)),
            subtitle: Text("Size: ${(data['avgSize'] as num).toStringAsFixed(1)} | $dateStr", style: const TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent), 
              onPressed: () => _confirmDeleteData(context, data.id)
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteData(BuildContext context, String docId) {
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF203A43), 
        title: const Text("Delete Data?", style: TextStyle(color: Colors.white)), 
        content: const Text("This action cannot be undone.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")), 
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), 
            onPressed: () async { 
              await DatabaseService().deleteExperimentData(projectId, docId); 
              if (ctx.mounted) Navigator.pop(ctx); 
            }, 
            child: const Text("Delete")
          )
        ]
      )
    );
  }
}