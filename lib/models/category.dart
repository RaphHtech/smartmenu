class CategoryLiveState {
  final List<String> order;
  final Set<String> hidden;
  final Map<String, int> counts;

  CategoryLiveState({
    required this.order,
    required this.hidden,
    required this.counts,
  });
}
