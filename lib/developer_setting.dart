import 'package:billin/common/c_app_bar.dart';
import 'package:billin/common/c_colors.dart';
import 'package:billin/common/c_container.dart';
import 'package:billin/service/base_url_config.dart';
import 'package:billin/service/group_service.dart';
import 'package:billin/service/receipt_service.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class DeveloperSetting extends StatelessWidget {
  const DeveloperSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CColors.background,
      appBar: const CAppBar('Developer Setting'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _ServerUrlSection(
                title: 'Llama.cpp Server',
                fieldLabel: 'Llama Base URL',
                hintText: 'http://127.0.0.1:9931',
                config: ReceiptService.baseUrlConfig,
                presets: const [
                  (label: 'Localhost', url: 'http://127.0.0.1:9931'),
                  (label: 'Android Emulator', url: 'http://10.0.2.2:9931'),
                ],
              ),
              const SizedBox(height: 16),
              _ServerUrlSection(
                title: 'BillIn API Server',
                fieldLabel: 'BillIn API Base URL',
                hintText: 'http://10.0.2.2:5000',
                config: GroupService.baseUrlConfig,
                presets: const [
                  (label: 'Localhost', url: 'http://127.0.0.1:5000'),
                  (label: 'Android Emulator', url: 'http://10.0.2.2:5000'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServerUrlSection extends StatefulWidget {
  const _ServerUrlSection({
    required this.title,
    required this.fieldLabel,
    required this.hintText,
    required this.config,
    required this.presets,
  });

  final String title;
  final String fieldLabel;
  final String hintText;
  final BaseUrlConfig config;
  final List<({String label, String url})> presets;

  @override
  State<_ServerUrlSection> createState() => _ServerUrlSectionState();
}

class _ServerUrlSectionState extends State<_ServerUrlSection> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _urlController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.config.currentUrl);
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
      await widget.config.setUrl(_urlController.text);
      _urlController.text = widget.config.currentUrl;
      if (!mounted) {
        return;
      }
      _showMessage(
        '${widget.fieldLabel} diperbarui: ${widget.config.currentUrl}',
      );
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
      await widget.config.resetUrl();
      _urlController.text = widget.config.currentUrl;
      _formKey.currentState?.validate();
      if (!mounted) {
        return;
      }
      _showMessage('${widget.fieldLabel} direset ke default.');
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
    return CContainer(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              spacing: 5,
              children: [
                Icon(
                  Symbols.bring_your_own_ip,
                  weight: 600,
                  color: CColors.accent,
                ),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CColors.text,
                  ),
                ),
                const Spacer(),
                ValueListenableBuilder<String>(
                  valueListenable: widget.config.notifier,
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
                labelText: widget.fieldLabel,
                labelStyle: TextStyle(color: CColors.accent),
                hintText: widget.hintText,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CColors.accent, width: 2),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) => BaseUrlConfig.validate(value ?? ''),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in widget.presets)
                  ActionChip(
                    label: Text(preset.label),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: CColors.border),
                    onPressed:
                        _isSaving ? null : () => _applyPreset(preset.url),
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
                      side: BorderSide(color: CColors.border),
                    ),
                    child: const Text(
                      'Reset Default',
                      style: TextStyle(color: Colors.black),
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
    );
  }
}
