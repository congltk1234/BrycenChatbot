class ChatTitleModel {
  String? chatid;
  String? chattitle;
  // String? createdAt;
  String? memory;
  // String? modifiedAt;

  ChatTitleModel({
    this.chatid,
    this.chattitle,
    // this.createdAt,
    this.memory,
    // this.modifiedAt,
  });

  ChatTitleModel.fromJson(Map<String, dynamic> json) {
    chattitle = json['chattitle'];
    // createdAt = json['createdAt'];
    memory = json['memory'];
    // modifiedAt = json['modifiedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chattitle'] = this.chattitle;
    data['chatid'] = this.chatid;
    // data['createdAt'] = this.createdAt;
    data['memory'] = this.memory;
    // data['modifiedAt'] = this.modifiedAt;
    return data;
  }
}
