class DashboardModel {
  bool success;
  String message;
  Data data;

  DashboardModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
    success: json["success"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  List<User> users;
  int verifiedCount;
  int unverifiedCount;
  int inspectionTotalCount;
  int inspectionCompletedCount;
  int inspectionInProgressCount;
  int criticalCount;
  int minorIssueCount;
  int goodCount;

  Data({
    required this.users,
    required this.verifiedCount,
    required this.unverifiedCount,
    required this.inspectionTotalCount,
    required this.inspectionCompletedCount,
    required this.inspectionInProgressCount,
    required this.criticalCount,
    required this.minorIssueCount,
    required this.goodCount,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    users: List<User>.from(json["users"].map((x) => User.fromJson(x))),
    verifiedCount: json["verifiedCount"],
    unverifiedCount: json["unverifiedCount"],
    inspectionTotalCount: json["inspectionTotalCount"],
    inspectionCompletedCount: json["inspectionCompletedCount"],
    inspectionInProgressCount: json["inspectionInProgressCount"],
    criticalCount: json["criticalCount"],
    minorIssueCount: json["minorIssueCount"],
    goodCount: json["goodCount"],
  );

  Map<String, dynamic> toJson() => {
    "users": List<dynamic>.from(users.map((x) => x.toJson())),
    "verifiedCount": verifiedCount,
    "unverifiedCount": unverifiedCount,
    "inspectionTotalCount": inspectionTotalCount,
    "inspectionCompletedCount": inspectionCompletedCount,
    "inspectionInProgressCount": inspectionInProgressCount,
    "criticalCount": criticalCount,
    "minorIssueCount": minorIssueCount,
    "goodCount": goodCount,
  };
}

class User {
  String name;
  String phone;
  bool isPhoneVerified;

  User({
    required this.name,
    required this.phone,
    required this.isPhoneVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json["name"],
    phone: json["phone"],
    isPhoneVerified: json["isPhoneVerified"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "phone": phone,
    "isPhoneVerified": isPhoneVerified,
  };
}
