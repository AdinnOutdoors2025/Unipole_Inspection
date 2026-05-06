class InspectionDetailsModel {
  bool? success;
  String? message;
  List<Datas>? data;

  InspectionDetailsModel({this.success, this.message, this.data});

  factory InspectionDetailsModel.fromJson(Map<String, dynamic> json) =>
      InspectionDetailsModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Datas>.from(json["data"]!.map((x) => Datas.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datas {
  GeoLocation? geoLocation;
  Foundation? foundation;
  String? id;
  String? userId;
  String? inspectionId;
  String? location;
  String? unipoleHeight;
  String? adStructureSize;
  String? visitingDate;
  String? visitedBy;
  String? visitedByPhone;
  String? selfieImage;
  int? inspectionStatus;
  String? inspectionFlag;
  InspectionMetrics? inspectionMetrics;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  AdBoardFrame? adBoardFrame;
  Post? post;
  GeneralInspection? generalInspection;

  Datas({
    this.geoLocation,
    this.foundation,
    this.id,
    this.userId,
    this.inspectionId,
    this.location,
    this.unipoleHeight,
    this.adStructureSize,
    this.visitingDate,
    this.visitedBy,
    this.visitedByPhone,
    this.selfieImage,
    this.inspectionStatus,
    this.inspectionFlag,
    this.inspectionMetrics,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.adBoardFrame,
    this.post,
    this.generalInspection,
  });

  factory Datas.fromJson(Map<String, dynamic> json) => Datas(
    geoLocation: json["geo_location"] == null
        ? null
        : GeoLocation.fromJson(json["geo_location"]),
    foundation: json["foundation"] == null
        ? null
        : Foundation.fromJson(json["foundation"]),
    id: json["_id"],
    userId: json["user_id"],
    inspectionId: json["inspection_id"],
    location: json["location"],
    unipoleHeight: json["unipole_height"],
    adStructureSize: json["ad_structure_size"],
    visitingDate: json["visiting_date"],
    visitedBy: json["visited_by"],
    visitedByPhone: json["visited_by_phone"],
    selfieImage: json["selfie_image"],
    inspectionStatus: json["inspection_status"],
    inspectionFlag: json["inspection_flag"],
    inspectionMetrics: json["inspection_metrics"] == null
        ? null
        : InspectionMetrics.fromJson(json["inspection_metrics"]),
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    adBoardFrame: json["ad_board_frame"] == null
        ? null
        : AdBoardFrame.fromJson(json["ad_board_frame"]),
    post: json["post"] == null ? null : Post.fromJson(json["post"]),
    generalInspection: json["general_inspection"] == null
        ? null
        : GeneralInspection.fromJson(json["general_inspection"]),
  );

  Map<String, dynamic> toJson() => {
    "geo_location": geoLocation?.toJson(),
    "foundation": foundation?.toJson(),
    "_id": id,
    "user_id": userId,
    "inspection_id": inspectionId,
    "location": location,
    "unipole_height": unipoleHeight,
    "ad_structure_size": adStructureSize,
    "visiting_date": visitingDate,
    "visited_by": visitedBy,
    "visited_by_phone": visitedByPhone,
    "selfie_image": selfieImage,
    "inspection_status": inspectionStatus,
    "inspection_flag": inspectionFlag,
    "inspection_metrics": inspectionMetrics?.toJson(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "ad_board_frame": adBoardFrame?.toJson(),
    "post": post?.toJson(),
    "general_inspection": generalInspection?.toJson(),
  };
}

class AdBoardFrame {
  AnglePipeMembersStrong? vibrationDueToWind;
  AnglePipeMembersStrong? flexProperlyFixed;
  AnglePipeMembersStrong? anglePipeMembersStrong;
  AnglePipeMembersStrong? flexLoose;
  AnglePipeMembersStrong? frameStraight;

  AdBoardFrame({
    this.vibrationDueToWind,
    this.flexProperlyFixed,
    this.anglePipeMembersStrong,
    this.flexLoose,
    this.frameStraight,
  });

  factory AdBoardFrame.fromJson(Map<String, dynamic> json) => AdBoardFrame(
    vibrationDueToWind: json["vibration_due_to_wind"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["vibration_due_to_wind"]),
    flexProperlyFixed: json["flex_properly_fixed"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["flex_properly_fixed"]),
    anglePipeMembersStrong: json["angle_pipe_members_strong"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["angle_pipe_members_strong"]),
    flexLoose: json["flex_loose"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["flex_loose"]),
    frameStraight: json["frame_straight"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["frame_straight"]),
  );

  Map<String, dynamic> toJson() => {
    "vibration_due_to_wind": vibrationDueToWind?.toJson(),
    "flex_properly_fixed": flexProperlyFixed?.toJson(),
    "angle_pipe_members_strong": anglePipeMembersStrong?.toJson(),
    "flex_loose": flexLoose?.toJson(),
    "frame_straight": frameStraight?.toJson(),
  };
}

class AnglePipeMembersStrong {
  bool? status;
  List<String>? images;

  AnglePipeMembersStrong({this.status, this.images});

  factory AnglePipeMembersStrong.fromJson(Map<String, dynamic> json) =>
      AnglePipeMembersStrong(
        status: json["status"],
        images: json["images"] == null
            ? []
            : List<String>.from(json["images"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
  };
}

class Foundation {
  AnglePipeMembersStrong? concreteCracks;
  AnglePipeMembersStrong? soilErosionAtFoundation;
  AnglePipeMembersStrong? waterStagnation;
  AnglePipeMembersStrong? anchorBoltLooseness;
  AnglePipeMembersStrong? basePlateProperlySeated;
  AnglePipeMembersStrong? surroundingSoilLoose;
  AnglePipeMembersStrong? anchorBoltsRusted;
  AnglePipeMembersStrong? gapInBasePlate;
  AnglePipeMembersStrong? groutingDamaged;

  Foundation({
    this.concreteCracks,
    this.soilErosionAtFoundation,
    this.waterStagnation,
    this.anchorBoltLooseness,
    this.basePlateProperlySeated,
    this.surroundingSoilLoose,
    this.anchorBoltsRusted,
    this.gapInBasePlate,
    this.groutingDamaged,
  });

  factory Foundation.fromJson(Map<String, dynamic> json) => Foundation(
    concreteCracks: json["concrete_cracks"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["concrete_cracks"]),
    soilErosionAtFoundation: json["soil_erosion_at_foundation"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["soil_erosion_at_foundation"]),
    waterStagnation: json["water_stagnation"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["water_stagnation"]),
    anchorBoltLooseness: json["anchor_bolt_looseness"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["anchor_bolt_looseness"]),
    basePlateProperlySeated: json["base_plate_properly_seated"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["base_plate_properly_seated"]),
    surroundingSoilLoose: json["surrounding_soil_loose"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["surrounding_soil_loose"]),
    anchorBoltsRusted: json["anchor_bolts_rusted"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["anchor_bolts_rusted"]),
    gapInBasePlate: json["gap_in_base_plate"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["gap_in_base_plate"]),
    groutingDamaged: json["grouting_damaged"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["grouting_damaged"]),
  );

  Map<String, dynamic> toJson() => {
    "concrete_cracks": concreteCracks?.toJson(),
    "soil_erosion_at_foundation": soilErosionAtFoundation?.toJson(),
    "water_stagnation": waterStagnation?.toJson(),
    "anchor_bolt_looseness": anchorBoltLooseness?.toJson(),
    "base_plate_properly_seated": basePlateProperlySeated?.toJson(),
    "surrounding_soil_loose": surroundingSoilLoose?.toJson(),
    "anchor_bolts_rusted": anchorBoltsRusted?.toJson(),
    "gap_in_base_plate": gapInBasePlate?.toJson(),
    "grouting_damaged": groutingDamaged?.toJson(),
  };
}

class GeneralInspection {
  AnglePipeMembersStrong? surroundingAreaSafe;
  AnglePipeMembersStrong? rainDamage;
  AnglePipeMembersStrong? windDamage;
  AnglePipeMembersStrong? repairsCarriedOutProperly;

  GeneralInspection({
    this.surroundingAreaSafe,
    this.rainDamage,
    this.windDamage,
    this.repairsCarriedOutProperly,
  });

  factory GeneralInspection.fromJson(Map<String, dynamic> json) =>
      GeneralInspection(
        surroundingAreaSafe: json["surrounding_area_safe"] == null
            ? null
            : AnglePipeMembersStrong.fromJson(json["surrounding_area_safe"]),
        rainDamage: json["rain_damage"] == null
            ? null
            : AnglePipeMembersStrong.fromJson(json["rain_damage"]),
        windDamage: json["wind_damage"] == null
            ? null
            : AnglePipeMembersStrong.fromJson(json["wind_damage"]),
        repairsCarriedOutProperly: json["repairs_carried_out_properly"] == null
            ? null
            : AnglePipeMembersStrong.fromJson(
                json["repairs_carried_out_properly"],
              ),
      );

  Map<String, dynamic> toJson() => {
    "surrounding_area_safe": surroundingAreaSafe?.toJson(),
    "rain_damage": rainDamage?.toJson(),
    "wind_damage": windDamage?.toJson(),
    "repairs_carried_out_properly": repairsCarriedOutProperly?.toJson(),
  };
}

class GeoLocation {
  double? latitude;
  double? longitude;

  GeoLocation({this.latitude, this.longitude});

  factory GeoLocation.fromJson(Map<String, dynamic> json) => GeoLocation(
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
  };
}

class InspectionMetrics {
  int? totalQuestions;
  int? yesCount;
  int? noCount;
  int? unansweredCount;
  int? averageYesRatio;

  InspectionMetrics({
    this.totalQuestions,
    this.yesCount,
    this.noCount,
    this.unansweredCount,
    this.averageYesRatio,
  });

  factory InspectionMetrics.fromJson(Map<String, dynamic> json) =>
      InspectionMetrics(
        totalQuestions: json["total_questions"],
        yesCount: json["yes_count"],
        noCount: json["no_count"],
        unansweredCount: json["unanswered_count"],
        averageYesRatio: json["average_yes_ratio"],
      );

  Map<String, dynamic> toJson() => {
    "total_questions": totalQuestions,
    "yes_count": yesCount,
    "no_count": noCount,
    "unanswered_count": unansweredCount,
    "average_yes_ratio": averageYesRatio,
  };
}

class Post {
  AnglePipeMembersStrong? postStraight;
  AnglePipeMembersStrong? damageInWeldedJoint;
  AnglePipeMembersStrong? platformStrong;
  AnglePipeMembersStrong? postTilted;
  AnglePipeMembersStrong? crackInWeldedJoint;
  AnglePipeMembersStrong? rustPresent;
  AnglePipeMembersStrong? paintPeeledOff;

  Post({
    this.postStraight,
    this.damageInWeldedJoint,
    this.platformStrong,
    this.postTilted,
    this.crackInWeldedJoint,
    this.rustPresent,
    this.paintPeeledOff,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    postStraight: json["post_straight"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["post_straight"]),
    damageInWeldedJoint: json["damage_in_welded_joint"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["damage_in_welded_joint"]),
    platformStrong: json["platform_strong"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["platform_strong"]),
    postTilted: json["post_tilted"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["post_tilted"]),
    crackInWeldedJoint: json["crack_in_welded_joint"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["crack_in_welded_joint"]),
    rustPresent: json["rust_present"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["rust_present"]),
    paintPeeledOff: json["paint_peeled_off"] == null
        ? null
        : AnglePipeMembersStrong.fromJson(json["paint_peeled_off"]),
  );

  Map<String, dynamic> toJson() => {
    "post_straight": postStraight?.toJson(),
    "damage_in_welded_joint": damageInWeldedJoint?.toJson(),
    "platform_strong": platformStrong?.toJson(),
    "post_tilted": postTilted?.toJson(),
    "crack_in_welded_joint": crackInWeldedJoint?.toJson(),
    "rust_present": rustPresent?.toJson(),
    "paint_peeled_off": paintPeeledOff?.toJson(),
  };
}
