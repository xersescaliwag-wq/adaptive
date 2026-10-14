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

  // READ NOTES
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

  // ADD NOTE DIALOG
  Future<void> _showAddDialog() async {
    if (_saving) return;

    var cancelled = false;

    final result = await AdaptiveAlertDialog.inputShow(
      context: context,
      title: 'Add note',
      message: 'Write your note below.',
      input: AdaptiveAlertDialogInput(
        placeholder: 'Write a note',
        initialValue: '',
        keyboardType: TextInputType.text,
      ),
      actions: [
        AlertAction(
          title: 'Cancel',
          style: AlertActionStyle.cancel,
          onPressed: () {
            cancelled = true;
          },
        ),
        AlertAction(
          title: 'Save',
          style: AlertActionStyle.primary,
          onPressed: () {},
        ),
      ],
    );

    if (!mounted || cancelled || result == null) return;

    final text = result.trim();
    if (text.isEmpty) return;

    await _add(text);
  }

  // CREATE NOTE
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

  // EDIT NOTE DIALOG
  Future<void> _showEditDialog(Map<String, dynamic> note) async {
    if (_saving) return;

    final oldText = '${note['notes'] ?? ''}';
    var cancelled = false;

    final result = await AdaptiveAlertDialog.inputShow(
      context: context,
      title: 'Edit note',
      message: 'Update your note below.',
      input: AdaptiveAlertDialogInput(
        placeholder: 'Edit your note',
        initialValue: oldText,
        keyboardType: TextInputType.text,
      ),
      actions: [
        AlertAction(
          title: 'Cancel',
          style: AlertActionStyle.cancel,
          onPressed: () {
            cancelled = true;
          },
        ),
        AlertAction(
          title: 'Update',
          style: AlertActionStyle.primary,
          onPressed: () {},
        ),
      ],
    );

    if (!mounted || cancelled || result == null) return;

    final newText = result.trim();

    if (newText.isEmpty || newText == oldText) return;

    await _update(note['id'], newText);
  }

  // UPDATE NOTE IN SUPABASE
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

  // DELETE NOTE
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

  // ADD MENU BUTTON
  Widget _menuButton() {
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
      child: AdaptivePopupMenuButton.icon<String>(
        icon: PlatformInfo.isIOS26OrHigher()
            ? 'ellipsis'
            : CupertinoIcons.ellipsis,
        size: _actionSize,
        buttonStyle: PopupButtonStyle.plain,
        items: [
          AdaptivePopupMenuItem(
            label: 'Add note',
            icon: PlatformInfo.isIOS26OrHigher() ? 'plus' : CupertinoIcons.add,
            value: 'add',
          ),
        ],
        onSelected: (index, item) {
          if (item.value == 'add') {
            _showAddDialog();
          }
        },
      ),
    );
  }

  // EDIT AND DELETE BUTTONS
  Widget _noteActions(Map<String, dynamic> note) {
    return SizedBox(
      width: 88,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: _actionSize,
            height: _actionSize,
            child: AdaptiveButton.icon(
              onPressed: () => _showEditDialog(note),
              icon: CupertinoIcons.pencil,
              style: AdaptiveButtonStyle.plain,
              minSize: const Size(_actionSize, _actionSize),
              padding: EdgeInsets.zero,
              useSmoothRectangleBorder: false,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: _actionSize,
            height: _actionSize,
            child: AdaptiveButton.icon(
              onPressed: () => _delete(note['id']),
              icon: CupertinoIcons.delete,
              style: AdaptiveButtonStyle.plain,
              minSize: const Size(_actionSize, _actionSize),
              padding: EdgeInsets.zero,
              useSmoothRectangleBorder: false,
            ),
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
          // HEADER
          AdaptiveListTile(
            title: const Text(
              'My notes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            hideBottomDivider: true,
            trailing: _menuButton(),
          ),

          // ERROR MESSAGE
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                _error!,
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemRed.resolveFrom(context),
                ),
              ),
            ),

          // NOTES LIST
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

                      return AdaptiveListTile(
                        title: Text('${note['notes'] ?? ''}'),
                        onTap: () => _showEditDialog(note),
                        hideBottomDivider: index == _notes.length - 1,
                        trailing: _noteActions(note),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
