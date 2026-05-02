class InspectionModel {
  bool success;
  String message;
  Data data;

  InspectionModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory InspectionModel.fromJson(Map<String, dynamic> json) =>
      InspectionModel(
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
  String id;
  String userId;
  String inspectionId;
  String? location;
  GeoLocation geoLocation;
  String unipoleHeight;
  String adStructureSize;
  String visitingDate;
  String? visitedBy;
  dynamic selfieImage;
  int inspectionStatus;
  String inspectionFlag;
  InspectionMetrics inspectionMetrics;
  DateTime? createdAt;
  DateTime? updatedAt;
  int v;
  Foundation foundation;
  Post post;
  AdBoardFrame adBoardFrame;
  GeneralInspection generalInspection;

  Data({
    required this.id,
    required this.userId,
    required this.inspectionId,
    required this.location,
    required this.geoLocation,
    required this.unipoleHeight,
    required this.adStructureSize,
    required this.visitingDate,
    required this.visitedBy,
    required this.selfieImage,
    required this.inspectionStatus,
    required this.inspectionFlag,
    required this.inspectionMetrics,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.foundation,
    required this.post,
    required this.adBoardFrame,
    required this.generalInspection,
  });


  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"] ?? "",
    userId: json["user_id"] ?? "",
    inspectionId: json["inspection_id"] ?? "",
    location: json["location"],
    geoLocation: GeoLocation.fromJson(json["geo_location"] ?? {}),
    unipoleHeight: json["unipole_height"] ?? "",
    adStructureSize: json["ad_structure_size"] ?? "",
    visitingDate: json["visiting_date"] ?? "",
    visitedBy: json["visited_by"],
    selfieImage: json["selfie_image"],
    inspectionStatus: json["inspection_status"] ?? 0,
    inspectionFlag: json["inspection_flag"] ?? "",
    inspectionMetrics: InspectionMetrics.fromJson(
      json["inspection_metrics"] ?? {},
    ),
    createdAt: json["createdAt"] != null
        ? DateTime.parse(json["createdAt"])
        : null,
    updatedAt: json["updatedAt"] != null
        ? DateTime.parse(json["updatedAt"])
        : null,
    v: json["__v"] ?? 0,
    foundation: Foundation.fromJson(json["foundation"] ?? {}),
    post: Post.fromJson(json["post"] ?? {}),
    adBoardFrame: AdBoardFrame.fromJson(json["ad_board_frame"] ?? {}),
    generalInspection: GeneralInspection.fromJson(
      json["general_inspection"] ?? {},
    ),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "user_id": userId,
    "inspection_id": inspectionId,
    "location": location,
    "geo_location": geoLocation.toJson(),
    "unipole_height": unipoleHeight,
    "ad_structure_size": adStructureSize,
    "visiting_date": visitingDate,
    "visited_by": visitedBy,
    "selfie_image": selfieImage,
    "inspection_status": inspectionStatus,
    "inspection_flag": inspectionFlag,
    "inspection_metrics": inspectionMetrics.toJson(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "foundation": foundation.toJson(),
    "post": post.toJson(),
    "ad_board_frame": adBoardFrame.toJson(),
    "general_inspection": generalInspection.toJson(),
  };
}

class AdBoardFrame {
  AnglePipeMembersStrong frameStraight;
  AnglePipeMembersStrong bendInFrame;
  AnglePipeMembersStrong anglePipeMembersStrong;
  AnglePipeMembersStrong weldedJointsStrong;
  AnglePipeMembersStrong flexProperlyFixed;
  AnglePipeMembersStrong flexLoose;
  AnglePipeMembersStrong clampsTight;
  AnglePipeMembersStrong supportFastenersLooseness;
  AnglePipeMembersStrong vibrationDueToWind;
  AnglePipeMembersStrong waterRunoffOrSeepageOnStructure;

  AdBoardFrame({
    required this.frameStraight,
    required this.bendInFrame,
    required this.anglePipeMembersStrong,
    required this.weldedJointsStrong,
    required this.flexProperlyFixed,
    required this.flexLoose,
    required this.clampsTight,
    required this.supportFastenersLooseness,
    required this.vibrationDueToWind,
    required this.waterRunoffOrSeepageOnStructure,
  });

  factory AdBoardFrame.fromJson(Map<String, dynamic> json) => AdBoardFrame(
    frameStraight: AnglePipeMembersStrong.fromJson(
      json["frame_straight"] ?? {},
    ),
    bendInFrame: AnglePipeMembersStrong.fromJson(json["bend_in_frame"] ?? {}),
    anglePipeMembersStrong: AnglePipeMembersStrong.fromJson(
      json["angle_pipe_members_strong"] ?? {},
    ),
    weldedJointsStrong: AnglePipeMembersStrong.fromJson(
      json["welded_joints_strong"] ?? {},
    ),
    flexProperlyFixed: AnglePipeMembersStrong.fromJson(
      json["flex_properly_fixed"] ?? {},
    ),
    flexLoose: AnglePipeMembersStrong.fromJson(json["flex_loose"] ?? {}),
    clampsTight: AnglePipeMembersStrong.fromJson(json["clamps_tight"] ?? {}),
    supportFastenersLooseness: AnglePipeMembersStrong.fromJson(
      json["support_fasteners_looseness"] ?? {},
    ),
    vibrationDueToWind: AnglePipeMembersStrong.fromJson(
      json["vibration_due_to_wind"] ?? {},
    ),
    waterRunoffOrSeepageOnStructure: AnglePipeMembersStrong.fromJson(
      json["water_runoff_or_seepage_on_structure"] ?? {},
    ),
  );

  Map<String, dynamic> toJson() => {
    "frame_straight": frameStraight.toJson(),
    "bend_in_frame": bendInFrame.toJson(),
    "angle_pipe_members_strong": anglePipeMembersStrong.toJson(),
    "welded_joints_strong": weldedJointsStrong.toJson(),
    "flex_properly_fixed": flexProperlyFixed.toJson(),
    "flex_loose": flexLoose.toJson(),
    "clamps_tight": clampsTight.toJson(),
    "support_fasteners_looseness": supportFastenersLooseness.toJson(),
    "vibration_due_to_wind": vibrationDueToWind.toJson(),
    "water_runoff_or_seepage_on_structure": waterRunoffOrSeepageOnStructure
        .toJson(),
  };
}

class AnglePipeMembersStrong {
  bool status;
  List<String> images;

  AnglePipeMembersStrong({required this.status, required this.images});

  factory AnglePipeMembersStrong.fromJson(Map<String, dynamic> json) =>
      AnglePipeMembersStrong(
        status: json["status"] ?? false,
        images: json["images"] == null
            ? []
            : List<String>.from(json["images"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "images": List<dynamic>.from(images.map((x) => x)),
  };
}

class Foundation {
  AnglePipeMembersStrong concreteCracks;
  AnglePipeMembersStrong soilErosionAtFoundation;
  AnglePipeMembersStrong waterStagnation;
  AnglePipeMembersStrong anchorBoltLooseness;
  AnglePipeMembersStrong anchorBoltsRusted;
  AnglePipeMembersStrong basePlateProperlySeated;
  AnglePipeMembersStrong gapInBasePlate;
  AnglePipeMembersStrong groutingDamaged;
  AnglePipeMembersStrong foundationTilted;
  AnglePipeMembersStrong foundationSettlementOccurred;
  AnglePipeMembersStrong surroundingSoilLoose;

  Foundation({
    required this.concreteCracks,
    required this.soilErosionAtFoundation,
    required this.waterStagnation,
    required this.anchorBoltLooseness,
    required this.anchorBoltsRusted,
    required this.basePlateProperlySeated,
    required this.gapInBasePlate,
    required this.groutingDamaged,
    required this.foundationTilted,
    required this.foundationSettlementOccurred,
    required this.surroundingSoilLoose,
  });

  factory Foundation.fromJson(Map<String, dynamic> json) => Foundation(
    concreteCracks: AnglePipeMembersStrong.fromJson(
      json["concrete_cracks"] ?? {},
    ),
    soilErosionAtFoundation: AnglePipeMembersStrong.fromJson(
      json["soil_erosion_at_foundation"] ?? {},
    ),
    waterStagnation: AnglePipeMembersStrong.fromJson(
      json["water_stagnation"] ?? {},
    ),
    anchorBoltLooseness: AnglePipeMembersStrong.fromJson(
      json["anchor_bolt_looseness"] ?? {},
    ),
    anchorBoltsRusted: AnglePipeMembersStrong.fromJson(
      json["anchor_bolts_rusted"] ?? {},
    ),
    basePlateProperlySeated: AnglePipeMembersStrong.fromJson(
      json["base_plate_properly_seated"] ?? {},
    ),
    gapInBasePlate: AnglePipeMembersStrong.fromJson(
      json["gap_in_base_plate"] ?? {},
    ),
    groutingDamaged: AnglePipeMembersStrong.fromJson(
      json["grouting_damaged"] ?? {},
    ),
    foundationTilted: AnglePipeMembersStrong.fromJson(
      json["foundation_tilted"] ?? {},
    ),
    foundationSettlementOccurred: AnglePipeMembersStrong.fromJson(
      json["foundation_settlement_occurred"] ?? {},
    ),
    surroundingSoilLoose: AnglePipeMembersStrong.fromJson(
      json["surrounding_soil_loose"] ?? {},
    ),
  );

  Map<String, dynamic> toJson() => {
    "concrete_cracks": concreteCracks.toJson(),
    "soil_erosion_at_foundation": soilErosionAtFoundation.toJson(),
    "water_stagnation": waterStagnation.toJson(),
    "anchor_bolt_looseness": anchorBoltLooseness.toJson(),
    "anchor_bolts_rusted": anchorBoltsRusted.toJson(),
    "base_plate_properly_seated": basePlateProperlySeated.toJson(),
    "gap_in_base_plate": gapInBasePlate.toJson(),
    "grouting_damaged": groutingDamaged.toJson(),
    "foundation_tilted": foundationTilted.toJson(),
    "foundation_settlement_occurred": foundationSettlementOccurred.toJson(),
    "surrounding_soil_loose": surroundingSoilLoose.toJson(),
  };
}

class Post {
  AnglePipeMembersStrong postStraight;
  AnglePipeMembersStrong postTilted;
  AnglePipeMembersStrong bendInPost;
  AnglePipeMembersStrong crackInWeldedJoint;
  AnglePipeMembersStrong damageInWeldedJoint;
  AnglePipeMembersStrong rustPresent;
  AnglePipeMembersStrong paintPeeledOff;
  AnglePipeMembersStrong postThicknessReduced;
  AnglePipeMembersStrong spliceBoltsTight;
  AnglePipeMembersStrong spliceNutsLooseness;
  AnglePipeMembersStrong ladderSecure;
  AnglePipeMembersStrong platformStrong;

  Post({
    required this.postStraight,
    required this.postTilted,
    required this.bendInPost,
    required this.crackInWeldedJoint,
    required this.damageInWeldedJoint,
    required this.rustPresent,
    required this.paintPeeledOff,
    required this.postThicknessReduced,
    required this.spliceBoltsTight,
    required this.spliceNutsLooseness,
    required this.ladderSecure,
    required this.platformStrong,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    postStraight: AnglePipeMembersStrong.fromJson(json["post_straight"] ?? {}),
    postTilted: AnglePipeMembersStrong.fromJson(json["post_tilted"] ?? {}),
    bendInPost: AnglePipeMembersStrong.fromJson(json["bend_in_post"] ?? {}),
    crackInWeldedJoint: AnglePipeMembersStrong.fromJson(
      json["crack_in_welded_joint"] ?? {},
    ),
    damageInWeldedJoint: AnglePipeMembersStrong.fromJson(
      json["damage_in_welded_joint"] ?? {},
    ),
    rustPresent: AnglePipeMembersStrong.fromJson(json["rust_present"] ?? {}),
    paintPeeledOff: AnglePipeMembersStrong.fromJson(
      json["paint_peeled_off"] ?? {},
    ),
    postThicknessReduced: AnglePipeMembersStrong.fromJson(
      json["post_thickness_reduced"] ?? {},
    ),
    spliceBoltsTight: AnglePipeMembersStrong.fromJson(
      json["splice_bolts_tight"] ?? {},
    ),
    spliceNutsLooseness: AnglePipeMembersStrong.fromJson(
      json["splice_nuts_looseness"] ?? {},
    ),
    ladderSecure: AnglePipeMembersStrong.fromJson(json["ladder_secure"] ?? {}),
    platformStrong: AnglePipeMembersStrong.fromJson(
      json["platform_strong"] ?? {},
    ),
  );

  Map<String, dynamic> toJson() => {
    "post_straight": postStraight.toJson(),
    "post_tilted": postTilted.toJson(),
    "bend_in_post": bendInPost.toJson(),
    "crack_in_welded_joint": crackInWeldedJoint.toJson(),
    "damage_in_welded_joint": damageInWeldedJoint.toJson(),
    "rust_present": rustPresent.toJson(),
    "paint_peeled_off": paintPeeledOff.toJson(),
    "post_thickness_reduced": postThicknessReduced.toJson(),
    "splice_bolts_tight": spliceBoltsTight.toJson(),
    "splice_nuts_looseness": spliceNutsLooseness.toJson(),
    "ladder_secure": ladderSecure.toJson(),
    "platform_strong": platformStrong.toJson(),
  };
}

class GeneralInspection {
  AnglePipeMembersStrong surroundingAreaSafe;
  AnglePipeMembersStrong nearbyTreesTouchingStructure;
  AnglePipeMembersStrong obstructionsPresent;
  AnglePipeMembersStrong windDamage;
  AnglePipeMembersStrong rainDamage;
  AnglePipeMembersStrong unauthorizedModifications;
  AnglePipeMembersStrong repairsCarriedOutProperly;

  GeneralInspection({
    required this.surroundingAreaSafe,
    required this.nearbyTreesTouchingStructure,
    required this.obstructionsPresent,
    required this.windDamage,
    required this.rainDamage,
    required this.unauthorizedModifications,
    required this.repairsCarriedOutProperly,
  });

  factory GeneralInspection.fromJson(Map<String, dynamic> json) =>
      GeneralInspection(
        surroundingAreaSafe: AnglePipeMembersStrong.fromJson(
          json["surrounding_area_safe"] ?? {},
        ),
        nearbyTreesTouchingStructure: AnglePipeMembersStrong.fromJson(
          json["nearby_trees_touching_structure"] ?? {},
        ),
        obstructionsPresent: AnglePipeMembersStrong.fromJson(
          json["obstructions_present"] ?? {},
        ),
        windDamage: AnglePipeMembersStrong.fromJson(json["wind_damage"] ?? {}),
        rainDamage: AnglePipeMembersStrong.fromJson(json["rain_damage"] ?? {}),
        unauthorizedModifications: AnglePipeMembersStrong.fromJson(
          json["unauthorized_modifications"] ?? {},
        ),
        repairsCarriedOutProperly: AnglePipeMembersStrong.fromJson(
          json["repairs_carried_out_properly"] ?? {},
        ),
      );

  Map<String, dynamic> toJson() => {
    "surrounding_area_safe": surroundingAreaSafe.toJson(),
    "nearby_trees_touching_structure": nearbyTreesTouchingStructure.toJson(),
    "obstructions_present": obstructionsPresent.toJson(),
    "wind_damage": windDamage.toJson(),
    "rain_damage": rainDamage.toJson(),
    "unauthorized_modifications": unauthorizedModifications.toJson(),
    "repairs_carried_out_properly": repairsCarriedOutProperly.toJson(),
  };
}

class GeoLocation {
  double latitude;
  double longitude;

  GeoLocation({required this.latitude, required this.longitude});

  factory GeoLocation.fromJson(Map<String, dynamic> json) => GeoLocation(
    latitude: (json["latitude"] ?? 0).toDouble(),
    longitude: (json["longitude"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
  };
}

class InspectionMetrics {
  int totalQuestions;
  int yesCount;
  int noCount;
  int unansweredCount;
  int averageYesRatio;

  InspectionMetrics({
    required this.totalQuestions,
    required this.yesCount,
    required this.noCount,
    required this.unansweredCount,
    required this.averageYesRatio,
  });

  factory InspectionMetrics.fromJson(Map<String, dynamic> json) =>
      InspectionMetrics(
        totalQuestions: json["total_questions"] ?? 0,
        yesCount: json["yes_count"] ?? 0,
        noCount: json["no_count"] ?? 0,
        unansweredCount: json["unanswered_count"] ?? 0,
        averageYesRatio: json["average_yes_ratio"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "total_questions": totalQuestions,
    "yes_count": yesCount,
    "no_count": noCount,
    "unanswered_count": unansweredCount,
    "average_yes_ratio": averageYesRatio,
  };
}
