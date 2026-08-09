import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/alarm_model.dart';
import '../models/mission_config.dart';
import '../providers/alarm_provider.dart';
import '../services/mission_service.dart';
import '../utils/constants.dart';

/// 新增/编辑闹钟页。
/// Phase 1：时间滚轮 + 重复类型 + 跳过节假日 + 标签 + 任务配置（1-3 个）+ 保存调度。
/// 单日覆盖 / 响铃日历预览在后续补全。
class AlarmEditPage extends StatefulWidget {
  const AlarmEditPage({super.key, this.alarmId});

  /// 编辑时传入；为空表示新增。
  final String? alarmId;

  @override
  State<AlarmEditPage> createState() => _AlarmEditPageState();
}

class _AlarmEditPageState extends State<AlarmEditPage> {
  late TimeOfDay _time;
  ScheduleType _scheduleType = ScheduleType.daily;
  bool _skipHoliday = false;
  String _label = '';
  List<int> _repeatDays = const [1, 2, 3, 4, 5];
  List<MissionConfig> _missions = [
    const MissionConfig(type: MissionType.schulte, difficulty: 2),
  ];

  /// 支持 routes 表内 pushNamed(arguments: alarmId) 传入。
  String? get _alarmId {
    if (widget.alarmId != null) return widget.alarmId;
    final arg = ModalRoute.of(context)?.settings.arguments;
    return arg is String ? arg : null;
  }

  @override
  void initState() {
    super.initState();
    _time = const TimeOfDay(hour: 7, minute: 30);
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final existing = _existing;
    if (existing != null) {
      _time = TimeOfDay(hour: existing.hour, minute: existing.minute);
      _scheduleType = existing.scheduleType;
      _skipHoliday = existing.skipHoliday;
      _label = existing.label;
      if (existing.repeatDays.isNotEmpty) _repeatDays = existing.repeatDays;
      if (existing.missions.isNotEmpty) _missions = existing.missions;
    }
  }

  AlarmModel? get _existing {
    final id = _alarmId;
    if (id == null) return null;
    return context.read<AlarmProvider>().byId(id);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  Future<void> _save() async {
    final provider = context.read<AlarmProvider>();
    final existing = _existing;
    final alarm = AlarmModel(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      hour: _time.hour,
      minute: _time.minute,
      scheduleType: _scheduleType,
      repeatDays: _scheduleType == ScheduleType.custom ? _repeatDays : const [],
      skipHoliday: _skipHoliday,
      label: _label,
      missions: _missions,
      soundPackId: existing?.soundPackId ?? 'crazy',
      volumeFadeIn: existing?.volumeFadeIn ?? true,
      enabled: existing?.enabled ?? true,
    );
    await provider.save(alarm);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _addMission() {
    if (_missions.length >= 3) return;
    setState(() => _missions.add(const MissionConfig(type: MissionType.schulte)));
  }

  void _removeMission(int index) {
    if (_missions.length <= 1) return;
    setState(() => _missions.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarmId == null ? '新增闹钟' : '编辑闹钟'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.pagePadding),
        children: [
          _buildTimeCard(),
          const SizedBox(height: AppDimens.gapM),
          _buildScheduleCard(),
          const SizedBox(height: AppDimens.gapM),
          _buildLabelCard(),
          const SizedBox(height: AppDimens.gapM),
          _buildMissionCard(),
        ],
      ),
    );
  }

  Widget _buildTimeCard() {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimens.gapL, vertical: AppDimens.gapS),
        title: Text(
          _time.format(context),
          style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: 0.5),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text('响铃时间', style: TextStyle(fontSize: 14)),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: _pickTime,
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Card(
      child: Column(
        children: [
          RadioGroup<ScheduleType>(
            groupValue: _scheduleType,
            onChanged: (v) => setState(() => _scheduleType = v!),
            child: const Column(
              children: [
                RadioListTile<ScheduleType>(
                  title: Text('每天'),
                  value: ScheduleType.daily,
                ),
                RadioListTile<ScheduleType>(
                  title: Text('工作日（周一~五）'),
                  value: ScheduleType.weekday,
                ),
                RadioListTile<ScheduleType>(
                  title: Text('仅法定工作日'),
                  value: ScheduleType.legal,
                ),
                RadioListTile<ScheduleType>(
                  title: Text('自定义周几'),
                  value: ScheduleType.custom,
                ),
              ],
            ),
          ),
          if (_scheduleType == ScheduleType.custom)
            Wrap(
              spacing: AppDimens.gapS,
              children: [
                for (var wd = 1; wd <= 7; wd++)
                  FilterChip(
                    label: Text(_weekdayName(wd)),
                    selected: _repeatDays.contains(wd),
                    onSelected: (sel) {
                      setState(() {
                        final set = _repeatDays.toSet();
                        if (sel) {
                          set.add(wd);
                        } else {
                          set.remove(wd);
                        }
                        _repeatDays = set.toList()..sort();
                      });
                    },
                  ),
              ],
            ),
          SwitchListTile(
            title: const Text('跳过节假日 / 周末'),
            subtitle: const Text('工作日闹钟遇节假日不响'),
            value: _skipHoliday,
            onChanged: (v) => setState(() => _skipHoliday = v),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.gapM),
        child: TextField(
          decoration: const InputDecoration(
            labelText: '标签（可选）',
            hintText: '如：上班 / 晨跑',
            border: InputBorder.none,
          ),
          onChanged: (v) => _label = v,
        ),
      ),
    );
  }

