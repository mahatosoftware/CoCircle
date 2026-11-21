// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_location_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemberLocationModel {

 String get userId; String get name; String? get photoUrl; double get latitude; double get longitude; double get heading; double get speed; double get accuracy; int? get battery; bool get online; DateTime get lastUpdated; String? get vehicleId; String? get destinationId; String get sharingStatus;// 'sharing', 'paused', 'offline'
 bool get isEmergency; String? get vehicleName;
/// Create a copy of MemberLocationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberLocationModelCopyWith<MemberLocationModel> get copyWith => _$MemberLocationModelCopyWithImpl<MemberLocationModel>(this as MemberLocationModel, _$identity);

  /// Serializes this MemberLocationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberLocationModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.battery, battery) || other.battery == battery)&&(identical(other.online, online) || other.online == online)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.destinationId, destinationId) || other.destinationId == destinationId)&&(identical(other.sharingStatus, sharingStatus) || other.sharingStatus == sharingStatus)&&(identical(other.isEmergency, isEmergency) || other.isEmergency == isEmergency)&&(identical(other.vehicleName, vehicleName) || other.vehicleName == vehicleName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,photoUrl,latitude,longitude,heading,speed,accuracy,battery,online,lastUpdated,vehicleId,destinationId,sharingStatus,isEmergency,vehicleName);

@override
String toString() {
  return 'MemberLocationModel(userId: $userId, name: $name, photoUrl: $photoUrl, latitude: $latitude, longitude: $longitude, heading: $heading, speed: $speed, accuracy: $accuracy, battery: $battery, online: $online, lastUpdated: $lastUpdated, vehicleId: $vehicleId, destinationId: $destinationId, sharingStatus: $sharingStatus, isEmergency: $isEmergency, vehicleName: $vehicleName)';
}


}

