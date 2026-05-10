/// One delivery route in the daily Waveplan. A route is identified by its
/// [routeId] (globally unique) and grouped into a wave by [dispatchTime].
class WaveplanRoute {
  final String routeCode; // CA_A169
  final String routeId; // 7503578-169
  final String dispatchArea; // STG-B_RED.7
  final String waitingAreaSpur; // 'rechts' | 'links'
  final String dispatchTime; // 11:00:00
  final String shiftEndTime; // 20:00:00
  final String serviceType; // Standardpaket
  final String? transporterId; // null when unassigned
  final String? assignedDsp; // AION

  const WaveplanRoute({
    required this.routeCode,
    required this.routeId,
    required this.dispatchArea,
    required this.waitingAreaSpur,
    required this.dispatchTime,
    required this.shiftEndTime,
    required this.serviceType,
    this.transporterId,
    this.assignedDsp,
  });

  WaveplanRoute copyWith({
    String? transporterId,
    bool clearTransporterId = false,
    String? assignedDsp,
    bool clearAssignedDsp = false,
  }) {
    return WaveplanRoute(
      routeCode: routeCode,
      routeId: routeId,
      dispatchArea: dispatchArea,
      waitingAreaSpur: waitingAreaSpur,
      dispatchTime: dispatchTime,
      shiftEndTime: shiftEndTime,
      serviceType: serviceType,
      transporterId: clearTransporterId
          ? null
          : (transporterId ?? this.transporterId),
      assignedDsp: clearAssignedDsp ? null : (assignedDsp ?? this.assignedDsp),
    );
  }

  bool get isAssigned => transporterId != null && transporterId!.isNotEmpty;

  /// Numeric tail of the dispatch area (e.g. STG-B_RED.7 → 7) used for
  /// stable sort within a wave.
  int get dispatchSlot {
    final m = RegExp(r'\.(\d+)$').firstMatch(dispatchArea);
    return m == null ? 0 : int.tryParse(m.group(1) ?? '0') ?? 0;
  }
}
