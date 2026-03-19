// lib/features/home/views/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../auth/controllers/auth_controller.dart';
import 'chat_screen.dart';

// ══════════════════════════════════════════════════════
// DATA MODELS
// ══════════════════════════════════════════════════════
class WorkspaceItem {
  String name;
  String lastEdit;
  Color color;
  WorkspaceItem({required this.name, required this.lastEdit, required this.color});
}

class TaskItem {
  String time;
  String title;
  String subtitle;
  Color color;
  bool done;
  TaskItem({required this.time, required this.title,
    required this.subtitle, required this.color, this.done = false});
}

class NoteItem {
  String title;
  String body;
  Color color;
  NoteItem({required this.title, required this.body, required this.color});
}

class ProjectItem {
  String name;
  String tag;
  Color tagColor;
  int active;
  double progress;
  ProjectItem({required this.name, required this.tag,
    required this.tagColor, required this.active, required this.progress});
}

// ── Static storage — persists across navigation ──
class _AppData {
  static final List<WorkspaceItem> workspaces = [];
  static final List<TaskItem> tasks = [];
  static final List<NoteItem> notes = [];
  static final List<ProjectItem> projects = [];
}

// ══════════════════════════════════════════════════════
// MAIN SHELL
// ══════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        ),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: [
            _DashboardPage(onRefresh: () => setState(() {})),
            const ChatScreen(),
            _BrainDumpPage(onRefresh: () => setState(() {})),
            _ProfilePage(onSignOut: () => context.go('/auth')),
          ][_currentIndex],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) {
          HapticFeedback.lightImpact();
          setState(() => _currentIndex = i);
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// BOTTOM NAV
// ══════════════════════════════════════════════════════
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'Home'),
      _NavItem(icon: Icons.chat_bubble_rounded, label: 'AI Chat'),
      _NavItem(icon: Icons.psychology_rounded, label: 'Brain Dump'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24), topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6C3FC8).withOpacity(0.10),
              blurRadius: 24, offset: const Offset(0, -6)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                      horizontal: selected ? 18 : 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight)
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: selected
                        ? [BoxShadow(
                            color: const Color(0xFF6C3FC8).withOpacity(0.30),
                            blurRadius: 12, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Icon(items[i].icon,
                          color: selected ? Colors.white : const Color(0xFFBBB8CC),
                          size: 22),
                      if (selected) ...[
                        const SizedBox(width: 6),
                        Text(items[i].label,
                            style: GoogleFonts.poppins(
                                fontSize: 12, fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ══════════════════════════════════════════════════════
// DASHBOARD PAGE
// ══════════════════════════════════════════════════════
class _DashboardPage extends StatefulWidget {
  final VoidCallback onRefresh;
  const _DashboardPage({required this.onRefresh});
  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _staggerCtrl;
  late List<Animation<double>> _fades;
  late List<Animation<Offset>> _slides;

  final _wsColors = [
    const Color(0xFFEDE6FF), const Color(0xFFE6F4FF),
    const Color(0xFFE6FFEF), const Color(0xFFFFF8E1),
    const Color(0xFFFFEBEE), const Color(0xFFF3E5F5),
  ];

  final _taskColors = [
    const Color(0xFF6C63FF), const Color(0xFF00BCD4),
    const Color(0xFFFFB300), const Color(0xFF4CAF50),
    const Color(0xFFE91E63), const Color(0xFF9C27B0),
  ];

  final _noteColors = [
    const Color(0xFFEDE6FF), const Color(0xFFFFF8E1),
    const Color(0xFFE6FFEF), const Color(0xFFFFEBEE),
  ];

  final _tagColors = [
    const Color(0xFF6C63FF), const Color(0xFF00BFA5),
    const Color(0xFFFF6D00), const Color(0xFF9C27B0),
    const Color(0xFFE53935),
  ];

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fades = List.generate(5, (i) {
      final start = (i * 0.14).clamp(0.0, 0.7);
      final end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _staggerCtrl,
              curve: Interval(start, end, curve: Curves.easeOut)));
    });
    _slides = List.generate(5, (i) {
      final start = (i * 0.14).clamp(0.0, 0.7);
      final end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
          .animate(CurvedAnimation(parent: _staggerCtrl,
              curve: Interval(start, end, curve: Curves.easeOutCubic)));
    });
    _staggerCtrl.forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  String get _firstName =>
      AuthController.currentFirstName?.split(' ').first ?? 'there';

  Widget _section(int i, Widget child) {
    return AnimatedBuilder(
      animation: _fades[i],
      builder: (_, __) => FadeTransition(
          opacity: _fades[i],
          child: SlideTransition(position: _slides[i], child: child)),
    );
  }

  // ── ADD WORKSPACE ──
  void _addWorkspace() {
    final ctrl = TextEditingController();
    int selectedColor = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => _BottomSheet(
          title: 'New Workspace',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetTextField(controller: ctrl, hint: 'Workspace name...'),
              const SizedBox(height: 16),
              Text('Color', style: GoogleFonts.poppins(
                  fontSize: 12, color: const Color(0xFF8A84A3),
                  fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              _ColorPicker(
                colors: _wsColors,
                selected: selectedColor,
                onSelect: (i) => setM(() => selectedColor = i),
              ),
              const SizedBox(height: 24),
              _SheetButton(
                label: 'Add Workspace',
                onTap: () {
                  if (ctrl.text.trim().isNotEmpty) {
                    setState(() {
                      _AppData.workspaces.add(WorkspaceItem(
                        name: ctrl.text.trim(),
                        lastEdit: 'Just now',
                        color: _wsColors[selectedColor],
                      ));
                    });
                    Navigator.pop(ctx);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editWorkspace(int index) {
    final ws = _AppData.workspaces[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BottomSheet(
        title: ws.name,
        child: Column(
          children: [
            _OptionTile(
              icon: Icons.edit_rounded, label: 'Rename',
              color: const Color(0xFF7C5CBF),
              onTap: () {
                Navigator.pop(ctx);
                _renameWorkspace(index);
              },
            ),
            const SizedBox(height: 10),
            _OptionTile(
              icon: Icons.delete_outline_rounded, label: 'Delete',
              color: const Color(0xFFE53935),
              onTap: () {
                setState(() => _AppData.workspaces.removeAt(index));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _renameWorkspace(int index) {
    final ctrl = TextEditingController(text: _AppData.workspaces[index].name);
    showDialog(
      context: context,
      builder: (ctx) => _RenameDialog(
        ctrl: ctrl,
        title: 'Rename Workspace',
        onSave: () {
          if (ctrl.text.trim().isNotEmpty) {
            setState(() {
              _AppData.workspaces[index].name = ctrl.text.trim();
              _AppData.workspaces[index].lastEdit = 'Just now';
            });
            Navigator.pop(ctx);
          }
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  // ── ADD TASK ──
  void _addTask() {
    final titleCtrl = TextEditingController();
    final subtitleCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '09:00');
    int selectedColor = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => _BottomSheet(
          title: 'Add Task',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetTextField(controller: titleCtrl, hint: 'Task title...'),
              const SizedBox(height: 12),
              _SheetTextField(
                  controller: subtitleCtrl, hint: 'Description (optional)'),
              const SizedBox(height: 12),
              _SheetTextField(
                  controller: timeCtrl, hint: 'Time (e.g. 09:00)',
                  keyboardType: TextInputType.datetime),
              const SizedBox(height: 16),
              Text('Color', style: GoogleFonts.poppins(
                  fontSize: 12, color: const Color(0xFF8A84A3),
                  fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              _ColorPicker(
                colors: _taskColors,
                selected: selectedColor,
                onSelect: (i) => setM(() => selectedColor = i),
              ),
              const SizedBox(height: 24),
              _SheetButton(
                label: 'Add Task',
                onTap: () {
                  if (titleCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _AppData.tasks.add(TaskItem(
                        time: timeCtrl.text.trim().isEmpty
                            ? '09:00' : timeCtrl.text.trim(),
                        title: titleCtrl.text.trim(),
                        subtitle: subtitleCtrl.text.trim().isEmpty
                            ? 'Task' : subtitleCtrl.text.trim(),
                        color: _taskColors[selectedColor],
                      ));
                      // Sort by time
                      _AppData.tasks.sort((a, b) => a.time.compareTo(b.time));
                    });
                    Navigator.pop(ctx);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ADD NOTE ──
  void _addNote() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    int selectedColor = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => _BottomSheet(
          title: 'Add Note',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetTextField(controller: titleCtrl, hint: 'Note title...'),
              const SizedBox(height: 12),
              _SheetTextField(
                  controller: bodyCtrl, hint: 'Write your note...',
                  maxLines: 3),
              const SizedBox(height: 16),
              Text('Color', style: GoogleFonts.poppins(
                  fontSize: 12, color: const Color(0xFF8A84A3),
                  fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              _ColorPicker(
                colors: _noteColors,
                selected: selectedColor,
                onSelect: (i) => setM(() => selectedColor = i),
              ),
              const SizedBox(height: 24),
              _SheetButton(
                label: 'Add Note',
                onTap: () {
                  if (titleCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _AppData.notes.add(NoteItem(
                        title: titleCtrl.text.trim(),
                        body: bodyCtrl.text.trim().isEmpty
                            ? '...' : bodyCtrl.text.trim(),
                        color: _noteColors[selectedColor],
                      ));
                    });
                    Navigator.pop(ctx);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ADD PROJECT ──
  void _addProject() {
    final nameCtrl = TextEditingController();
    final tagCtrl = TextEditingController();
    int selectedColor = 0;
    double progress = 0.0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => _BottomSheet(
          title: 'Add Project',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetTextField(controller: nameCtrl, hint: 'Project name...'),
              const SizedBox(height: 12),
              _SheetTextField(controller: tagCtrl, hint: 'Tag (e.g. DESIGN)'),
              const SizedBox(height: 16),
              Text('Progress: ${(progress * 100).toInt()}%',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: const Color(0xFF8A84A3),
                      fontWeight: FontWeight.w500)),
              Slider(
                value: progress,
                onChanged: (v) => setM(() => progress = v),
                activeColor: const Color(0xFF7C5CBF),
                inactiveColor: const Color(0xFFE8E4F5),
              ),
              const SizedBox(height: 8),
              Text('Color', style: GoogleFonts.poppins(
                  fontSize: 12, color: const Color(0xFF8A84A3),
                  fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              _ColorPicker(
                colors: _tagColors,
                selected: selectedColor,
                onSelect: (i) => setM(() => selectedColor = i),
              ),
              const SizedBox(height: 24),
              _SheetButton(
                label: 'Add Project',
                onTap: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _AppData.projects.add(ProjectItem(
                        name: nameCtrl.text.trim(),
                        tag: tagCtrl.text.trim().isEmpty
                            ? 'GENERAL' : tagCtrl.text.trim().toUpperCase(),
                        tagColor: _tagColors[selectedColor],
                        active: 0,
                        progress: progress,
                      ));
                    });
                    Navigator.pop(ctx);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _section(0, _buildHeader())),
        SliverToBoxAdapter(child: _section(1, _buildWorkspaces())),
        SliverToBoxAdapter(child: _section(2, _buildProjectsSection())),
        SliverToBoxAdapter(child: _section(3, _buildTasks())),
        SliverToBoxAdapter(child: _section(4, _buildNotes())),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  // ── HEADER ──
  Widget _buildHeader() {
    final tasks = _AppData.tasks.where((t) => !t.done).length;
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20, right: 20, bottom: 22,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(text: 'Hi, ',
                        style: GoogleFonts.poppins(fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.85))),
                    TextSpan(text: '$_firstName! 👋',
                        style: GoogleFonts.poppins(fontSize: 24,
                            fontWeight: FontWeight.w700, color: Colors.white)),
                  ]),
                ),
                const SizedBox(height: 4),
                Text(
                  tasks == 0
                      ? 'No tasks for today yet'
                      : 'You have $tasks task${tasks == 1 ? '' : 's'} left for today',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: Colors.white.withOpacity(0.72)),
                ),
              ],
            ),
          ),
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.35), width: 1.5),
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  // ── WORKSPACES ──
  Widget _buildWorkspaces() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Work Spaces',
            action: _AddButton(onTap: _addWorkspace),
          ),
          const SizedBox(height: 14),
          _AppData.workspaces.isEmpty
              ? _EmptyCard(
                  icon: Icons.folder_open_rounded,
                  message: 'No workspaces yet\nTap + to create one')
              : SizedBox(
                  height: 115,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _AppData.workspaces.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (ctx, i) => _WorkspaceCard(
                      workspace: _AppData.workspaces[i],
                      onLongPress: () => _editWorkspace(i),
                    ),
                  ),
                ),
          if (_AppData.workspaces.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Long press to edit or delete',
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: const Color(0xFFBBB8CC))),
            ),
        ],
      ),
    );
  }

  // ── PROJECTS ──
  Widget _buildProjectsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Overview',
            action: _AddButton(onTap: _addProject),
          ),
          const SizedBox(height: 14),
          _AppData.projects.isEmpty
              ? _EmptyCard(
                  icon: Icons.work_outline_rounded,
                  message: 'No projects yet\nTap + to add one')
              : Column(
                  children: List.generate(_AppData.projects.length, (i) {
                    final p = _AppData.projects[i];
                    return Dismissible(
                      key: Key('project_$i${p.name}'),
                      direction: DismissDirection.endToStart,
                      background: _DismissBackground(),
                      onDismissed: (_) =>
                          setState(() => _AppData.projects.removeAt(i)),
                      child: _ProjectCard(project: p),
                    );
                  }),
                ),
          if (_AppData.projects.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Swipe left to delete',
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: const Color(0xFFBBB8CC))),
            ),
        ],
      ),
    );
  }

  // ── TASKS ──
  Widget _buildTasks() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: "Today's Tasks",
            action: _AddButton(onTap: _addTask),
          ),
          const SizedBox(height: 14),
          _AppData.tasks.isEmpty
              ? _EmptyCard(
                  icon: Icons.check_circle_outline_rounded,
                  message: "No tasks for today\nTap + to add one")
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C3FC8).withOpacity(0.07),
                        blurRadius: 20, offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: List.generate(_AppData.tasks.length, (i) {
                      final task = _AppData.tasks[i];
                      return Dismissible(
                        key: Key('task_$i${task.title}'),
                        direction: DismissDirection.endToStart,
                        background: _DismissBackground(),
                        onDismissed: (_) =>
                            setState(() => _AppData.tasks.removeAt(i)),
                        child: _TaskRow(
                          task: task,
                          isLast: i == _AppData.tasks.length - 1,
                          onToggle: () {
                            setState(() => task.done = !task.done);
                          },
                        ),
                      );
                    }),
                  ),
                ),
          if (_AppData.tasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Swipe left to delete • tap to mark done',
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: const Color(0xFFBBB8CC))),
            ),
        ],
      ),
    );
  }

  // ── NOTES ──
  Widget _buildNotes() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Recent Notes',
            action: _AddButton(onTap: _addNote),
          ),
          const SizedBox(height: 14),
          _AppData.notes.isEmpty
              ? _EmptyCard(
                  icon: Icons.sticky_note_2_outlined,
                  message: 'No notes yet\nTap + to add one')
              : Wrap(
                  spacing: 10, runSpacing: 10,
                  children: List.generate(_AppData.notes.length, (i) {
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 50) / 2,
                      child: _NoteCard(
                        note: _AppData.notes[i],
                        onDelete: () =>
                            setState(() => _AppData.notes.removeAt(i)),
                      ),
                    );
                  }),
                ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// REUSABLE SHEET COMPONENTS
