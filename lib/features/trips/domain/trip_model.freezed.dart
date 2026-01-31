// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TripModel {

 String get id; String get circleId; String get name; TripType get type;@TimestampConverter() DateTime? get startDate;@TimestampConverter() DateTime? get endDate; String? get location; String get createdBy;@TimestampConverter() DateTime get createdAt; bool get isActive;// Read-optimized summary
 double get totalExpenses;
/// Create a copy of TripModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TripModelCopyWith<TripModel> get copyWith => _$TripModelCopyWithImpl<TripModel>(this as TripModel, _$identity);

  /// Serializes this TripModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TripModel&&(identical(other.id, id) || other.id == id)&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.location, location) || other.location == location)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.totalExpenses, totalExpenses) || other.totalExpenses == totalExpenses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,circleId,name,type,startDate,endDate,location,createdBy,createdAt,isActive,totalExpenses);

@override
String toString() {
  return 'TripModel(id: $id, circleId: $circleId, name: $name, type: $type, startDate: $startDate, endDate: $endDate, location: $location, createdBy: $createdBy, createdAt: $createdAt, isActive: $isActive, totalExpenses: $totalExpenses)';
}


}

/// @nodoc
abstract mixin class $TripModelCopyWith<$Res>  {
  factory $TripModelCopyWith(TripModel value, $Res Function(TripModel) _then) = _$TripModelCopyWithImpl;
@useResult
$Res call({
 String id, String circleId, String name, TripType type,@TimestampConverter() DateTime? startDate,@TimestampConverter() DateTime? endDate, String? location, String createdBy,@TimestampConverter() DateTime createdAt, bool isActive, double totalExpenses
});




}
/// @nodoc
class _$TripModelCopyWithImpl<$Res>
    implements $TripModelCopyWith<$Res> {
  _$TripModelCopyWithImpl(this._self, this._then);

  final TripModel _self;
  final $Res Function(TripModel) _then;

/// Create a copy of TripModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? circleId = null,Object? name = null,Object? type = null,Object? startDate = freezed,Object? endDate = freezed,Object? location = freezed,Object? createdBy = null,Object? createdAt = null,Object? isActive = null,Object? totalExpenses = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TripType,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,totalExpenses: null == totalExpenses ? _self.totalExpenses : totalExpenses // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TripModel].
extension TripModelPatterns on TripModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TripModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TripModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TripModel value)  $default,){
final _that = this;
switch (_that) {
case _TripModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TripModel value)?  $default,){
final _that = this;
switch (_that) {
case _TripModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String circleId,  String name,  TripType type, @TimestampConverter()  DateTime? startDate, @TimestampConverter()  DateTime? endDate,  String? location,  String createdBy, @TimestampConverter()  DateTime createdAt,  bool isActive,  double totalExpenses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TripModel() when $default != null:
return $default(_that.id,_that.circleId,_that.name,_that.type,_that.startDate,_that.endDate,_that.location,_that.createdBy,_that.createdAt,_that.isActive,_that.totalExpenses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String circleId,  String name,  TripType type, @TimestampConverter()  DateTime? startDate, @TimestampConverter()  DateTime? endDate,  String? location,  String createdBy, @TimestampConverter()  DateTime createdAt,  bool isActive,  double totalExpenses)  $default,) {final _that = this;
switch (_that) {
case _TripModel():
return $default(_that.id,_that.circleId,_that.name,_that.type,_that.startDate,_that.endDate,_that.location,_that.createdBy,_that.createdAt,_that.isActive,_that.totalExpenses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String circleId,  String name,  TripType type, @TimestampConverter()  DateTime? startDate, @TimestampConverter()  DateTime? endDate,  String? location,  String createdBy, @TimestampConverter()  DateTime createdAt,  bool isActive,  double totalExpenses)?  $default,) {final _that = this;
switch (_that) {
case _TripModel() when $default != null:
return $default(_that.id,_that.circleId,_that.name,_that.type,_that.startDate,_that.endDate,_that.location,_that.createdBy,_that.createdAt,_that.isActive,_that.totalExpenses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TripModel implements TripModel {
  const _TripModel({required this.id, required this.circleId, required this.name, required this.type, @TimestampConverter() this.startDate, @TimestampConverter() this.endDate, this.location, required this.createdBy, @TimestampConverter() required this.createdAt, this.isActive = true, this.totalExpenses = 0.0});
  factory _TripModel.fromJson(Map<String, dynamic> json) => _$TripModelFromJson(json);

@override final  String id;
@override final  String circleId;
@override final  String name;
@override final  TripType type;
@override@TimestampConverter() final  DateTime? startDate;
@override@TimestampConverter() final  DateTime? endDate;
@override final  String? location;
@override final  String createdBy;
@override@TimestampConverter() final  DateTime createdAt;
@override@JsonKey() final  bool isActive;
// Read-optimized summary
@override@JsonKey() final  double totalExpenses;

/// Create a copy of TripModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TripModelCopyWith<_TripModel> get copyWith => __$TripModelCopyWithImpl<_TripModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TripModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TripModel&&(identical(other.id, id) || other.id == id)&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.location, location) || other.location == location)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.totalExpenses, totalExpenses) || other.totalExpenses == totalExpenses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,circleId,name,type,startDate,endDate,location,createdBy,createdAt,isActive,totalExpenses);

@override
String toString() {
  return 'TripModel(id: $id, circleId: $circleId, name: $name, type: $type, startDate: $startDate, endDate: $endDate, location: $location, createdBy: $createdBy, createdAt: $createdAt, isActive: $isActive, totalExpenses: $totalExpenses)';
}


}

/// @nodoc
abstract mixin class _$TripModelCopyWith<$Res> implements $TripModelCopyWith<$Res> {
  factory _$TripModelCopyWith(_TripModel value, $Res Function(_TripModel) _then) = __$TripModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String circleId, String name, TripType type,@TimestampConverter() DateTime? startDate,@TimestampConverter() DateTime? endDate, String? location, String createdBy,@TimestampConverter() DateTime createdAt, bool isActive, double totalExpenses
});




}
/// @nodoc
class __$TripModelCopyWithImpl<$Res>
    implements _$TripModelCopyWith<$Res> {
  __$TripModelCopyWithImpl(this._self, this._then);

  final _TripModel _self;
  final $Res Function(_TripModel) _then;

/// Create a copy of TripModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? circleId = null,Object? name = null,Object? type = null,Object? startDate = freezed,Object? endDate = freezed,Object? location = freezed,Object? createdBy = null,Object? createdAt = null,Object? isActive = null,Object? totalExpenses = null,}) {
  return _then(_TripModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TripType,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,totalExpenses: null == totalExpenses ? _self.totalExpenses : totalExpenses // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
