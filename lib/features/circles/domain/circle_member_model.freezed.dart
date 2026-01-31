// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'circle_member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CircleMemberModel {

 String get uid; String get circleId; String get displayName; String? get photoUrl; CircleRole get role; DateTime get joinedAt;
/// Create a copy of CircleMemberModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CircleMemberModelCopyWith<CircleMemberModel> get copyWith => _$CircleMemberModelCopyWithImpl<CircleMemberModel>(this as CircleMemberModel, _$identity);

  /// Serializes this CircleMemberModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CircleMemberModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,circleId,displayName,photoUrl,role,joinedAt);

@override
String toString() {
  return 'CircleMemberModel(uid: $uid, circleId: $circleId, displayName: $displayName, photoUrl: $photoUrl, role: $role, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class $CircleMemberModelCopyWith<$Res>  {
  factory $CircleMemberModelCopyWith(CircleMemberModel value, $Res Function(CircleMemberModel) _then) = _$CircleMemberModelCopyWithImpl;
@useResult
$Res call({
 String uid, String circleId, String displayName, String? photoUrl, CircleRole role, DateTime joinedAt
});




}
/// @nodoc
class _$CircleMemberModelCopyWithImpl<$Res>
    implements $CircleMemberModelCopyWith<$Res> {
  _$CircleMemberModelCopyWithImpl(this._self, this._then);

  final CircleMemberModel _self;
  final $Res Function(CircleMemberModel) _then;

/// Create a copy of CircleMemberModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? circleId = null,Object? displayName = null,Object? photoUrl = freezed,Object? role = null,Object? joinedAt = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as CircleRole,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CircleMemberModel].
extension CircleMemberModelPatterns on CircleMemberModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CircleMemberModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CircleMemberModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CircleMemberModel value)  $default,){
final _that = this;
switch (_that) {
case _CircleMemberModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CircleMemberModel value)?  $default,){
final _that = this;
switch (_that) {
case _CircleMemberModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String circleId,  String displayName,  String? photoUrl,  CircleRole role,  DateTime joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CircleMemberModel() when $default != null:
return $default(_that.uid,_that.circleId,_that.displayName,_that.photoUrl,_that.role,_that.joinedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String circleId,  String displayName,  String? photoUrl,  CircleRole role,  DateTime joinedAt)  $default,) {final _that = this;
switch (_that) {
case _CircleMemberModel():
return $default(_that.uid,_that.circleId,_that.displayName,_that.photoUrl,_that.role,_that.joinedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String circleId,  String displayName,  String? photoUrl,  CircleRole role,  DateTime joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _CircleMemberModel() when $default != null:
return $default(_that.uid,_that.circleId,_that.displayName,_that.photoUrl,_that.role,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CircleMemberModel implements CircleMemberModel {
  const _CircleMemberModel({required this.uid, required this.circleId, required this.displayName, this.photoUrl, required this.role, required this.joinedAt});
  factory _CircleMemberModel.fromJson(Map<String, dynamic> json) => _$CircleMemberModelFromJson(json);

@override final  String uid;
@override final  String circleId;
@override final  String displayName;
@override final  String? photoUrl;
@override final  CircleRole role;
@override final  DateTime joinedAt;

/// Create a copy of CircleMemberModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CircleMemberModelCopyWith<_CircleMemberModel> get copyWith => __$CircleMemberModelCopyWithImpl<_CircleMemberModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CircleMemberModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CircleMemberModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,circleId,displayName,photoUrl,role,joinedAt);

@override
String toString() {
  return 'CircleMemberModel(uid: $uid, circleId: $circleId, displayName: $displayName, photoUrl: $photoUrl, role: $role, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$CircleMemberModelCopyWith<$Res> implements $CircleMemberModelCopyWith<$Res> {
  factory _$CircleMemberModelCopyWith(_CircleMemberModel value, $Res Function(_CircleMemberModel) _then) = __$CircleMemberModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String circleId, String displayName, String? photoUrl, CircleRole role, DateTime joinedAt
});




}
/// @nodoc
class __$CircleMemberModelCopyWithImpl<$Res>
    implements _$CircleMemberModelCopyWith<$Res> {
  __$CircleMemberModelCopyWithImpl(this._self, this._then);

  final _CircleMemberModel _self;
  final $Res Function(_CircleMemberModel) _then;

/// Create a copy of CircleMemberModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? circleId = null,Object? displayName = null,Object? photoUrl = freezed,Object? role = null,Object? joinedAt = null,}) {
  return _then(_CircleMemberModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as CircleRole,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
