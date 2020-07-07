class TicketModel{
  TicketModel({this.id, this.ticketManager, this.userId, this.state = 'Pending'});
  final String id;
  final String userId;
  final String state;
  final String ticketManager;

  Map<String, dynamic> asMap(){
    return{
      "userId": userId,
      "state": state,
      "ticketManager": ticketManager
    };
  }

  TicketModel fromMap(Map<String, dynamic> obj){
    return TicketModel(
      id: obj['id'],
      userId: obj['userId'],
      state: obj['state'],
      ticketManager: obj['ticketManager'],
    );
  }
}