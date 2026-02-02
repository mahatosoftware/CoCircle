// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationModel {

 String get id; String get title; String get body; NotificationType get type; String get targetPath; DateTime get timestamp; bool get isRead; String get recipientUid; String get senderUid; String? get senderName; String? get tripId; String? get expenseId;
/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationModelCopyWith<NotificationModel> get copyWith => _$NotificationModelCopyWithImpl<NotificationModel>(this as NotificationModel, _$identity);

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.type, type) || other.type == type)&&(identical(other.targetPath, targetPath) || other.targetPath == targetPath)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.recipientUid, recipientUid) || other.recipientUid == recipientUid)&&(identical(other.senderUid, senderUid) || other.senderUid == senderUid)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.expenseId, expenseId) || other.expenseId == expenseId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,body,type,targetPath,timestamp,isRead,recipientUid,senderUid,senderName,tripId,expenseId);

@override
String toString() {
  return 'NotificationModel(id: $id, title: $title, body: $body, type: $type, targetPath: $targetPath, timestamp: $timestamp, isRead: $isRead, recipientUid: $recipientUid, senderUid: $senderUid, senderName: $senderName, tripId: $tripId, expenseId: $expenseId)';
}


}

/// @nodoc
abstract mixin class $NotificationModelCopyWith<$Res>  {
  factory $NotificationModelCopyWith(NotificationModel value, $Res Function(NotificationModel) _then) = _$NotificationModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String body, NotificationType type, String targetPath, DateTime timestamp, bool isRead, String recipientUid, String senderUid, String? senderName, String? tripId, String? expenseId
});




}
/// @nodoc
class _$NotificationModelCopyWithImpl<$Res>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._self, this._then);

  final NotificationModel _self;
  final $Res Function(NotificationModel) _then;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? body = null,Object? type = null,Object? targetPath = null,Object? timestamp = null,Object? isRead = null,Object? recipientUid = null,Object? senderUid = null,Object? senderName = freezed,Object? tripId = freezed,Object? expenseId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,targetPath: null == targetPath ? _self.targetPath : targetPath // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,recipientUid: null == recipientUid ? _self.recipientUid : recipientUid // ignore: cast_nullable_to_non_nullable
as String,senderUid: null == senderUid ? _self.senderUid : senderUid // ignore: cast_nullable_to_non_nullable
as String,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,tripId: freezed == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String?,expenseId: freezed == expenseId ? _self.expenseId : expenseId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationModel].
extension NotificationModelPatterns on NotificationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationModel value)  $default,){
final _that = this;
switch (_that) {
case _NotificationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String body,  NotificationType type,  String targetPath,  DateTime timestamp,  bool isRead,  String recipientUid,  String senderUid,  String? senderName,  String? tripId,  String? expenseId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.type,_that.targetPath,_that.timestamp,_that.isRead,_that.recipientUid,_that.senderUid,_that.senderName,_that.tripId,_that.expenseId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String body,  NotificationType type,  String targetPath,  DateTime timestamp,  bool isRead,  String recipientUid,  String senderUid,  String? senderName,  String? tripId,  String? expenseId)  $default,) {final _that = this;
switch (_that) {
case _NotificationModel():
return $default(_that.id,_that.title,_that.body,_that.type,_that.targetPath,_that.timestamp,_that.isRead,_that.recipientUid,_that.senderUid,_that.senderName,_that.tripId,_that.expenseId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String body,  NotificationType type,  String targetPath,  DateTime timestamp,  bool isRead,  String recipientUid,  String senderUid,  String? senderName,  String? tripId,  String? expenseId)?  $default,) {final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.type,_that.targetPath,_that.timestamp,_that.isRead,_that.recipientUid,_that.senderUid,_that.senderName,_that.tripId,_that.expenseId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationModel implements NotificationModel {
  const _NotificationModel({required this.id, required this.title, required this.body, required this.type, required this.targetPath, required this.timestamp, this.isRead = false, required this.recipientUid, required this.senderUid, this.senderName, this.tripId, this.expenseId});
  factory _NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String body;
@override final  NotificationType type;
@override final  String targetPath;
@override final  DateTime timestamp;
@override@JsonKey() final  bool isRead;
@override final  String recipientUid;
@override final  String senderUid;
@override final  String? senderName;
@override final  String? tripId;
@override final  String? expenseId;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationModelCopyWith<_NotificationModel> get copyWith => __$NotificationModelCopyWithImpl<_NotificationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.type, type) || other.type == type)&&(identical(other.targetPath, targetPath) || other.targetPath == targetPath)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.recipientUid, recipientUid) || other.recipientUid == recipientUid)&&(identical(other.senderUid, senderUid) || other.senderUid == senderUid)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.expenseId, expenseId) || other.expenseId == expenseId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,body,type,targetPath,timestamp,isRead,recipientUid,senderUid,senderName,tripId,expenseId);

@override
String toString() {
  return 'NotificationModel(id: $id, title: $title, body: $body, type: $type, targetPath: $targetPath, timestamp: $timestamp, isRead: $isRead, recipientUid: $recipientUid, senderUid: $senderUid, senderName: $senderName, tripId: $tripId, expenseId: $expenseId)';
}


}

/// @nodoc
abstract mixin class _$NotificationModelCopyWith<$Res> implements $NotificationModelCopyWith<$Res> {
  factory _$NotificationModelCopyWith(_NotificationModel value, $Res Function(_NotificationModel) _then) = __$NotificationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String body, NotificationType type, String targetPath, DateTime timestamp, bool isRead, String recipientUid, String senderUid, String? senderName, String? tripId, String? expenseId
});




}
/// @nodoc
class __$NotificationModelCopyWithImpl<$Res>
    implements _$NotificationModelCopyWith<$Res> {
  __$NotificationModelCopyWithImpl(this._self, this._then);

  final _NotificationModel _self;
  final $Res Function(_NotificationModel) _then;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? body = null,Object? type = null,Object? targetPath = null,Object? timestamp = null,Object? isRead = null,Object? recipientUid = null,Object? senderUid = null,Object? senderName = freezed,Object? tripId = freezed,Object? expenseId = freezed,}) {
  return _then(_NotificationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,targetPath: null == targetPath ? _self.targetPath : targetPath // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,recipientUid: null == recipientUid ? _self.recipientUid : recipientUid // ignore: cast_nullable_to_non_nullable
as String,senderUid: null == senderUid ? _self.senderUid : senderUid // ignore: cast_nullable_to_non_nullable
as String,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,tripId: freezed == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String?,expenseId: freezed == expenseId ? _self.expenseId : expenseId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