/// @nodoc
abstract mixin class $MemberLocationModelCopyWith<$Res>  {
  factory $MemberLocationModelCopyWith(MemberLocationModel value, $Res Function(MemberLocationModel) _then) = _$MemberLocationModelCopyWithImpl;
@useResult
$Res call({
 String userId, String name, String? photoUrl, double latitude, double longitude, double heading, double speed, double accuracy, int? battery, bool online, DateTime lastUpdated, String? vehicleId, String? destinationId, String sharingStatus, bool isEmergency, String? vehicleName
});




}
/// @nodoc
class _$MemberLocationModelCopyWithImpl<$Res>
    implements $MemberLocationModelCopyWith<$Res> {
  _$MemberLocationModelCopyWithImpl(this._self, this._then);

  final MemberLocationModel _self;
  final $Res Function(MemberLocationModel) _then;

/// Create a copy of MemberLocationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? name = null,Object? photoUrl = freezed,Object? latitude = null,Object? longitude = null,Object? heading = null,Object? speed = null,Object? accuracy = null,Object? battery = freezed,Object? online = null,Object? lastUpdated = null,Object? vehicleId = freezed,Object? destinationId = freezed,Object? sharingStatus = null,Object? isEmergency = null,Object? vehicleName = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,heading: null == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,battery: freezed == battery ? _self.battery : battery // ignore: cast_nullable_to_non_nullable
as int?,online: null == online ? _self.online : online // ignore: cast_nullable_to_non_nullable
as bool,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String?,destinationId: freezed == destinationId ? _self.destinationId : destinationId // ignore: cast_nullable_to_non_nullable
as String?,sharingStatus: null == sharingStatus ? _self.sharingStatus : sharingStatus // ignore: cast_nullable_to_non_nullable
as String,isEmergency: null == isEmergency ? _self.isEmergency : isEmergency // ignore: cast_nullable_to_non_nullable
as bool,vehicleName: freezed == vehicleName ? _self.vehicleName : vehicleName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberLocationModel].
extension MemberLocationModelPatterns on MemberLocationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberLocationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberLocationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberLocationModel value)  $default,){
final _that = this;
switch (_that) {
case _MemberLocationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberLocationModel value)?  $default,){
final _that = this;
switch (_that) {
case _MemberLocationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String name,  String? photoUrl,  double latitude,  double longitude,  double heading,  double speed,  double accuracy,  int? battery,  bool online,  DateTime lastUpdated,  String? vehicleId,  String? destinationId,  String sharingStatus,  bool isEmergency,  String? vehicleName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberLocationModel() when $default != null:
return $default(_that.userId,_that.name,_that.photoUrl,_that.latitude,_that.longitude,_that.heading,_that.speed,_that.accuracy,_that.battery,_that.online,_that.lastUpdated,_that.vehicleId,_that.destinationId,_that.sharingStatus,_that.isEmergency,_that.vehicleName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String name,  String? photoUrl,  double latitude,  double longitude,  double heading,  double speed,  double accuracy,  int? battery,  bool online,  DateTime lastUpdated,  String? vehicleId,  String? destinationId,  String sharingStatus,  bool isEmergency,  String? vehicleName)  $default,) {final _that = this;
switch (_that) {
case _MemberLocationModel():
return $default(_that.userId,_that.name,_that.photoUrl,_that.latitude,_that.longitude,_that.heading,_that.speed,_that.accuracy,_that.battery,_that.online,_that.lastUpdated,_that.vehicleId,_that.destinationId,_that.sharingStatus,_that.isEmergency,_that.vehicleName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String name,  String? photoUrl,  double latitude,  double longitude,  double heading,  double speed,  double accuracy,  int? battery,  bool online,  DateTime lastUpdated,  String? vehicleId,  String? destinationId,  String sharingStatus,  bool isEmergency,  String? vehicleName)?  $default,) {final _that = this;
switch (_that) {
case _MemberLocationModel() when $default != null:
return $default(_that.userId,_that.name,_that.photoUrl,_that.latitude,_that.longitude,_that.heading,_that.speed,_that.accuracy,_that.battery,_that.online,_that.lastUpdated,_that.vehicleId,_that.destinationId,_that.sharingStatus,_that.isEmergency,_that.vehicleName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberLocationModel implements MemberLocationModel {
  const _MemberLocationModel({required this.userId, required this.name, this.photoUrl, required this.latitude, required this.longitude, this.heading = 0.0, this.speed = 0.0, this.accuracy = 0.0, this.battery, this.online = false, required this.lastUpdated, this.vehicleId, this.destinationId, this.sharingStatus = 'sharing', this.isEmergency = false, this.vehicleName});
  factory _MemberLocationModel.fromJson(Map<String, dynamic> json) => _$MemberLocationModelFromJson(json);

@override final  String userId;
@override final  String name;
@override final  String? photoUrl;
@override final  double latitude;
@override final  double longitude;
@override@JsonKey() final  double heading;
@override@JsonKey() final  double speed;
@override@JsonKey() final  double accuracy;
@override final  int? battery;
@override@JsonKey() final  bool online;
@override final  DateTime lastUpdated;
@override final  String? vehicleId;
@override final  String? destinationId;
@override@JsonKey() final  String sharingStatus;
// 'sharing', 'paused', 'offline'
@override@JsonKey() final  bool isEmergency;
@override final  String? vehicleName;

/// Create a copy of MemberLocationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberLocationModelCopyWith<_MemberLocationModel> get copyWith => __$MemberLocationModelCopyWithImpl<_MemberLocationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberLocationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberLocationModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.battery, battery) || other.battery == battery)&&(identical(other.online, online) || other.online == online)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.destinationId, destinationId) || other.destinationId == destinationId)&&(identical(other.sharingStatus, sharingStatus) || other.sharingStatus == sharingStatus)&&(identical(other.isEmergency, isEmergency) || other.isEmergency == isEmergency)&&(identical(other.vehicleName, vehicleName) || other.vehicleName == vehicleName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,photoUrl,latitude,longitude,heading,speed,accuracy,battery,online,lastUpdated,vehicleId,destinationId,sharingStatus,isEmergency,vehicleName);

@override
String toString() {
  return 'MemberLocationModel(userId: $userId, name: $name, photoUrl: $photoUrl, latitude: $latitude, longitude: $longitude, heading: $heading, speed: $speed, accuracy: $accuracy, battery: $battery, online: $online, lastUpdated: $lastUpdated, vehicleId: $vehicleId, destinationId: $destinationId, sharingStatus: $sharingStatus, isEmergency: $isEmergency, vehicleName: $vehicleName)';
}


}

/// @nodoc
abstract mixin class _$MemberLocationModelCopyWith<$Res> implements $MemberLocationModelCopyWith<$Res> {
  factory _$MemberLocationModelCopyWith(_MemberLocationModel value, $Res Function(_MemberLocationModel) _then) = __$MemberLocationModelCopyWithImpl;
@override @useResult
$Res call({
 String userId, String name, String? photoUrl, double latitude, double longitude, double heading, double speed, double accuracy, int? battery, bool online, DateTime lastUpdated, String? vehicleId, String? destinationId, String sharingStatus, bool isEmergency, String? vehicleName
});




}
/// @nodoc
class __$MemberLocationModelCopyWithImpl<$Res>
    implements _$MemberLocationModelCopyWith<$Res> {
  __$MemberLocationModelCopyWithImpl(this._self, this._then);

  final _MemberLocationModel _self;
  final $Res Function(_MemberLocationModel) _then;

/// Create a copy of MemberLocationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? name = null,Object? photoUrl = freezed,Object? latitude = null,Object? longitude = null,Object? heading = null,Object? speed = null,Object? accuracy = null,Object? battery = freezed,Object? online = null,Object? lastUpdated = null,Object? vehicleId = freezed,Object? destinationId = freezed,Object? sharingStatus = null,Object? isEmergency = null,Object? vehicleName = freezed,}) {
  return _then(_MemberLocationModel(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,heading: null == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,battery: freezed == battery ? _self.battery : battery // ignore: cast_nullable_to_non_nullable
as int?,online: null == online ? _self.online : online // ignore: cast_nullable_to_non_nullable
as bool,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String?,destinationId: freezed == destinationId ? _self.destinationId : destinationId // ignore: cast_nullable_to_non_nullable
as String?,sharingStatus: null == sharingStatus ? _self.sharingStatus : sharingStatus // ignore: cast_nullable_to_non_nullable
as String,isEmergency: null == isEmergency ? _self.isEmergency : isEmergency // ignore: cast_nullable_to_non_nullable
as bool,vehicleName: freezed == vehicleName ? _self.vehicleName : vehicleName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
