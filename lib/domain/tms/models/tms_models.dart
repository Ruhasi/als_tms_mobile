import 'package:freezed_annotation/freezed_annotation.dart';

part 'tms_models.freezed.dart';
part 'tms_models.g.dart';

enum UserRole { owner, transporter, broker }

enum JobStatus { requested, accepted, inTransit, delivered, cancelled }

@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String name,
    required String initials,
    required UserRole role,
    required String company,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}

@freezed
abstract class TmsOption with _$TmsOption {
  const factory TmsOption({
    required String id,
    required String title,
    required String subtitle,
    @Default(false) bool isAuto,
    @Default(false) bool isLocked,
  }) = _TmsOption;

  factory TmsOption.fromJson(Map<String, dynamic> json) =>
      _$TmsOptionFromJson(json);
}

@freezed
abstract class JobComment with _$JobComment {
  const factory JobComment({
    required String author,
    required String message,
    required DateTime createdAt,
    @Default(false) bool isDispatcher,
  }) = _JobComment;

  factory JobComment.fromJson(Map<String, dynamic> json) =>
      _$JobCommentFromJson(json);
}

@freezed
abstract class TmsJob with _$TmsJob {
  const factory TmsJob({
    required String id,
    required JobStatus status,
    required String pickup,
    required String destination,
    required String pickupTime,
    required String deliveryTime,
    required String customer,
    required String shipper,
    required String invoiceTo,
    required String provider,
    required String vehicle,
    required String driver,
    @Default(false) bool isFlagged,
    @Default('') String flagReason,
    @Default(<JobComment>[]) List<JobComment> comments,
  }) = _TmsJob;

  factory TmsJob.fromJson(Map<String, dynamic> json) => _$TmsJobFromJson(json);
}

@freezed
abstract class DashboardData with _$DashboardData {
  const factory DashboardData({
    required AppUser user,
    required int openJobs,
    required int deliveredThisMonth,
    required int flaggedJobs,
    required List<TmsJob> jobs,
  }) = _DashboardData;

  factory DashboardData.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataFromJson(json);
}
