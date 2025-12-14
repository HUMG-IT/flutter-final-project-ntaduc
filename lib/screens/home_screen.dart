import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/task_provider.dart';
import '../providers/user_provider.dart';
import '../models/task.dart';
import '../widgets/task_list_item.dart';
import '../widgets/login_dialog.dart';
import 'task_form_screen.dart';

/// Màn hình chính hiển thị lịch và danh sách công việc
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  int _selectedViewIndex = 1; // 0: Week, 1: Month, 2: TwoWeeks, 3: Year
  bool _showYearView = false;

  @override
  void initState() {
    super.initState();
    // Load tasks khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final taskProvider = context.read<TaskProvider>();
      taskProvider.setUsername(userProvider.userName);
    });
  }

  Widget _buildViewSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildViewButton('Tuần', 0, Icons.view_week),
          const SizedBox(width: 8),
          _buildViewButton('Tháng', 1, Icons.calendar_view_month),
          const SizedBox(width: 8),
          _buildViewButton('Năm', 3, Icons.calendar_today),
          const SizedBox(width: 8),
          // Nút về ngày hiện tại
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Về hôm nay',
            onPressed: () {
              final today = DateTime.now();
              setState(() {
                _focusedDay = today;
                _showYearView = false;
                _selectedViewIndex = 1;
                _calendarFormat = CalendarFormat.month;
              });
              context.read<TaskProvider>().setSelectedDate(today);
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.withOpacity(0.1),
              foregroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton(String label, int index, IconData icon) {
    final isSelected = _selectedViewIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedViewIndex = index;
            switch (index) {
              case 0:
                _calendarFormat = CalendarFormat.week;
                _showYearView = false;
                break;
              case 1:
                _calendarFormat = CalendarFormat.month;
                _showYearView = false;
                break;
              case 2:
                _calendarFormat = CalendarFormat.twoWeeks;
                _showYearView = false;
                break;
              case 3:
                _showYearView = true;
                break;
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurple : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch & Ghi Chú'),
        elevation: 2,
        leading: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: PopupMenuButton<String>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CircleAvatar(
                  backgroundColor: userProvider.isLoggedIn
                      ? Colors.deepPurple
                      : Colors.grey[400],
                  child: Text(
                    userProvider.userInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  // User info header
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: userProvider.isLoggedIn
                                  ? Colors.deepPurple
                                  : Colors.grey[400],
                              radius: 20,
                              child: Text(
                                userProvider.userInitial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userProvider.displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    userProvider.isLoggedIn
                                        ? 'Đã đăng nhập'
                                        : 'Chế độ khách',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  
                  // Login/Logout option
                  if (!userProvider.isLoggedIn)
                    PopupMenuItem<String>(
                      value: 'login',
                      child: const Row(
                        children: [
                          Icon(Icons.login, size: 20, color: Colors.green),
                          SizedBox(width: 12),
                          Text('Đăng nhập'),
                        ],
                      ),
                    )
                  else
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: const Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Đăng xuất'),
                        ],
                      ),
                    ),
                ],
                onSelected: (value) async {
                  if (value == 'login') {
                    final result = await showDialog(
                      context: context,
                      builder: (context) => const LoginDialog(),
                    );
                    // Reload tasks sau khi login thành công
                    if (result == true && context.mounted) {
                      final userProvider = context.read<UserProvider>();
                      final taskProvider = context.read<TaskProvider>();
                      await taskProvider.setUsername(userProvider.userName);
                    }
                  } else if (value == 'logout') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xác nhận đăng xuất'),
                        content: const Text('Bạn có chắc muốn đăng xuất?'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Hủy'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Đăng xuất'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && context.mounted) {
                      await context.read<UserProvider>().logout();
                      // Reload tasks với user khách sau khi logout
                      if (context.mounted) {
                        await context.read<TaskProvider>().setUsername(null);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã đăng xuất thành công'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TaskProvider>().loadTasks(),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.loadTasks();
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildViewSelector(),
              if (_showYearView)
                Expanded(child: _buildYearView(provider))
              else ...[
                _buildCalendar(provider),
                const Divider(height: 1),
                _buildTaskListHeader(provider),
                Expanded(
                  child: _buildTaskList(provider),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToTaskForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendar(TaskProvider provider) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 3,
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(provider.selectedDate, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
          provider.setSelectedDate(selectedDay);
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          // Style cho ngày hôm nay
          todayDecoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          // Style cho ngày được chọn
          selectedDecoration: const BoxDecoration(
            color: Colors.deepPurple,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          // Style cho marker (đánh dấu)
          markerDecoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          markerSize: 7.0,
          markerMargin: const EdgeInsets.symmetric(horizontal: 1.0),
          markersMaxCount: 3,
          // Style cho ngày có event
          markersAlignment: Alignment.bottomCenter,
          // Style cho các ngày thường
          defaultTextStyle: const TextStyle(
            color: Colors.black87,
          ),
          // Style cho cuối tuần - CHỈ chủ nhật màu đỏ
          weekendTextStyle: const TextStyle(
            color: Colors.black87, // Thứ 7 vẫn đen
          ),
          // Style cho các ngày ngoài tháng
          outsideTextStyle: TextStyle(
            color: Colors.grey[400],
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false, // Ẩn nút format vì đã có tab
          titleCentered: true,
          titleTextStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          // Format tiêu đề tháng bằng tiếng Việt
          titleTextFormatter: (date, locale) {
            return 'Tháng ${date.month} năm ${date.year}';
          },
        ),
        // Tùy chỉnh màu cho từng ngày trong tuần
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          weekendStyle: TextStyle(
            color: Colors.grey[700], // Thứ 7 màu xám
            fontWeight: FontWeight.bold,
          ),
          dowTextFormatter: (date, locale) {
            // Format thứ theo kiểu T2, T3, CN...
            switch (date.weekday) {
              case DateTime.monday:
                return 'T2';
              case DateTime.tuesday:
                return 'T3';
              case DateTime.wednesday:
                return 'T4';
              case DateTime.thursday:
                return 'T5';
              case DateTime.friday:
                return 'T6';
              case DateTime.saturday:
                return 'T7';
              case DateTime.sunday:
                return 'CN';
              default:
                return '';
            }
          },
        ),
        calendarBuilders: CalendarBuilders(
          // Custom builder cho chủ nhật - màu đỏ
          defaultBuilder: (context, day, focusedDay) {
            if (day.weekday == DateTime.sunday) {
              return Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              );
            }
            return null; // Trả về null để dùng style mặc định
          },
          // Custom builder cho marker để hiển thị số lượng task
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return const SizedBox();
            
            final count = provider.getTaskCountForDate(day);
            if (count == 0) return const SizedBox();
            
            return Positioned(
              bottom: 1,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Center(
                  child: Text(
                    count > 9 ? '9+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
          // Custom builder để thêm indicator cho task hoàn thành
          singleMarkerBuilder: (context, day, event) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            );
          },
        ),
        eventLoader: (day) {
          // Hiển thị marker cho các ngày có task
          final count = provider.getTaskCountForDate(day);
          return List.generate(count, (index) => 'task');
        },
      ),
    );
  }

  String _getVietnameseDayOfWeek(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Thứ 2';
      case DateTime.tuesday:
        return 'Thứ 3';
      case DateTime.wednesday:
        return 'Thứ 4';
      case DateTime.thursday:
        return 'Thứ 5';
      case DateTime.friday:
        return 'Thứ 6';
      case DateTime.saturday:
        return 'Thứ 7';
      case DateTime.sunday:
        return 'Chủ nhật';
      default:
        return '';
    }
  }

  String _getVietnameseMonth(int month) {
    return 'Tháng $month';
  }

  Widget _buildTaskListHeader(TaskProvider provider) {
    final date = provider.selectedDate;
    final dayOfWeek = _getVietnameseDayOfWeek(date.weekday);
    final dateStr = '$dayOfWeek, ngày ${date.day} ${_getVietnameseMonth(date.month)} năm ${date.year}';
    final taskCount = provider.tasksForSelectedDate.length;
    final completedCount = provider.tasksForSelectedDate.where((t) => t.isCompleted).length;

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedCount/$taskCount công việc hoàn thành',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (taskCount > 0)
            CircularProgressIndicator(
              value: taskCount > 0 ? completedCount / taskCount : 0,
              backgroundColor: Colors.grey[300],
            ),
        ],
      ),
    );
  }

  Widget _buildTaskList(TaskProvider provider) {
    final tasks = provider.tasksForSelectedDate;

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không có công việc nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Thêm công việc mới'),
              onPressed: () => _navigateToTaskForm(context),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskListItem(
          task: task,
          onTap: () => _navigateToTaskForm(context, task: task),
          onToggleComplete: () => provider.toggleTaskComplete(task.id),
          onDelete: () => _confirmDelete(context, task),
        );
      },
    );
  }

  void _navigateToTaskForm(BuildContext context, {Task? task}) async {
    final userProvider = context.read<UserProvider>();
    
    // Kiểm tra đăng nhập trước khi tạo/sửa task
    if (!userProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để tạo công việc'),
          backgroundColor: Colors.orange,
        ),
      );
      final result = await showDialog(
        context: context,
        builder: (context) => const LoginDialog(),
      );
      // Reload tasks sau khi login thành công
      if (result == true && context.mounted) {
        final taskProvider = context.read<TaskProvider>();
        await taskProvider.setUsername(userProvider.userName);
      }
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(
          task: task,
          initialDate: context.read<TaskProvider>().selectedDate,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa công việc "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<TaskProvider>().deleteTask(task.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa công việc')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _showSearchDialog(BuildContext context) async {
    final controller = TextEditingController();
    final provider = context.read<TaskProvider>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tìm kiếm công việc'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nhập từ khóa...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final results = await provider.searchTasks(controller.text);
              if (context.mounted) {
                Navigator.pop(context);
                _showSearchResults(context, results);
              }
            },
            child: const Text('Tìm'),
          ),
        ],
      ),
    );
  }

  void _showSearchResults(BuildContext context, List<Task> results) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tìm thấy ${results.length} kết quả',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text('Không tìm thấy kết quả'))
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final task = results[index];
                      return TaskListItem(
                        task: task,
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToTaskForm(context, task: task);
                        },
                        onToggleComplete: () =>
                            context.read<TaskProvider>().toggleTaskComplete(task.id),
                        onDelete: () => _confirmDelete(context, task),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearView(TaskProvider provider) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header năm
          Card(
            margin: const EdgeInsets.all(8),
            elevation: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.deepPurple),
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(_focusedDay.year - 1, _focusedDay.month);
                      });
                    },
                  ),
                  Text(
                    'Năm ${_focusedDay.year}',
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.deepPurple),
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(_focusedDay.year + 1, _focusedDay.month);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // Grid 12 tháng
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                return _buildMonthCard(provider, month);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCard(TaskProvider provider, int month) {
    final firstDayOfMonth = DateTime(_focusedDay.year, month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;
    
    // Tên tháng
    final monthNames = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
      'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
      'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
    ];

    // Kiểm tra xem tháng hiện tại có phải là tháng đang chọn không
    final isCurrentMonth = month == DateTime.now().month && 
                          _focusedDay.year == DateTime.now().year;

    return GestureDetector(
      onTap: () {
        setState(() {
          _focusedDay = DateTime(_focusedDay.year, month, 1);
          _selectedViewIndex = 1;
          _showYearView = false;
          _calendarFormat = CalendarFormat.month;
        });
        provider.setSelectedDate(DateTime(_focusedDay.year, month, 1));
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth;
            final cellSize = (cardWidth - 16) / 7;
            final fontSize = cellSize * 0.4;
            final headerFontSize = fontSize * 0.8;
            
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: isCurrentMonth
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.deepPurple.withOpacity(0.1),
                          Colors.blue.withOpacity(0.05),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tên tháng
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isCurrentMonth ? Colors.deepPurple : Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        monthNames[month - 1],
                        style: TextStyle(
                          color: isCurrentMonth ? Colors.white : Colors.black87,
                          fontSize: fontSize * 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Tên các ngày trong tuần
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
                        .map((day) => SizedBox(
                              width: cellSize,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  day,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: day == 'CN' ? Colors.red : Colors.grey[600],
                                    fontSize: headerFontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 4),
                  // Grid các ngày
                  // Tính số tuần cần hiển thị
                  ...() {
                    final firstDayIndex = firstWeekday == 7 ? 6 : firstWeekday - 1;
                    final totalDays = daysInMonth + firstDayIndex;
                    final weeksNeeded = (totalDays / 7).ceil();
                    
                    return List.generate(weeksNeeded, (weekIndex) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (dayIndex) {
                            final index = weekIndex * 7 + dayIndex;
                            final dayOffset = index - firstDayIndex;
                            final day = dayOffset + 1;
                            
                            if (day < 1 || day > daysInMonth) {
                              return SizedBox(width: cellSize, height: cellSize);
                            }

                            final date = DateTime(_focusedDay.year, month, day);
                            final isToday = date.day == DateTime.now().day &&
                                           date.month == DateTime.now().month &&
                                           date.year == DateTime.now().year;
                            final isSunday = date.weekday == DateTime.sunday;
                            final taskCount = provider.getTaskCountForDate(date);

                            return SizedBox(
                              width: cellSize,
                              height: cellSize,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isToday ? Colors.blue : null,
                                  shape: BoxShape.circle,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '$day',
                                        style: TextStyle(
                                          color: isToday
                                              ? Colors.white
                                              : isSunday
                                                  ? Colors.red
                                                  : Colors.black87,
                                          fontSize: fontSize,
                                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (taskCount > 0)
                                      Positioned(
                                        bottom: cellSize * 0.1,
                                        child: Container(
                                          width: cellSize * 0.15,
                                          height: cellSize * 0.15,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    });
                  }(),

                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
