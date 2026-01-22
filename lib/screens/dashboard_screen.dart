import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import 'project_detail_screen.dart';
import 'dart:ui';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Research Projects", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.cyanAccent, size: 30),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: db.getProjects(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
            
            var projects = snapshot.data!.docs;
            
            return ListView.builder(
              itemCount: projects.length,
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 80),
              itemBuilder: (context, index) {
                var p = projects[index];
                // ดึงข้อมูล Cell/Drug (ถ้าเป็นโปรเจกต์เก่าที่ไม่มี key นี้ ให้ใส่ค่า Default)
                String pCellLine = (p.data() as Map).containsKey('cellLine') ? p['cellLine'] : 'Unknown Cell';
                String pDrugName = (p.data() as Map).containsKey('drugName') ? p['drugName'] : 'Unknown Drug';

                return Dismissible(
                  key: Key(p.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.8), borderRadius: BorderRadius.circular(15)),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), SizedBox(width: 10), Icon(Icons.delete_forever, color: Colors.white, size: 30)]),
                  ),
                  confirmDismiss: (direction) async => await _showDeleteConfirmDialog(context),
                  onDismissed: (direction) {
                    db.deleteProject(p.id);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Project deleted"), backgroundColor: Colors.redAccent));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withOpacity(0.1))),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      title: Text(p['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['description'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 5),
                          // โชว์ Tag เล็กๆ ให้รู้ว่าเป็นยาตัวไหน
                          Row(
                            children: [
                              _miniTag(Icons.biotech, pCellLine),
                              const SizedBox(width: 10),
                              _miniTag(Icons.medication, pDrugName),
                            ],
                          )
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.cyanAccent), onPressed: () => _showEditProjectDialog(context, db, p)),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white12, size: 16),
                        ],
                      ),
                      onTap: () {
                        // ส่งข้อมูลไปหน้า Detail เพื่อเตรียมส่งต่อให้หน้า Upload
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ProjectDetailScreen(
                            projectId: p.id, 
                            projectName: p['name'],
                            cellLine: pCellLine,
                            drugName: pDrugName,
                          )
                        ));
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => _showAddProjectDialog(context, db),
      ),
    );
  }

  Widget _miniTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)),
      child: Row(children: [Icon(icon, size: 10, color: Colors.cyanAccent), const SizedBox(width: 4), Text(text, style: const TextStyle(color: Colors.cyanAccent, fontSize: 10))]),
    );
  }

  Future<bool?> _showDeleteConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text("Delete Project?", style: TextStyle(color: Colors.white)),
        content: const Text("This cannot be undone.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  // Dialog สร้างโปรเจกต์ (มี 4 ช่องแล้ว)
  void _showAddProjectDialog(BuildContext context, DatabaseService db) {
     final nameCtrl = TextEditingController();
     final descCtrl = TextEditingController();
     final cellCtrl = TextEditingController();
     final drugCtrl = TextEditingController();
     
     showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text("New Research Project", style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameCtrl, "Project Name"),
              _buildTextField(descCtrl, "Description"),
              const Divider(color: Colors.white24),
              const Text("Setup (Fixed)", style: TextStyle(color: Colors.cyanAccent, fontSize: 12)),
              _buildTextField(cellCtrl, "Cell Line (e.g. A549)"),
              _buildTextField(drugCtrl, "Drug Name (e.g. Isalpinin)"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && cellCtrl.text.isNotEmpty) {
                db.createProject(
                  name: nameCtrl.text, 
                  description: descCtrl.text,
                  cellLine: cellCtrl.text,
                  drugName: drugCtrl.text,
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text("Create"),
          )
        ],
      ),
    );
  }

  void _showEditProjectDialog(BuildContext context, DatabaseService db, DocumentSnapshot doc) {
     final nameCtrl = TextEditingController(text: doc['name']);
     final descCtrl = TextEditingController(text: doc['description']);
     showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text("Edit Project", style: TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [_buildTextField(nameCtrl, "Project Name"), _buildTextField(descCtrl, "Description")]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.black), onPressed: () { if (nameCtrl.text.isNotEmpty) { db.updateProject(doc.id, nameCtrl.text, descCtrl.text); Navigator.pop(ctx); } }, child: const Text("Update"))
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label) {
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: ctrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.cyanAccent), enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)))));
  }
}