// ══════════════════════════════════════════════════════
class _BottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  const _BottomSheet({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 20, left: 24, right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28), topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E4F5),
              borderRadius: BorderRadius.circular(2),
            ),
          )),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: const Color(0xFF1E0F5C))),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  const _SheetTextField({
    required this.controller, required this.hint,
    this.maxLines = 1, this.keyboardType,
  });
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: maxLines == 1,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1E0F5C)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: const Color(0xFFBBB8CC)),
        filled: true,
        fillColor: const Color(0xFFF7F5FF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8E4F5), width: 1.2)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7C5CBF), width: 1.5)),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final List<Color> colors;
  final int selected;
  final ValueChanged<int> onSelect;
  const _ColorPicker(
      {required this.colors, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(colors.length, (i) {
        final sel = i == selected;
        return GestureDetector(
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: sel ? 34 : 28, height: sel ? 34 : 28,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: colors[i], shape: BoxShape.circle,
              border: sel
                  ? Border.all(color: const Color(0xFF7C5CBF), width: 2.5)
                  : null,
              boxShadow: sel
                  ? [BoxShadow(color: colors[i].withOpacity(0.5), blurRadius: 8)]
                  : [],
            ),
          ),
        );
      }),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SheetButton({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)]),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [BoxShadow(
            color: const Color(0xFF6C3FC8).withOpacity(0.32),
            blurRadius: 14, offset: const Offset(0, 5),
          )],
        ),
        child: Center(child: Text(label,
            style: GoogleFonts.poppins(fontSize: 15,
                fontWeight: FontWeight.w600, color: Colors.white))),
      ),
    );
  }
}

