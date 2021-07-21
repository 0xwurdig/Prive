class Message {
  final String sent;
  final int status;
  final String body;
  final String type;
  final String from;
  final int id;

  Message({this.id, this.sent, this.body, this.status, this.from, this.type});
}
