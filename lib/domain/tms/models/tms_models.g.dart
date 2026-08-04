// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tms_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  name: json['name'] as String,
  initials: json['initials'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  company: json['company'] as String,
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'name': instance.name,
  'initials': instance.initials,
  'role': _$UserRoleEnumMap[instance.role]!,
  'company': instance.company,
};

const _$UserRoleEnumMap = {
  UserRole.owner: 'owner',
  UserRole.transporter: 'transporter',
  UserRole.broker: 'broker',
};

_TmsOption _$TmsOptionFromJson(Map<String, dynamic> json) => _TmsOption(
  id: json['id'] as String,
  title: json['title'] as String,
  subtitle: json['subtitle'] as String,
  isAuto: json['isAuto'] as bool? ?? false,
  isLocked: json['isLocked'] as bool? ?? false,
);

Map<String, dynamic> _$TmsOptionToJson(_TmsOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'isAuto': instance.isAuto,
      'isLocked': instance.isLocked,
    };

_JobComment _$JobCommentFromJson(Map<String, dynamic> json) => _JobComment(
  author: json['author'] as String,
  message: json['message'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isDispatcher: json['isDispatcher'] as bool? ?? false,
);

Map<String, dynamic> _$JobCommentToJson(_JobComment instance) =>
    <String, dynamic>{
      'author': instance.author,
      'message': instance.message,
      'createdAt': instance.createdAt.toIso8601String(),
      'isDispatcher': instance.isDispatcher,
    };

_TmsJob _$TmsJobFromJson(Map<String, dynamic> json) => _TmsJob(
  id: json['id'] as String,
  status: $enumDecode(_$JobStatusEnumMap, json['status']),
  pickup: json['pickup'] as String,
  destination: json['destination'] as String,
  pickupTime: json['pickupTime'] as String,
  deliveryTime: json['deliveryTime'] as String,
  customer: json['customer'] as String,
  shipper: json['shipper'] as String,
  invoiceTo: json['invoiceTo'] as String,
  provider: json['provider'] as String,
  vehicle: json['vehicle'] as String,
  driver: json['driver'] as String,
  isFlagged: json['isFlagged'] as bool? ?? false,
  flagReason: json['flagReason'] as String? ?? '',
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map((e) => JobComment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <JobComment>[],
);

Map<String, dynamic> _$TmsJobToJson(_TmsJob instance) => <String, dynamic>{
  'id': instance.id,
  'status': _$JobStatusEnumMap[instance.status]!,
  'pickup': instance.pickup,
  'destination': instance.destination,
  'pickupTime': instance.pickupTime,
  'deliveryTime': instance.deliveryTime,
  'customer': instance.customer,
  'shipper': instance.shipper,
  'invoiceTo': instance.invoiceTo,
  'provider': instance.provider,
  'vehicle': instance.vehicle,
  'driver': instance.driver,
  'isFlagged': instance.isFlagged,
  'flagReason': instance.flagReason,
  'comments': instance.comments,
};

const _$JobStatusEnumMap = {
  JobStatus.requested: 'requested',
  JobStatus.accepted: 'accepted',
  JobStatus.inTransit: 'inTransit',
  JobStatus.delivered: 'delivered',
  JobStatus.cancelled: 'cancelled',
};

_DashboardData _$DashboardDataFromJson(Map<String, dynamic> json) =>
    _DashboardData(
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      openJobs: (json['openJobs'] as num).toInt(),
      deliveredThisMonth: (json['deliveredThisMonth'] as num).toInt(),
      flaggedJobs: (json['flaggedJobs'] as num).toInt(),
      jobs: (json['jobs'] as List<dynamic>)
          .map((e) => TmsJob.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardDataToJson(_DashboardData instance) =>
    <String, dynamic>{
      'user': instance.user,
      'openJobs': instance.openJobs,
      'deliveredThisMonth': instance.deliveredThisMonth,
      'flaggedJobs': instance.flaggedJobs,
      'jobs': instance.jobs,
    };