class _RenameDialog extends StatelessWidget {
  final TextEditingController ctrl;
  final String title;
  final VoidCallback onSave, onCancel;
  const _RenameDialog({
    required this.ctrl, required this.title,
    required this.onSave, required this.onCancel,
  });
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w700,
          color: const Color(0xFF1E0F5C))),
      content: TextField(
        controller: ctrl, autofocus: true,
        style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1E0F5C)),
        decoration: InputDecoration(
          filled: true, fillColor: const Color(0xFFF7F5FF),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF7C5CBF), width: 1.5)),
        ),
      ),
      actions: [
        TextButton(onPressed: onCancel,
            child: Text('Cancel', style: GoogleFonts.poppins(
                color: const Color(0xFF8A84A3)))),
        TextButton(onPressed: onSave,
            child: Text('Save', style: GoogleFonts.poppins(
                color: const Color(0xFF7C5CBF),
                fontWeight: FontWeight.w600))),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════
// UI COMPONENTS
// ══════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  const _SectionHeader({required this.title, this.action});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: const Color(0xFF1E0F5C))),
        if (action != null) action!,
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)]),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text('Add', style: GoogleFonts.poppins(
                fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyCard({required this.icon, required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E4F5), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: const Color(0xFFD8CEF0)),
          const SizedBox(height: 10),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: const Color(0xFFBBB8CC), height: 1.5)),
        ],
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete_outline_rounded,
          color: Color(0xFFE53935), size: 24),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OptionTile({required this.icon, required this.label,
      required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(width: 36, height: 36,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18)),
            const SizedBox(width: 14),
            Text(label, style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// WORKSPACE CARD
// ══════════════════════════════════════════════════════
class _WorkspaceCard extends StatefulWidget {
  final WorkspaceItem workspace;
  final VoidCallback onLongPress;
  const _WorkspaceCard({required this.workspace, required this.onLongPress});
  @override
  State<_WorkspaceCard> createState() => _WorkspaceCardState();
}

class _WorkspaceCardState extends State<_WorkspaceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onLongPress: () { HapticFeedback.mediumImpact(); widget.onLongPress(); },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: 148,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.workspace.color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(
              color: widget.workspace.color.withOpacity(0.5),
              blurRadius: 12, offset: const Offset(0, 4),
            )],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 32, height: 32,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.folder_rounded,
                    color: Color(0xFF7C5CBF), size: 18)),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.workspace.name,
                    style: GoogleFonts.poppins(fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E0F5C)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('Edited ${widget.workspace.lastEdit}',
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: const Color(0xFF8A84A3))),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// PROJECT CARD
// ══════════════════════════════════════════════════════
class _ProjectCard extends StatefulWidget {
  final ProjectItem project;
  const _ProjectCard({required this.project});
  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 900));
    _anim = Tween<double>(begin: 0, end: widget.project.progress)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 200), () => _ctrl.forward());
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Color get _progressColor {
    if (widget.project.progress >= 0.8) return const Color(0xFF4CAF50);
    if (widget.project.progress >= 0.4) return const Color(0xFF6C63FF);
    return const Color(0xFFFFB300);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(
          color: const Color(0xFF6C3FC8).withOpacity(0.06),
          blurRadius: 16, offset: const Offset(0, 4),
        )],
      ),
      child: Column(children: [
        Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(
              color: widget.project.tagColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.work_outline_rounded,
                color: widget.project.tagColor, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(widget.project.name,
                    style: GoogleFonts.poppins(fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E0F5C)),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.project.tagColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6)),
                  child: Text(widget.project.tag,
                      style: GoogleFonts.poppins(fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: widget.project.tagColor,
                          letterSpacing: 0.5)),
                ),
              ]),
              const SizedBox(height: 4),
              Text('${widget.project.active} active tasks',
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: const Color(0xFF8A84A3))),
            ],
          )),
        ]),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progress',
                style: GoogleFonts.poppins(
                    fontSize: 10, color: const Color(0xFF8A84A3))),
            AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Text(
                '${(_anim.value * 100).toInt()}%',
                style: GoogleFonts.poppins(fontSize: 11,
                    fontWeight: FontWeight.w600, color: _progressColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => LinearProgressIndicator(
              value: _anim.value,
              backgroundColor: const Color(0xFFEDE6FF),
              valueColor: AlwaysStoppedAnimation<Color>(_progressColor),
              minHeight: 6,
            ),
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════
// TASK ROW
// ══════════════════════════════════════════════════════
class _TaskRow extends StatelessWidget {
  final TaskItem task;
  final bool isLast;
  final VoidCallback onToggle;
  const _TaskRow({required this.task, required this.isLast,
      required this.onToggle});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(
              bottom: BorderSide(color: Color(0xFFF0EEF8), width: 1)),
        ),
        child: Row(children: [
          SizedBox(width: 44,
            child: Text(task.time, style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: const Color(0xFF1E0F5C)))),
          Container(width: 3, height: 36,
            decoration: BoxDecoration(
                color: task.done
                    ? const Color(0xFFBBB8CC) : task.color,
                borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: task.done
                        ? const Color(0xFFBBB8CC)
                        : const Color(0xFF1E0F5C),
                    decoration: task.done
                        ? TextDecoration.lineThrough : null,
                  )),
              Text(task.subtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: const Color(0xFF8A84A3))),
            ],
          )),
          Icon(
            task.done
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: task.done
                ? const Color(0xFF4CAF50) : const Color(0xFFD8CEF0),
            size: 22,
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// NOTE CARD
// ══════════════════════════════════════════════════════
class _NoteCard extends StatelessWidget {
  final NoteItem note;
  final VoidCallback onDelete;
  const _NoteCard({required this.note, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (ctx) => _BottomSheet(
            title: note.title,
            child: _OptionTile(
              icon: Icons.delete_outline_rounded, label: 'Delete',
              color: const Color(0xFFE53935),
              onTap: () { Navigator.pop(ctx); onDelete(); },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: note.color, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: note.color.withOpacity(0.45),
              blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(note.title, style: GoogleFonts.poppins(fontSize: 12,
              fontWeight: FontWeight.w700, color: const Color(0xFF1E0F5C))),
          const SizedBox(height: 5),
          Text(note.body, style: GoogleFonts.poppins(fontSize: 10.5,
              color: const Color(0xFF5A5480), height: 1.4),
              maxLines: 3, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// BRAIN DUMP PAGE
// ══════════════════════════════════════════════════════
class _BrainDumpPage extends StatefulWidget {
  final VoidCallback onRefresh;
  const _BrainDumpPage({required this.onRefresh});
  @override
  State<_BrainDumpPage> createState() => _BrainDumpPageState();
}

class _BrainDumpPageState extends State<_BrainDumpPage> {
  final _ctrl = TextEditingController();
  final List<String> _dumps = [];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Brain Dump ', style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 4),
              Text('Write anything on your mind',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: Colors.white.withOpacity(0.72))),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  Expanded(child: TextField(
                    controller: _ctrl,
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'What\'s on your mind?',
                      hintStyle: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.5)),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                    maxLines: null,
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) {
                        setState(() { _dumps.insert(0, v.trim()); _ctrl.clear(); });
                      }
                    },
                  )),
                  GestureDetector(
                    onTap: () {
                      if (_ctrl.text.trim().isNotEmpty) {
                        setState(() {
                          _dumps.insert(0, _ctrl.text.trim());
                          _ctrl.clear();
                        });
                      }
                    },
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
          Expanded(
            child: _dumps.isEmpty
                ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.psychology_rounded,
                          size: 48, color: Color(0xFFD8CEF0)),
                      const SizedBox(height: 12),
                      Text('Start typing your thoughts above',
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: const Color(0xFFBBB8CC))),
                    ],
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _dumps.length,
                    itemBuilder: (ctx, i) => Dismissible(
                      key: Key('dump_$i'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: Color(0xFFE53935)),
                      ),
                      onDismissed: (_) =>
                          setState(() => _dumps.removeAt(i)),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(
                            color: const Color(0xFF6C3FC8).withOpacity(0.06),
                            blurRadius: 10, offset: const Offset(0, 3),
                          )],
                        ),
                        child: Text(_dumps[i], style: GoogleFonts.poppins(
                            fontSize: 14, color: const Color(0xFF1E0F5C),
                            height: 1.5)),
                      ),
                    ),
                  ),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// PROFILE PAGE
