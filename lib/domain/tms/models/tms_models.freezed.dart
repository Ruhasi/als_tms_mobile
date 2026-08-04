// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tms_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUser {

 String get name; String get initials; UserRole get role; String get company;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.name, name) || other.name == name)&&(identical(other.initials, initials) || other.initials == initials)&&(identical(other.role, role) || other.role == role)&&(identical(other.company, company) || other.company == company));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,initials,role,company);

@override
String toString() {
  return 'AppUser(name: $name, initials: $initials, role: $role, company: $company)';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String name, String initials, UserRole role, String company
});




}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? initials = null,Object? role = null,Object? company = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,initials: null == initials ? _self.initials : initials // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String initials,  UserRole role,  String company)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.name,_that.initials,_that.role,_that.company);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String initials,  UserRole role,  String company)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.name,_that.initials,_that.role,_that.company);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String initials,  UserRole role,  String company)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.name,_that.initials,_that.role,_that.company);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUser implements AppUser {
  const _AppUser({required this.name, required this.initials, required this.role, required this.company});
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

@override final  String name;
@override final  String initials;
@override final  UserRole role;
@override final  String company;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.name, name) || other.name == name)&&(identical(other.initials, initials) || other.initials == initials)&&(identical(other.role, role) || other.role == role)&&(identical(other.company, company) || other.company == company));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,initials,role,company);

