import 'package:flutter/material.dart';
import '../models/idoso.dart';
import '../services/idoso_service.dart';
import '../constants/app_colors.dart';

class IdosoFormScreen extends StatefulWidget {
  final String? token;
  final Idoso? idoso; // null = criar novo, não-null = editar

  const IdosoFormScreen({super.key, this.token, this.idoso});

  @override
  State<IdosoFormScreen> createState() => _IdosoFormScreenState();
}

class _IdosoFormScreenState extends State<IdosoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cpfController = TextEditingController();

  DateTime? _dataNascimento;
  String _nivelCognitivo = 'normal';
  bool _limitacoesAuditivas = false;
  bool _usaAparelhoAuditivo = false;
  bool _limitacoesVisuais = false;
  String _mobilidade = 'independente';
  String _tomVoz = 'amigavel';
  String _preferenciaHorario = 'manha';

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.idoso != null) {
      _loadIdosoData();
    }
  }

  void _loadIdosoData() {
    final idoso = widget.idoso!;
    _nomeController.text = idoso.nome;
    _telefoneController.text = idoso.telefone;
    _cpfController.text = idoso.cpf ?? '';
    _dataNascimento = idoso.dataNascimento;
    _nivelCognitivo = idoso.nivelCognitivo;
    _limitacoesAuditivas = idoso.limitacoesAuditivas;
    _usaAparelhoAuditivo = idoso.usaAparelhoAuditivo;
    _limitacoesVisuais = idoso.limitacoesVisuais;
    _mobilidade = idoso.mobilidade;
    _tomVoz = idoso.tomVoz;
    _preferenciaHorario = idoso.preferenciaHorarioLigacao;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime(1950),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dataNascimento = picked;
      });
    }
  }

  Future<void> _saveIdoso() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dataNascimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de nascimento')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final idoso = Idoso(
      id: widget.idoso?.id ?? '',
      nome: _nomeController.text,
      dataNascimento: _dataNascimento!,
      telefone: _telefoneController.text,
      cpf: _cpfController.text.isEmpty ? null : _cpfController.text,
      nivelCognitivo: _nivelCognitivo,
      limitacoesAuditivas: _limitacoesAuditivas,
      usaAparelhoAuditivo: _usaAparelhoAuditivo,
      limitacoesVisuais: _limitacoesVisuais,
      mobilidade: _mobilidade,
      tomVoz: _tomVoz,
      preferenciaHorarioLigacao: _preferenciaHorario,
    );

    final result = widget.idoso == null
        ? await IdosoService.createIdoso(idoso, token: widget.token)
        : await IdosoService.updateIdoso(
            widget.idoso!.id,
            idoso,
            token: widget.token,
          );

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.idoso == null
                  ? 'Idoso cadastrado com sucesso!'
                  : 'Idoso atualizado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar idoso'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.idoso == null ? 'Novo Idoso' : 'Editar Idoso',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('Informações Básicas', [
              TextFormField(
                controller: _nomeController,
                decoration: _inputDecoration('Nome Completo', Icons.person),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: _inputDecoration(
                    'Data de Nascimento',
                    Icons.cake,
                  ),
                  child: Text(
                    _dataNascimento == null
                        ? 'Selecione a data'
                        : '${_dataNascimento!.day}/${_dataNascimento!.month}/${_dataNascimento!.year}',
                    style: TextStyle(
                      color: _dataNascimento == null
                          ? Colors.grey[600]
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefoneController,
                decoration: _inputDecoration('Telefone', Icons.phone),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cpfController,
                decoration: _inputDecoration('CPF (opcional)', Icons.badge),
                keyboardType: TextInputType.number,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection('Perfil de Saúde', [
              _buildDropdown(
                'Nível Cognitivo',
                _nivelCognitivo,
                ['normal', 'leve', 'moderado', 'severo'],
                (value) => setState(() => _nivelCognitivo = value!),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                'Mobilidade',
                _mobilidade,
                ['independente', 'auxiliado', 'cadeira_rodas'],
                (value) => setState(() => _mobilidade = value!),
              ),
              const SizedBox(height: 16),
              _buildCheckbox(
                'Limitações Auditivas',
                _limitacoesAuditivas,
                (value) => setState(() => _limitacoesAuditivas = value!),
              ),
              if (_limitacoesAuditivas)
                _buildCheckbox(
                  'Usa Aparelho Auditivo',
                  _usaAparelhoAuditivo,
                  (value) => setState(() => _usaAparelhoAuditivo = value!),
                ),
              _buildCheckbox(
                'Limitações Visuais',
                _limitacoesVisuais,
                (value) => setState(() => _limitacoesVisuais = value!),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection('Preferências', [
              _buildDropdown('Tom de Voz', _tomVoz, [
                'amigavel',
                'formal',
                'carinhoso',
              ], (value) => setState(() => _tomVoz = value!)),
              const SizedBox(height: 16),
              _buildDropdown(
                'Horário Preferido para Ligação',
                _preferenciaHorario,
                ['manha', 'tarde', 'noite'],
                (value) => setState(() => _preferenciaHorario = value!),
              ),
            ]),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveIdoso,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      widget.idoso == null ? 'Cadastrar' : 'Salvar Alterações',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(_formatLabel(item)));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildCheckbox(
    String label,
    bool value,
    void Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  String _formatLabel(String value) {
    final map = {
      'normal': 'Normal',
      'leve': 'Leve',
      'moderado': 'Moderado',
      'severo': 'Severo',
      'independente': 'Independente',
      'auxiliado': 'Auxiliado',
      'cadeira_rodas': 'Cadeira de Rodas',
      'amigavel': 'Amigável',
      'formal': 'Formal',
      'carinhoso': 'Carinhoso',
      'manha': 'Manhã',
      'tarde': 'Tarde',
      'noite': 'Noite',
    };
    return map[value] ?? value;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _cpfController.dispose();
    super.dispose();
  }
}
