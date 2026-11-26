import 'package:billin/model/receipt.dart';

class GroupMember {
  final String id;
  final String name;
  final String role;
  final int colorIndex;

  const GroupMember({
    required this.id,
    required this.name,
    required this.role,
    required this.colorIndex,
  });

  bool get isHost => role == 'host';

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'member',
      colorIndex: int.tryParse(json['color_index']?.toString() ?? '') ?? 0,
    );
  }
}

class MemberShare {
  final int itemCount;
  final double subtotal;
  final int tax;
  final int service;
  final int discount;
  final int total;

  const MemberShare({
    required this.itemCount,
    required this.subtotal,
    required this.tax,
    required this.service,
    required this.discount,
    required this.total,
  });
}

class GroupData {
  final String token;
  final String joinUrl;
  final int revision;
  final ReceiptData receipt;
  final List<GroupMember> members;
  final Map<int, Set<String>> assignments;

  const GroupData({
    required this.token,
    required this.joinUrl,
    required this.revision,
    required this.receipt,
    required this.members,
    required this.assignments,
  });

  factory GroupData.fromJson(Map<String, dynamic> json) {
    final rawReceipt = json['receipt'];
    final receipt = rawReceipt is Map
        ? ReceiptData.fromJson(Map<String, dynamic>.from(rawReceipt))
        : ReceiptData.demo();

    final members = <GroupMember>[];
    final rawMembers = json['members'];
    if (rawMembers is List) {
      for (final member in rawMembers) {
        if (member is Map) {
          members.add(GroupMember.fromJson(Map<String, dynamic>.from(member)));
        }
      }
    }

    final assignments = <int, Set<String>>{};
    final rawAssignments = json['assignments'];
    if (rawAssignments is Map) {
      rawAssignments.forEach((key, value) {
        final index = int.tryParse(key.toString());
        if (index == null || value is! List) {
          return;
        }
        assignments[index] = value.map((item) => item.toString()).toSet();
      });
    }

    return GroupData(
      token: json['token']?.toString() ?? '',
      joinUrl: json['join_url']?.toString() ?? '',
      revision: int.tryParse(json['revision']?.toString() ?? '') ?? 0,
      receipt: receipt,
      members: members,
      assignments: assignments,
    );
  }

  /// Used while the backend is unreachable so the split page stays usable in
  /// local-only mode.
  factory GroupData.local(ReceiptData receipt, {String hostName = 'Melissa'}) {
    final host = GroupMember(
      id: 'local-host',
      name: hostName,
      role: 'host',
      colorIndex: 0,
    );

    return GroupData(
      token: '',
      joinUrl: '',
      revision: 0,
      receipt: receipt,
      members: [host],
      assignments: {},
    );
  }

  GroupMember? memberById(String? id) {
    if (id == null) {
      return null;
    }
    for (final member in members) {
      if (member.id == id) {
        return member;
      }
    }
    return null;
  }

  GroupMember? get host {
    for (final member in members) {
      if (member.isHost) {
        return member;
      }
    }
    return null;
  }

  Set<int> selectedIndexes(String memberId) {
    final selected = <int>{};
    assignments.forEach((index, memberIds) {
      if (memberIds.contains(memberId)) {
        selected.add(index);
      }
    });
    return selected;
  }

  List<GroupMember> assigneesFor(int index) {
    final memberIds = assignments[index] ?? const <String>{};
    return members.where((member) => memberIds.contains(member.id)).toList();
  }

  int get allItemsSubtotal =>
      receipt.items.fold(0, (sum, item) => sum + item.total);

  double itemSubtotalFor(String memberId) {
    var subtotal = 0.0;
    for (var index = 0; index < receipt.items.length; index++) {
      final memberIds = assignments[index] ?? const <String>{};
      if (memberIds.contains(memberId) && memberIds.isNotEmpty) {
        subtotal += receipt.items[index].total / memberIds.length;
      }
    }
    return subtotal;
  }

  MemberShare shareFor(String memberId) {
    final subtotal = itemSubtotalFor(memberId);
    final ratio = allItemsSubtotal == 0 ? 0.0 : subtotal / allItemsSubtotal;
    final tax = (receipt.tax * ratio).round();
    final service = (receipt.serviceCharge * ratio).round();
    final discount = (receipt.discounts * ratio).round();
    final total = (subtotal + tax + service - discount).round();

    return MemberShare(
      itemCount: selectedIndexes(memberId).length,
      subtotal: subtotal,
      tax: tax,
      service: service,
      discount: discount,
      total: total,
    );
  }

  GroupData copyWith({
    List<GroupMember>? members,
    Map<int, Set<String>>? assignments,
    int? revision,
  }) {
    return GroupData(
      token: token,
      joinUrl: joinUrl,
      revision: revision ?? this.revision,
      receipt: receipt,
      members: members ?? this.members,
      assignments: assignments ?? this.assignments,
    );
  }

  GroupData withAssignments(String memberId, Set<int> indexes) {
    final next = <int, Set<String>>{};

    assignments.forEach((index, memberIds) {
      final copy = Set<String>.from(memberIds)..remove(memberId);
      if (copy.isNotEmpty) {
        next[index] = copy;
      }
    });

    for (final index in indexes) {
      next.putIfAbsent(index, () => <String>{}).add(memberId);
    }

    return copyWith(assignments: next);
  }
}

/// How an item should be presented in the split list.
enum ItemSplitBadge {
  /// Nobody or a single person is assigned; no header is shown.
  solo,

  /// One unit per assignee (quantity equals the number of assignees).
  each,

  /// The quantity does not match the assignee count, so the portions are
  /// shared and each person's exact amount is unknown.
  shared,
}

ItemSplitBadge splitBadgeFor(int assigneeCount, num quantity) {
  if (assigneeCount <= 1) {
    return ItemSplitBadge.solo;
  }
  if (quantity == assigneeCount) {
    return ItemSplitBadge.each;
  }
  return ItemSplitBadge.shared;
}