@override
String toString() {
  return 'AppUser(name: $name, initials: $initials, role: $role, company: $company)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String name, String initials, UserRole role, String company
});




}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? initials = null,Object? role = null,Object? company = null,}) {
  return _then(_AppUser(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,initials: null == initials ? _self.initials : initials // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TmsOption {

 String get id; String get title; String get subtitle; bool get isAuto; bool get isLocked;
/// Create a copy of TmsOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TmsOptionCopyWith<TmsOption> get copyWith => _$TmsOptionCopyWithImpl<TmsOption>(this as TmsOption, _$identity);

  /// Serializes this TmsOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TmsOption&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.isAuto, isAuto) || other.isAuto == isAuto)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,subtitle,isAuto,isLocked);

@override
String toString() {
  return 'TmsOption(id: $id, title: $title, subtitle: $subtitle, isAuto: $isAuto, isLocked: $isLocked)';
}


}

/// @nodoc
abstract mixin class $TmsOptionCopyWith<$Res>  {
  factory $TmsOptionCopyWith(TmsOption value, $Res Function(TmsOption) _then) = _$TmsOptionCopyWithImpl;
@useResult
$Res call({
 String id, String title, String subtitle, bool isAuto, bool isLocked
});




}
/// @nodoc
class _$TmsOptionCopyWithImpl<$Res>
    implements $TmsOptionCopyWith<$Res> {
  _$TmsOptionCopyWithImpl(this._self, this._then);

  final TmsOption _self;
  final $Res Function(TmsOption) _then;

/// Create a copy of TmsOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? subtitle = null,Object? isAuto = null,Object? isLocked = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,isAuto: null == isAuto ? _self.isAuto : isAuto // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TmsOption].
extension TmsOptionPatterns on TmsOption {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TmsOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TmsOption() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TmsOption value)  $default,){
final _that = this;
switch (_that) {
case _TmsOption():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TmsOption value)?  $default,){
final _that = this;
switch (_that) {
case _TmsOption() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String subtitle,  bool isAuto,  bool isLocked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TmsOption() when $default != null:
return $default(_that.id,_that.title,_that.subtitle,_that.isAuto,_that.isLocked);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String subtitle,  bool isAuto,  bool isLocked)  $default,) {final _that = this;
switch (_that) {
case _TmsOption():
return $default(_that.id,_that.title,_that.subtitle,_that.isAuto,_that.isLocked);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String subtitle,  bool isAuto,  bool isLocked)?  $default,) {final _that = this;
switch (_that) {
case _TmsOption() when $default != null:
return $default(_that.id,_that.title,_that.subtitle,_that.isAuto,_that.isLocked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TmsOption implements TmsOption {
  const _TmsOption({required this.id, required this.title, required this.subtitle, this.isAuto = false, this.isLocked = false});
  factory _TmsOption.fromJson(Map<String, dynamic> json) => _$TmsOptionFromJson(json);

@override final  String id;
@override final  String title;
@override final  String subtitle;
@override@JsonKey() final  bool isAuto;
@override@JsonKey() final  bool isLocked;

/// Create a copy of TmsOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TmsOptionCopyWith<_TmsOption> get copyWith => __$TmsOptionCopyWithImpl<_TmsOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TmsOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TmsOption&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.isAuto, isAuto) || other.isAuto == isAuto)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,subtitle,isAuto,isLocked);

@override
String toString() {
  return 'TmsOption(id: $id, title: $title, subtitle: $subtitle, isAuto: $isAuto, isLocked: $isLocked)';
}


}

/// @nodoc
abstract mixin class _$TmsOptionCopyWith<$Res> implements $TmsOptionCopyWith<$Res> {
  factory _$TmsOptionCopyWith(_TmsOption value, $Res Function(_TmsOption) _then) = __$TmsOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String subtitle, bool isAuto, bool isLocked
});




}
/// @nodoc
class __$TmsOptionCopyWithImpl<$Res>
    implements _$TmsOptionCopyWith<$Res> {
  __$TmsOptionCopyWithImpl(this._self, this._then);

  final _TmsOption _self;
  final $Res Function(_TmsOption) _then;

/// Create a copy of TmsOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? subtitle = null,Object? isAuto = null,Object? isLocked = null,}) {
  return _then(_TmsOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,isAuto: null == isAuto ? _self.isAuto : isAuto // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$JobComment {

 String get author; String get message; DateTime get createdAt; bool get isDispatcher;
/// Create a copy of JobComment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobCommentCopyWith<JobComment> get copyWith => _$JobCommentCopyWithImpl<JobComment>(this as JobComment, _$identity);

  /// Serializes this JobComment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobComment&&(identical(other.author, author) || other.author == author)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isDispatcher, isDispatcher) || other.isDispatcher == isDispatcher));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,author,message,createdAt,isDispatcher);

@override
String toString() {
  return 'JobComment(author: $author, message: $message, createdAt: $createdAt, isDispatcher: $isDispatcher)';
}


}

/// @nodoc
abstract mixin class $JobCommentCopyWith<$Res>  {
  factory $JobCommentCopyWith(JobComment value, $Res Function(JobComment) _then) = _$JobCommentCopyWithImpl;
@useResult
$Res call({
 String author, String message, DateTime createdAt, bool isDispatcher
});




}
/// @nodoc
class _$JobCommentCopyWithImpl<$Res>
    implements $JobCommentCopyWith<$Res> {
  _$JobCommentCopyWithImpl(this._self, this._then);

  final JobComment _self;
  final $Res Function(JobComment) _then;

/// Create a copy of JobComment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? author = null,Object? message = null,Object? createdAt = null,Object? isDispatcher = null,}) {
  return _then(_self.copyWith(
author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDispatcher: null == isDispatcher ? _self.isDispatcher : isDispatcher // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [JobComment].
extension JobCommentPatterns on JobComment {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobComment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobComment() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobComment value)  $default,){
final _that = this;
switch (_that) {
case _JobComment():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobComment value)?  $default,){
final _that = this;
switch (_that) {
case _JobComment() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String author,  String message,  DateTime createdAt,  bool isDispatcher)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobComment() when $default != null:
return $default(_that.author,_that.message,_that.createdAt,_that.isDispatcher);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String author,  String message,  DateTime createdAt,  bool isDispatcher)  $default,) {final _that = this;
switch (_that) {
case _JobComment():
return $default(_that.author,_that.message,_that.createdAt,_that.isDispatcher);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String author,  String message,  DateTime createdAt,  bool isDispatcher)?  $default,) {final _that = this;
switch (_that) {
case _JobComment() when $default != null:
return $default(_that.author,_that.message,_that.createdAt,_that.isDispatcher);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobComment implements JobComment {
  const _JobComment({required this.author, required this.message, required this.createdAt, this.isDispatcher = false});
  factory _JobComment.fromJson(Map<String, dynamic> json) => _$JobCommentFromJson(json);

@override final  String author;
@override final  String message;
@override final  DateTime createdAt;
@override@JsonKey() final  bool isDispatcher;

/// Create a copy of JobComment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobCommentCopyWith<_JobComment> get copyWith => __$JobCommentCopyWithImpl<_JobComment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobCommentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobComment&&(identical(other.author, author) || other.author == author)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isDispatcher, isDispatcher) || other.isDispatcher == isDispatcher));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,author,message,createdAt,isDispatcher);

@override
String toString() {
  return 'JobComment(author: $author, message: $message, createdAt: $createdAt, isDispatcher: $isDispatcher)';
}


}

/// @nodoc
abstract mixin class _$JobCommentCopyWith<$Res> implements $JobCommentCopyWith<$Res> {
  factory _$JobCommentCopyWith(_JobComment value, $Res Function(_JobComment) _then) = __$JobCommentCopyWithImpl;
@override @useResult
$Res call({
 String author, String message, DateTime createdAt, bool isDispatcher
});




}
/// @nodoc
class __$JobCommentCopyWithImpl<$Res>
    implements _$JobCommentCopyWith<$Res> {
  __$JobCommentCopyWithImpl(this._self, this._then);

  final _JobComment _self;
  final $Res Function(_JobComment) _then;

/// Create a copy of JobComment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? author = null,Object? message = null,Object? createdAt = null,Object? isDispatcher = null,}) {
  return _then(_JobComment(
author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDispatcher: null == isDispatcher ? _self.isDispatcher : isDispatcher // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TmsJob {

 String get id; JobStatus get status; String get pickup; String get destination; String get pickupTime; String get deliveryTime; String get customer; String get shipper; String get invoiceTo; String get provider; String get vehicle; String get driver; bool get isFlagged; String get flagReason; List<JobComment> get comments;
/// Create a copy of TmsJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TmsJobCopyWith<TmsJob> get copyWith => _$TmsJobCopyWithImpl<TmsJob>(this as TmsJob, _$identity);

  /// Serializes this TmsJob to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TmsJob&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.pickup, pickup) || other.pickup == pickup)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.pickupTime, pickupTime) || other.pickupTime == pickupTime)&&(identical(other.deliveryTime, deliveryTime) || other.deliveryTime == deliveryTime)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.shipper, shipper) || other.shipper == shipper)&&(identical(other.invoiceTo, invoiceTo) || other.invoiceTo == invoiceTo)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle)&&(identical(other.driver, driver) || other.driver == driver)&&(identical(other.isFlagged, isFlagged) || other.isFlagged == isFlagged)&&(identical(other.flagReason, flagReason) || other.flagReason == flagReason)&&const DeepCollectionEquality().equals(other.comments, comments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,pickup,destination,pickupTime,deliveryTime,customer,shipper,invoiceTo,provider,vehicle,driver,isFlagged,flagReason,const DeepCollectionEquality().hash(comments));

@override
String toString() {
  return 'TmsJob(id: $id, status: $status, pickup: $pickup, destination: $destination, pickupTime: $pickupTime, deliveryTime: $deliveryTime, customer: $customer, shipper: $shipper, invoiceTo: $invoiceTo, provider: $provider, vehicle: $vehicle, driver: $driver, isFlagged: $isFlagged, flagReason: $flagReason, comments: $comments)';
}


}

/// @nodoc
abstract mixin class $TmsJobCopyWith<$Res>  {
  factory $TmsJobCopyWith(TmsJob value, $Res Function(TmsJob) _then) = _$TmsJobCopyWithImpl;
@useResult
$Res call({
 String id, JobStatus status, String pickup, String destination, String pickupTime, String deliveryTime, String customer, String shipper, String invoiceTo, String provider, String vehicle, String driver, bool isFlagged, String flagReason, List<JobComment> comments
});




}
/// @nodoc
class _$TmsJobCopyWithImpl<$Res>
    implements $TmsJobCopyWith<$Res> {
  _$TmsJobCopyWithImpl(this._self, this._then);

  final TmsJob _self;
  final $Res Function(TmsJob) _then;

/// Create a copy of TmsJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? pickup = null,Object? destination = null,Object? pickupTime = null,Object? deliveryTime = null,Object? customer = null,Object? shipper = null,Object? invoiceTo = null,Object? provider = null,Object? vehicle = null,Object? driver = null,Object? isFlagged = null,Object? flagReason = null,Object? comments = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JobStatus,pickup: null == pickup ? _self.pickup : pickup // ignore: cast_nullable_to_non_nullable
as String,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,pickupTime: null == pickupTime ? _self.pickupTime : pickupTime // ignore: cast_nullable_to_non_nullable
as String,deliveryTime: null == deliveryTime ? _self.deliveryTime : deliveryTime // ignore: cast_nullable_to_non_nullable
as String,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as String,shipper: null == shipper ? _self.shipper : shipper // ignore: cast_nullable_to_non_nullable
as String,invoiceTo: null == invoiceTo ? _self.invoiceTo : invoiceTo // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,vehicle: null == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as String,driver: null == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as String,isFlagged: null == isFlagged ? _self.isFlagged : isFlagged // ignore: cast_nullable_to_non_nullable
as bool,flagReason: null == flagReason ? _self.flagReason : flagReason // ignore: cast_nullable_to_non_nullable
as String,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as List<JobComment>,
  ));
}

}


/// Adds pattern-matching-related methods to [TmsJob].
extension TmsJobPatterns on TmsJob {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TmsJob value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TmsJob() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TmsJob value)  $default,){
final _that = this;
switch (_that) {
case _TmsJob():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TmsJob value)?  $default,){
final _that = this;
switch (_that) {
case _TmsJob() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  JobStatus status,  String pickup,  String destination,  String pickupTime,  String deliveryTime,  String customer,  String shipper,  String invoiceTo,  String provider,  String vehicle,  String driver,  bool isFlagged,  String flagReason,  List<JobComment> comments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TmsJob() when $default != null:
return $default(_that.id,_that.status,_that.pickup,_that.destination,_that.pickupTime,_that.deliveryTime,_that.customer,_that.shipper,_that.invoiceTo,_that.provider,_that.vehicle,_that.driver,_that.isFlagged,_that.flagReason,_that.comments);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  JobStatus status,  String pickup,  String destination,  String pickupTime,  String deliveryTime,  String customer,  String shipper,  String invoiceTo,  String provider,  String vehicle,  String driver,  bool isFlagged,  String flagReason,  List<JobComment> comments)  $default,) {final _that = this;
switch (_that) {
case _TmsJob():
return $default(_that.id,_that.status,_that.pickup,_that.destination,_that.pickupTime,_that.deliveryTime,_that.customer,_that.shipper,_that.invoiceTo,_that.provider,_that.vehicle,_that.driver,_that.isFlagged,_that.flagReason,_that.comments);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  JobStatus status,  String pickup,  String destination,  String pickupTime,  String deliveryTime,  String customer,  String shipper,  String invoiceTo,  String provider,  String vehicle,  String driver,  bool isFlagged,  String flagReason,  List<JobComment> comments)?  $default,) {final _that = this;
switch (_that) {
case _TmsJob() when $default != null:
return $default(_that.id,_that.status,_that.pickup,_that.destination,_that.pickupTime,_that.deliveryTime,_that.customer,_that.shipper,_that.invoiceTo,_that.provider,_that.vehicle,_that.driver,_that.isFlagged,_that.flagReason,_that.comments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TmsJob implements TmsJob {
  const _TmsJob({required this.id, required this.status, required this.pickup, required this.destination, required this.pickupTime, required this.deliveryTime, required this.customer, required this.shipper, required this.invoiceTo, required this.provider, required this.vehicle, required this.driver, this.isFlagged = false, this.flagReason = '', final  List<JobComment> comments = const <JobComment>[]}): _comments = comments;
  factory _TmsJob.fromJson(Map<String, dynamic> json) => _$TmsJobFromJson(json);

@override final  String id;
@override final  JobStatus status;
@override final  String pickup;
@override final  String destination;
@override final  String pickupTime;
@override final  String deliveryTime;
@override final  String customer;
@override final  String shipper;
@override final  String invoiceTo;
@override final  String provider;
@override final  String vehicle;
@override final  String driver;
@override@JsonKey() final  bool isFlagged;
@override@JsonKey() final  String flagReason;
 final  List<JobComment> _comments;
@override@JsonKey() List<JobComment> get comments {
  if (_comments is EqualUnmodifiableListView) return _comments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comments);
}


/// Create a copy of TmsJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TmsJobCopyWith<_TmsJob> get copyWith => __$TmsJobCopyWithImpl<_TmsJob>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TmsJobToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TmsJob&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.pickup, pickup) || other.pickup == pickup)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.pickupTime, pickupTime) || other.pickupTime == pickupTime)&&(identical(other.deliveryTime, deliveryTime) || other.deliveryTime == deliveryTime)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.shipper, shipper) || other.shipper == shipper)&&(identical(other.invoiceTo, invoiceTo) || other.invoiceTo == invoiceTo)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle)&&(identical(other.driver, driver) || other.driver == driver)&&(identical(other.isFlagged, isFlagged) || other.isFlagged == isFlagged)&&(identical(other.flagReason, flagReason) || other.flagReason == flagReason)&&const DeepCollectionEquality().equals(other._comments, _comments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,pickup,destination,pickupTime,deliveryTime,customer,shipper,invoiceTo,provider,vehicle,driver,isFlagged,flagReason,const DeepCollectionEquality().hash(_comments));

@override
String toString() {
  return 'TmsJob(id: $id, status: $status, pickup: $pickup, destination: $destination, pickupTime: $pickupTime, deliveryTime: $deliveryTime, customer: $customer, shipper: $shipper, invoiceTo: $invoiceTo, provider: $provider, vehicle: $vehicle, driver: $driver, isFlagged: $isFlagged, flagReason: $flagReason, comments: $comments)';
}


}

/// @nodoc
abstract mixin class _$TmsJobCopyWith<$Res> implements $TmsJobCopyWith<$Res> {
  factory _$TmsJobCopyWith(_TmsJob value, $Res Function(_TmsJob) _then) = __$TmsJobCopyWithImpl;
@override @useResult
$Res call({
 String id, JobStatus status, String pickup, String destination, String pickupTime, String deliveryTime, String customer, String shipper, String invoiceTo, String provider, String vehicle, String driver, bool isFlagged, String flagReason, List<JobComment> comments
});




}
/// @nodoc
class __$TmsJobCopyWithImpl<$Res>
    implements _$TmsJobCopyWith<$Res> {
  __$TmsJobCopyWithImpl(this._self, this._then);

  final _TmsJob _self;
  final $Res Function(_TmsJob) _then;

/// Create a copy of TmsJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? pickup = null,Object? destination = null,Object? pickupTime = null,Object? deliveryTime = null,Object? customer = null,Object? shipper = null,Object? invoiceTo = null,Object? provider = null,Object? vehicle = null,Object? driver = null,Object? isFlagged = null,Object? flagReason = null,Object? comments = null,}) {
  return _then(_TmsJob(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JobStatus,pickup: null == pickup ? _self.pickup : pickup // ignore: cast_nullable_to_non_nullable
as String,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,pickupTime: null == pickupTime ? _self.pickupTime : pickupTime // ignore: cast_nullable_to_non_nullable
as String,deliveryTime: null == deliveryTime ? _self.deliveryTime : deliveryTime // ignore: cast_nullable_to_non_nullable
as String,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as String,shipper: null == shipper ? _self.shipper : shipper // ignore: cast_nullable_to_non_nullable
as String,invoiceTo: null == invoiceTo ? _self.invoiceTo : invoiceTo // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,vehicle: null == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as String,driver: null == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as String,isFlagged: null == isFlagged ? _self.isFlagged : isFlagged // ignore: cast_nullable_to_non_nullable
as bool,flagReason: null == flagReason ? _self.flagReason : flagReason // ignore: cast_nullable_to_non_nullable
as String,comments: null == comments ? _self._comments : comments // ignore: cast_nullable_to_non_nullable
as List<JobComment>,
  ));
}


}


/// @nodoc
mixin _$DashboardData {

 AppUser get user; int get openJobs; int get deliveredThisMonth; int get flaggedJobs; List<TmsJob> get jobs;
/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardDataCopyWith<DashboardData> get copyWith => _$DashboardDataCopyWithImpl<DashboardData>(this as DashboardData, _$identity);

  /// Serializes this DashboardData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardData&&(identical(other.user, user) || other.user == user)&&(identical(other.openJobs, openJobs) || other.openJobs == openJobs)&&(identical(other.deliveredThisMonth, deliveredThisMonth) || other.deliveredThisMonth == deliveredThisMonth)&&(identical(other.flaggedJobs, flaggedJobs) || other.flaggedJobs == flaggedJobs)&&const DeepCollectionEquality().equals(other.jobs, jobs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,openJobs,deliveredThisMonth,flaggedJobs,const DeepCollectionEquality().hash(jobs));

@override
String toString() {
  return 'DashboardData(user: $user, openJobs: $openJobs, deliveredThisMonth: $deliveredThisMonth, flaggedJobs: $flaggedJobs, jobs: $jobs)';
}


}

/// @nodoc
abstract mixin class $DashboardDataCopyWith<$Res>  {
  factory $DashboardDataCopyWith(DashboardData value, $Res Function(DashboardData) _then) = _$DashboardDataCopyWithImpl;
@useResult
$Res call({
 AppUser user, int openJobs, int deliveredThisMonth, int flaggedJobs, List<TmsJob> jobs
});


$AppUserCopyWith<$Res> get user;

}
/// @nodoc
class _$DashboardDataCopyWithImpl<$Res>
    implements $DashboardDataCopyWith<$Res> {
  _$DashboardDataCopyWithImpl(this._self, this._then);

  final DashboardData _self;
  final $Res Function(DashboardData) _then;

/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? openJobs = null,Object? deliveredThisMonth = null,Object? flaggedJobs = null,Object? jobs = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AppUser,openJobs: null == openJobs ? _self.openJobs : openJobs // ignore: cast_nullable_to_non_nullable
as int,deliveredThisMonth: null == deliveredThisMonth ? _self.deliveredThisMonth : deliveredThisMonth // ignore: cast_nullable_to_non_nullable
as int,flaggedJobs: null == flaggedJobs ? _self.flaggedJobs : flaggedJobs // ignore: cast_nullable_to_non_nullable
as int,jobs: null == jobs ? _self.jobs : jobs // ignore: cast_nullable_to_non_nullable
as List<TmsJob>,
  ));
}
/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUserCopyWith<$Res> get user {
  
  return $AppUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [DashboardData].
extension DashboardDataPatterns on DashboardData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardData value)  $default,){
final _that = this;
switch (_that) {
case _DashboardData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardData value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppUser user,  int openJobs,  int deliveredThisMonth,  int flaggedJobs,  List<TmsJob> jobs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
return $default(_that.user,_that.openJobs,_that.deliveredThisMonth,_that.flaggedJobs,_that.jobs);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppUser user,  int openJobs,  int deliveredThisMonth,  int flaggedJobs,  List<TmsJob> jobs)  $default,) {final _that = this;
switch (_that) {
case _DashboardData():
return $default(_that.user,_that.openJobs,_that.deliveredThisMonth,_that.flaggedJobs,_that.jobs);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppUser user,  int openJobs,  int deliveredThisMonth,  int flaggedJobs,  List<TmsJob> jobs)?  $default,) {final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
return $default(_that.user,_that.openJobs,_that.deliveredThisMonth,_that.flaggedJobs,_that.jobs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardData implements DashboardData {
  const _DashboardData({required this.user, required this.openJobs, required this.deliveredThisMonth, required this.flaggedJobs, required final  List<TmsJob> jobs}): _jobs = jobs;
  factory _DashboardData.fromJson(Map<String, dynamic> json) => _$DashboardDataFromJson(json);

@override final  AppUser user;
@override final  int openJobs;
@override final  int deliveredThisMonth;
@override final  int flaggedJobs;
 final  List<TmsJob> _jobs;
@override List<TmsJob> get jobs {
  if (_jobs is EqualUnmodifiableListView) return _jobs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_jobs);
}


/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardDataCopyWith<_DashboardData> get copyWith => __$DashboardDataCopyWithImpl<_DashboardData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardData&&(identical(other.user, user) || other.user == user)&&(identical(other.openJobs, openJobs) || other.openJobs == openJobs)&&(identical(other.deliveredThisMonth, deliveredThisMonth) || other.deliveredThisMonth == deliveredThisMonth)&&(identical(other.flaggedJobs, flaggedJobs) || other.flaggedJobs == flaggedJobs)&&const DeepCollectionEquality().equals(other._jobs, _jobs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,openJobs,deliveredThisMonth,flaggedJobs,const DeepCollectionEquality().hash(_jobs));

@override
String toString() {
  return 'DashboardData(user: $user, openJobs: $openJobs, deliveredThisMonth: $deliveredThisMonth, flaggedJobs: $flaggedJobs, jobs: $jobs)';
}


}

/// @nodoc
abstract mixin class _$DashboardDataCopyWith<$Res> implements $DashboardDataCopyWith<$Res> {
  factory _$DashboardDataCopyWith(_DashboardData value, $Res Function(_DashboardData) _then) = __$DashboardDataCopyWithImpl;
@override @useResult
$Res call({
 AppUser user, int openJobs, int deliveredThisMonth, int flaggedJobs, List<TmsJob> jobs
});


@override $AppUserCopyWith<$Res> get user;

}
/// @nodoc
class __$DashboardDataCopyWithImpl<$Res>
    implements _$DashboardDataCopyWith<$Res> {
  __$DashboardDataCopyWithImpl(this._self, this._then);

  final _DashboardData _self;
  final $Res Function(_DashboardData) _then;

/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? openJobs = null,Object? deliveredThisMonth = null,Object? flaggedJobs = null,Object? jobs = null,}) {
  return _then(_DashboardData(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AppUser,openJobs: null == openJobs ? _self.openJobs : openJobs // ignore: cast_nullable_to_non_nullable
as int,deliveredThisMonth: null == deliveredThisMonth ? _self.deliveredThisMonth : deliveredThisMonth // ignore: cast_nullable_to_non_nullable
as int,flaggedJobs: null == flaggedJobs ? _self.flaggedJobs : flaggedJobs // ignore: cast_nullable_to_non_nullable
as int,jobs: null == jobs ? _self._jobs : jobs // ignore: cast_nullable_to_non_nullable
as List<TmsJob>,
  ));
}

/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUserCopyWith<$Res> get user {
  
  return $AppUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
