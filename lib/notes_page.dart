import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import 'supabase_client.dart';

const double _actionSize = 40;

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, dynamic>> _notes = [];

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await supabase
          .from('Notes')
          .select()
          .order('id', ascending: false);

      if (!mounted) return;

      setState(() {
        _notes = List<Map<String, dynamic>>.from(data);
        _loading = false;
        _error = null;
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Could not load notes.';
      });
    }
  }

  Future<String?> _showNoteDialog({
    required String title,
    required String action,
    String initialValue = '',
  }) {
    return AdaptiveAlertDialog.inputShow(
      context: context,
      title: title,
      message: 'Write your note below.',
      input: AdaptiveAlertDialogInput(
        placeholder: 'Write a note',
        initialValue: initialValue,
        keyboardType: TextInputType.text,
      ),
      actions: [
        AlertAction(
          title: 'Cancel',
          style: AlertActionStyle.cancel,
          onPressed: () {},
        ),
        AlertAction(
          title: action,
          style: AlertActionStyle.primary,
          onPressed: () {},
        ),
      ],
    );
  }

  Future<void> _showAddDialog() async {
    if (_saving) return;

    final result = await _showNoteDialog(title: 'Add note', action: 'Save');
    if (!mounted || result == null) return;

    final text = result.trim();
    if (text.isEmpty) return;

    await _add(text);
  }

  Future<void> _add(String text) async {
    if (_saving) return;

    setState(() => _saving = true);

    try {
      await supabase.from('Notes').insert({'notes': text});
      await _load();
    } on PostgrestException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not save note.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> note) async {
    if (_saving) return;

    final oldText = '${note['notes'] ?? ''}';
    final result = await _showNoteDialog(
      title: 'Edit note',
      action: 'Update',
      initialValue: oldText,
    );
    if (!mounted || result == null) return;

    final newText = result.trim();
    if (newText.isEmpty || newText == oldText) return;

    await _update(note['id'], newText);
  }

  Future<void> _update(dynamic id, String text) async {
    if (_saving) return;

    setState(() => _saving = true);

    try {
      final updated = await supabase
          .from('Notes')
          .update({'notes': text})
          .eq('id', id)
          .select('id');

      if (updated.isEmpty) {
        if (mounted) {
          setState(() {
            _error = 'Note was not updated. Check your permissions.';
          });
        }
        return;
      }

      await _load();
    } on PostgrestException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not update note.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(dynamic id) async {
    if (_saving) return;

    setState(() => _saving = true);

    try {
      await supabase.from('Notes').delete().eq('id', id);
      await _load();
    } on PostgrestException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not delete note.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _navigationAction() {
    if (_saving) {
      return const SizedBox(
        width: _actionSize,
        height: _actionSize,
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return SizedBox(
      width: _actionSize,
      height: _actionSize,
      child: AdaptiveButton.icon(
        onPressed: _showAddDialog,
        icon: CupertinoIcons.add,
        style: AdaptiveButtonStyle.plain,
        minSize: const Size(_actionSize, _actionSize),
        padding: EdgeInsets.zero,
        useSmoothRectangleBorder: false,
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return SizedBox(
      width: _actionSize,
      height: _actionSize,
      child: AdaptiveButton.icon(
        onPressed: _saving ? null : onPressed,
        icon: icon,
        style: AdaptiveButtonStyle.plain,
        iconColor: color,
        minSize: const Size(_actionSize, _actionSize),
        padding: EdgeInsets.zero,
        useSmoothRectangleBorder: false,
      ),
    );
  }

  Widget _noteTile(Map<String, dynamic> note, bool isLast) {
    return AdaptiveListTile(
      title: Text('${note['notes'] ?? ''}'),
      hideBottomDivider: isLast,
      onTap: () => _showEditDialog(note),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _actionButton(
            icon: CupertinoIcons.pencil,
            onPressed: () => _showEditDialog(note),
          ),
          _actionButton(
            icon: CupertinoIcons.delete,
            color: CupertinoColors.systemRed.resolveFrom(context),
            onPressed: () => _delete(note['id']),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdaptiveListTile(
            title: const Text(
              'My notes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            hideBottomDivider: true,
            trailing: _navigationAction(),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              child: Text(
                _error!,
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemRed.resolveFrom(context),
                ),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CupertinoActivityIndicator())
                : _notes.isEmpty
                ? Center(
                    child: Text(
                      'No notes yet',
                      style: TextStyle(color: secondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return _noteTile(note, index == _notes.length - 1);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