  Widget _buildMissionCard() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimens.gapM),
            child: Row(
              children: [
                const Expanded(
                  child: Text('起床任务',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                TextButton.icon(
                  onPressed: _addMission,
                  icon: const Icon(Icons.add),
                  label: const Text('添加任务'),
                ),
              ],
            ),
          ),
          for (var i = 0; i < _missions.length; i++) _buildMissionRow(i),
        ],
      ),
    );
  }

  Widget _buildMissionRow(int index) {
    final mission = _missions[index];
    return ListTile(
      leading: Text('${index + 1}'),
      title: Text(mission.displayName),
      subtitle: Text(_missionDesc(mission)),
      trailing: index > 0
          ? IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => _removeMission(index),
            )
          : null,
      onTap: () => _pickMissionType(index),
    );
  }

  Future<void> _pickMissionType(int index) async {
    final type = await showModalBottomSheet<MissionType>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final t in MissionType.values)
              ListTile(
                leading: Icon(_missionIcon(t)),
                title: Text(_typeName(t)),
                trailing: _missions[index].type == t ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(t),
              ),
          ],
        ),
      ),
    );
    if (type == null) return;
    setState(() {
      var m = _missions[index];
      m = MissionConfig(type: type, difficulty: m.difficulty, target: m.target);
      _missions[index] = m;
    });
    await _pickMissionParams(index);
  }

  Future<void> _pickMissionParams(int index) async {
    final m = _missions[index];
    if (m.type == MissionType.steps) {
      final target = await _pickSlider('目标步数', [20, 40, 60], m.target > 0 ? m.target : 20);
      if (target != null) {
        setState(() => _missions[index] = m.copyWith(target: target));
      }
    } else if (m.type == MissionType.shake) {
      final target = await _pickSlider('目标次数', [10, 20, 30], m.target > 0 ? m.target : 10);
      if (target != null) {
        setState(() => _missions[index] = m.copyWith(target: target));
      }
    } else if (m.type == MissionType.schulte) {
      final diff = await _pickSlider('难度（方格大小）', [1, 2, 3], m.difficulty);
      if (diff != null) {
        setState(() => _missions[index] = m.copyWith(difficulty: diff));
      }
    } else if (m.type == MissionType.poem) {
      final diff = await _pickSlider('难度（诗长）', [1, 2, 3], m.difficulty);
      if (diff != null) {
        setState(() => _missions[index] = m.copyWith(difficulty: diff));
      }
    }
  }

  Future<int?> _pickSlider(String title, List<int> options, int current) {
    return showModalBottomSheet<int>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.gapM),
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            for (final o in options)
              ListTile(
                title: Text(o.toString()),
                trailing: o == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(o),
              ),
          ],
        ),
      ),
    );
  }

  String _missionDesc(MissionConfig m) {
    return switch (m.type) {
      MissionType.schulte => '${MissionService.schulteGridSize(m.difficulty)}×${MissionService.schulteGridSize(m.difficulty)} 方格',
      MissionType.poem => '难度 ${m.difficulty} 档古诗',
      MissionType.steps => '走 ${m.target > 0 ? m.target : 20} 步',
      MissionType.shake => '摇 ${m.target > 0 ? m.target : 10} 次',
    };
  }

  String _typeName(MissionType t) => switch (t) {
        MissionType.schulte => '舒尔特方格',
        MissionType.poem => '输入古诗',
        MissionType.steps => '步数任务',
        MissionType.shake => '摇动任务',
      };

  IconData _missionIcon(MissionType t) => switch (t) {
        MissionType.schulte => Icons.grid_on,
        MissionType.poem => Icons.menu_book,
        MissionType.steps => Icons.directions_walk,
        MissionType.shake => Icons.phone_android,
      };

  String _weekdayName(int wd) =>
      const ['', '一', '二', '三', '四', '五', '六', '日'][wd];
}
