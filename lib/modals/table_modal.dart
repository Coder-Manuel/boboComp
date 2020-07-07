class TableModal{
  final String label;
  final int maxNoChairs;
  final int minNoChairs;
  final double reserveCostPerChair;

  get map => _map();

  // TODO:
  // schedule

  TableModal({
    this.label,
    this.maxNoChairs = 1,
    this.minNoChairs = 1,
    this.reserveCostPerChair = 0.0,
  });

  Map<String, dynamic> _map(){
    return{
      'label': label,
      'maxNoChairs': maxNoChairs,
      'minNoChairs': minNoChairs,
      'reserveCostPerChair': reserveCostPerChair
    };
  }
}