// ══════════════════════════════════════════════════════
class _ProfilePage extends StatelessWidget {
  final VoidCallback onSignOut;
  const _ProfilePage({required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    final firstName = AuthController.currentFirstName ?? '';
    final lastName = AuthController.currentLastName ?? '';
    final email = AuthController.currentUserEmail ?? '';
    final initials = [
      if (firstName.isNotEmpty) firstName[0],
      if (lastName.isNotEmpty) lastName[0],
    ].join().toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20, right: 20, bottom: 32,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.5), width: 2),
                  ),
                  child: Center(child: Text(initials.isEmpty ? 'U' : initials,
                      style: GoogleFonts.poppins(fontSize: 28,
                          fontWeight: FontWeight.w700, color: Colors.white))),
                ),
                const SizedBox(height: 12),
                Text('$firstName $lastName'.trim(),
                    style: GoogleFonts.poppins(fontSize: 20,
                        fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(email, style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.white.withOpacity(0.7))),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                _ProfileStat(label: 'Workspaces',
                    value: '${_AppData.workspaces.length}',
                    icon: Icons.folder_rounded,
                    color: const Color(0xFF6C63FF)),
                const SizedBox(height: 12),
                _ProfileStat(label: 'Tasks',
                    value: '${_AppData.tasks.length}',
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF4CAF50)),
                const SizedBox(height: 12),
                _ProfileStat(label: 'Projects',
                    value: '${_AppData.projects.length}',
                    icon: Icons.work_rounded,
                    color: const Color(0xFFFFB300)),
                const SizedBox(height: 12),
                _ProfileStat(label: 'Notes',
                    value: '${_AppData.notes.length}',
                    icon: Icons.sticky_note_2_rounded,
                    color: const Color(0xFFE91E63)),
                const SizedBox(height: 32),
                // Sign out
                GestureDetector(
                  onTap: () {
                    AuthController().signOut();
                    onSignOut();
                  },
                  child: Container(
                    width: double.infinity, height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFFFFCDD2), width: 1.2),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      const Icon(Icons.logout_rounded,
                          color: Color(0xFFE53935), size: 20),
                      const SizedBox(width: 8),
                      Text('Sign Out', style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w600,
                          color: const Color(0xFFE53935))),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _ProfileStat({required this.label, required this.value,
      required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: const Color(0xFF6C3FC8).withOpacity(0.05),
          blurRadius: 12, offset: const Offset(0, 3),
        )],
      ),
      child: Row(children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 14),
        Text(label, style: GoogleFonts.poppins(fontSize: 14,
            fontWeight: FontWeight.w500, color: const Color(0xFF5A5480))),
        const Spacer(),
        Text(value, style: GoogleFonts.poppins(fontSize: 20,
            fontWeight: FontWeight.w700, color: const Color(0xFF1E0F5C))),
      ]),
    );
  }
}