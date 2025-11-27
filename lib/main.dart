import 'package:flutter/material.dart';
import 'dart:convert'; // Import necessário para converter dados em JSON
import 'package:shared_preferences/shared_preferences.dart'; // Import para salvar os dados no dispositivo

void main() {
  runApp(const MyApp());
}

// MODELO DE DADOS
class Activity {
  String id;
  String name;
  DateTime date;
  double cost;
  double hours;

  Activity({
    required this.id,
    required this.name,
    required this.date,
    required this.cost,
    required this.hours,
  });

  // Converte o objeto Activity para um Mapa (JSON) para ser salvo
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(), // Datas precisam virar texto
      'cost': cost,
      'hours': hours,
    };
  }

  // Cria um objeto Activity a partir de um Mapa (JSON) carregado
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      cost: json['cost'],
      hours: json['hours'],
    );
  }
}

// APP PRINCIPAL & TEMA (Estilo Azul/Neutro)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Horas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent, // Azul principal
        scaffoldBackgroundColor: const Color(0xFF121212), // Fundo preto neutro (Material Design)
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.lightBlueAccent, // Azul secundário
          surface: Color(0xFF1E1E1E), // Superfície cinza neutra
          onPrimary: Colors.white,
        ),
        useMaterial3: true,
        // Estilizando inputs globalmente para azul
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIconColor: Colors.white54,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// TELA INICIAL (DASHBOARD)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Meta de horas
  final double targetHours = 200.0;
  
  // Lista de atividades
  List<Activity> activities = [];

  @override
  void initState() {
    super.initState();
    _loadData(); // Carrega os dados assim que o app abre
  }

  // Carrega os dados do armazenamento
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('activities_data');
    
    if (dataString != null) {
      // Se tiver dados salvos, decodifica de JSON para Lista de Objetos
      final List<dynamic> jsonList = jsonDecode(dataString);
      setState(() {
        activities = jsonList.map((item) => Activity.fromJson(item)).toList();
      });
    }
  }

  // Salva os dados no armazenamento
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    // Converte a lista de objetos para texto JSON
    final String dataString = jsonEncode(activities.map((e) => e.toJson()).toList());
    await prefs.setString('activities_data', dataString);
  }

  // Getters para cálculos
  double get totalHours => activities.fold(0, (sum, item) => sum + item.hours);
  double get remainingHours => (targetHours - totalHours) > 0 ? (targetHours - totalHours) : 0;

  // Funções de Gerenciamento de Estado
  void _addActivity(Activity newActivity) {
    setState(() {
      activities.add(newActivity);
    });
    _saveData(); // Salva após adicionar
  }
// Edita uma atividade e salvar
  void _editActivity(Activity editedActivity) {
    setState(() {
      int index = activities.indexWhere((a) => a.id == editedActivity.id);
      if (index != -1) {
        activities[index] = editedActivity;
      }
    });
    _saveData();
  }

//Deleta uma atividade e salvar
  void _deleteActivity(String id) {
    setState(() {
      activities.removeWhere((a) => a.id == id);
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Horas Complementares", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)))),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //Topo com contagem regressiva
            _buildProgressCard(),
            
            const Spacer(),

            //Botão de Adicionar
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormScreen(onSubmit: _addActivity),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text("ADICIONAR HORAS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 16),

            //Botão de Ver Lista
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListScreen(
                      activities: activities,
                      onDelete: _deleteActivity,
                      onEdit: (activity) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FormScreen(
                              existingActivity: activity,
                              onSubmit: _editActivity,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.list_alt, color: Colors.blueAccent),
              label: const Text("VER HORAS COMPLEMENTARES", style: TextStyle(color: Colors.blueAccent)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blueAccent),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Surface neutra
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          const Text(
            "PROGRESSO TOTAL",
            style: TextStyle(color: Colors.white54, letterSpacing: 1.5, fontSize: 12),
          ),
          const SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: totalHours.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                TextSpan(
                  text: "/${targetHours.toStringAsFixed(0)} h",
                  style: const TextStyle(fontSize: 24, color: Colors.white54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${remainingHours.toStringAsFixed(0)} horas restantes",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.blueAccent, // Azul
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (totalHours / targetHours).clamp(0.0, 1.0),
            backgroundColor: Colors.white10,
            color: Colors.blueAccent, // Barra azul
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

// TELA DE LISTAGEM
class ListScreen extends StatelessWidget {
  final List<Activity> activities;
  final Function(String) onDelete;
  final Function(Activity) onEdit;

  const ListScreen({
    super.key,
    required this.activities,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Histórico")),
      body: activities.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.history_toggle_off, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text("Nenhuma hora registrada.", style: TextStyle(color: Colors.white54)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final item = activities[index];
                return Card(
                  color: const Color(0xFF1E1E1E), // Surface neutra
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Esquerda: Nome e Data
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${item.date.day.toString().padLeft(2, '0')}/${item.date.month.toString().padLeft(2, '0')}/${item.date.year} • R\$ ${item.cost.toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.white54, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        
                        // Direita: Ações e Horas
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20, color: Colors.white38),
                                  onPressed: () => onEdit(item),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                                  onPressed: () => _confirmDelete(context, item.id),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(68, 138, 255, 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color.fromRGBO(68, 138, 255, 0.5), width: 1),
                              ),
                              child: Text(
                                "${item.hours.toStringAsFixed(0)}h",
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Excluir?", style: TextStyle(color: Colors.white)),
        content: const Text("Essa ação não pode ser desfeita.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text("Cancelar", style: TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text("Excluir", style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              onDelete(id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}

// TELA DE FORMULÁRIO (ADICIONAR/EDITAR)
class FormScreen extends StatefulWidget {
  final Function(Activity) onSubmit;
  final Activity? existingActivity;

  const FormScreen({
    super.key,
    required this.onSubmit,
    this.existingActivity,
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _costController;
  late TextEditingController _hoursController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final item = widget.existingActivity;
    _nameController = TextEditingController(text: item?.name ?? '');
    _costController = TextEditingController(text: item?.cost.toString() ?? '');
    _hoursController = TextEditingController(text: item?.hours.toString() ?? '');
    _selectedDate = item?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newActivity = Activity(
        id: widget.existingActivity?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        date: _selectedDate,
        cost: double.tryParse(_costController.text.replaceAll(',', '.')) ?? 0.0,
        hours: double.tryParse(_hoursController.text) ?? 0.0,
      );

      widget.onSubmit(newActivity);
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blueAccent, // Calendário azul
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingActivity != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Editar Atividade" : "Nova Atividade")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nome do Evento
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Nome do Evento", Icons.event),
                validator: (value) => value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),

              // Data (Botão Customizado)
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white54),
                      const SizedBox(width: 12),
                      Text(
                        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Linha com Custo e Horas
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Custo (R\$)", Icons.attach_money),
                      validator: (value) => value == null || value.isEmpty ? 'Informe o custo' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _hoursController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Qtd. Horas", Icons.access_time),
                      validator: (value) => value == null || value.isEmpty ? 'Informe as horas' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isEditing ? "SALVAR ALTERAÇÕES" : "ADICIONAR EVENTO",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
    );
  }
}