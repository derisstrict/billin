import 'package:billin/common/c_app_bar.dart';
import 'package:billin/common/c_colors.dart';
import 'package:billin/common/c_container.dart';
import 'package:billin/service/receipt_service.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class DeveloperSetting extends StatefulWidget {
  const DeveloperSetting({super.key});

  @override
  State<DeveloperSetting> createState() => _DeveloperSettingState();
}

class _DeveloperSettingState extends State<DeveloperSetting> {
  static const _presets = [
    (label: 'Localhost / USB', url: 'http://127.0.0.1:9931'),
    (label: 'Android Emulator', url: 'http://10.0.2.2:9931'),
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _urlController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(
      text: ReceiptService.currentBaseUrl,
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ReceiptService.setBaseUrl(_urlController.text);
      _urlController.text = ReceiptService.currentBaseUrl;
      if (!mounted) {
        return;
      }
      _showMessage('Llama Base URL diperbarui: ${ReceiptService.currentBaseUrl}');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _reset() async {
    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ReceiptService.resetBaseUrl();
      _urlController.text = ReceiptService.currentBaseUrl;
      _formKey.currentState?.validate();
      if (!mounted) {
        return;
      }
      _showMessage('Llama Base URL direset ke default.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _applyPreset(String url) {
    _urlController.text = url;
    _formKey.currentState?.validate();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CColors.background,
      appBar: const CAppBar('Developer Setting'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: CContainer(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    spacing: 5,
                    children: [
                      Icon(Symbols.bring_your_own_ip,
                        weight: 600,
                        color: CColors.accent,
                      ),
                      Text(
                        'Llama.cpp Server',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CColors.text,
                        ),
                      ),
                      Spacer(),
                      ValueListenableBuilder<String>(
                        valueListenable: ReceiptService.baseUrlNotifier,
                        builder: (context, activeUrl, _) {
                          return Text(
                            activeUrl,
                            style: TextStyle(
                              fontSize: 12,
                              color: CColors.textGray,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _urlController,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      labelText: 'Llama Base URL',
                      labelStyle: TextStyle(color: CColors.accent),
                      hintText: 'http://127.0.0.1:9931',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: CColors.border
                        )
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: CColors.accent,
                          width: 2
                        )
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) =>
                        ReceiptService.validateBaseUrl(value ?? ''),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final preset in _presets)
                        ActionChip(
                          label: Text(preset.label),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: CColors.border
                          ),
                          onPressed: _isSaving
                              ? null
                              : () => _applyPreset(preset.url),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSaving ? null : _reset,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: CColors.border
                            )
                          ),
                          child: const Text('Reset Default',
                            style: TextStyle(
                              color: Colors.black
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CColors.accent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _isSaving ? null : _save,
                          child: const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
