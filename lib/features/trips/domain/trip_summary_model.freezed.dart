// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_summary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TripSummaryModel {

 String get tripId; double get totalExpenses; Map<String, double> get memberBalances;// uid -> net balance
 int get latestSettlementVersion; DateTime get lastUpdated;
/// Create a copy of TripSummaryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TripSummaryModelCopyWith<TripSummaryModel> get copyWith => _$TripSummaryModelCopyWithImpl<TripSummaryModel>(this as TripSummaryModel, _$identity);

  /// Serializes this TripSummaryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TripSummaryModel&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.totalExpenses, totalExpenses) || other.totalExpenses == totalExpenses)&&const DeepCollectionEquality().equals(other.memberBalances, memberBalances)&&(identical(other.latestSettlementVersion, latestSettlementVersion) || other.latestSettlementVersion == latestSettlementVersion)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tripId,totalExpenses,const DeepCollectionEquality().hash(memberBalances),latestSettlementVersion,lastUpdated);

@override
String toString() {
  return 'TripSummaryModel(tripId: $tripId, totalExpenses: $totalExpenses, memberBalances: $memberBalances, latestSettlementVersion: $latestSettlementVersion, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class $TripSummaryModelCopyWith<$Res>  {
  factory $TripSummaryModelCopyWith(TripSummaryModel value, $Res Function(TripSummaryModel) _then) = _$TripSummaryModelCopyWithImpl;
@useResult
$Res call({
 String tripId, double totalExpenses, Map<String, double> memberBalances, int latestSettlementVersion, DateTime lastUpdated
});




}
/// @nodoc
class _$TripSummaryModelCopyWithImpl<$Res>
    implements $TripSummaryModelCopyWith<$Res> {
  _$TripSummaryModelCopyWithImpl(this._self, this._then);

  final TripSummaryModel _self;
  final $Res Function(TripSummaryModel) _then;

/// Create a copy of TripSummaryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tripId = null,Object? totalExpenses = null,Object? memberBalances = null,Object? latestSettlementVersion = null,Object? lastUpdated = null,}) {
  return _then(_self.copyWith(
tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,totalExpenses: null == totalExpenses ? _self.totalExpenses : totalExpenses // ignore: cast_nullable_to_non_nullable
as double,memberBalances: null == memberBalances ? _self.memberBalances : memberBalances // ignore: cast_nullable_to_non_nullable
as Map<String, double>,latestSettlementVersion: null == latestSettlementVersion ? _self.latestSettlementVersion : latestSettlementVersion // ignore: cast_nullable_to_non_nullable
as int,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TripSummaryModel].
extension TripSummaryModelPatterns on TripSummaryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TripSummaryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TripSummaryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TripSummaryModel value)  $default,){
final _that = this;
switch (_that) {
case _TripSummaryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TripSummaryModel value)?  $default,){
final _that = this;
switch (_that) {
case _TripSummaryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tripId,  double totalExpenses,  Map<String, double> memberBalances,  int latestSettlementVersion,  DateTime lastUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TripSummaryModel() when $default != null:
return $default(_that.tripId,_that.totalExpenses,_that.memberBalances,_that.latestSettlementVersion,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tripId,  double totalExpenses,  Map<String, double> memberBalances,  int latestSettlementVersion,  DateTime lastUpdated)  $default,) {final _that = this;
switch (_that) {
case _TripSummaryModel():
return $default(_that.tripId,_that.totalExpenses,_that.memberBalances,_that.latestSettlementVersion,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tripId,  double totalExpenses,  Map<String, double> memberBalances,  int latestSettlementVersion,  DateTime lastUpdated)?  $default,) {final _that = this;
switch (_that) {
case _TripSummaryModel() when $default != null:
return $default(_that.tripId,_that.totalExpenses,_that.memberBalances,_that.latestSettlementVersion,_that.lastUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TripSummaryModel implements TripSummaryModel {
  const _TripSummaryModel({required this.tripId, required this.totalExpenses, required final  Map<String, double> memberBalances, required this.latestSettlementVersion, required this.lastUpdated}): _memberBalances = memberBalances;
  factory _TripSummaryModel.fromJson(Map<String, dynamic> json) => _$TripSummaryModelFromJson(json);

@override final  String tripId;
@override final  double totalExpenses;
 final  Map<String, double> _memberBalances;
@override Map<String, double> get memberBalances {
  if (_memberBalances is EqualUnmodifiableMapView) return _memberBalances;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_memberBalances);
}

// uid -> net balance
@override final  int latestSettlementVersion;
@override final  DateTime lastUpdated;

/// Create a copy of TripSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TripSummaryModelCopyWith<_TripSummaryModel> get copyWith => __$TripSummaryModelCopyWithImpl<_TripSummaryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TripSummaryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TripSummaryModel&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.totalExpenses, totalExpenses) || other.totalExpenses == totalExpenses)&&const DeepCollectionEquality().equals(other._memberBalances, _memberBalances)&&(identical(other.latestSettlementVersion, latestSettlementVersion) || other.latestSettlementVersion == latestSettlementVersion)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tripId,totalExpenses,const DeepCollectionEquality().hash(_memberBalances),latestSettlementVersion,lastUpdated);

@override
String toString() {
  return 'TripSummaryModel(tripId: $tripId, totalExpenses: $totalExpenses, memberBalances: $memberBalances, latestSettlementVersion: $latestSettlementVersion, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class _$TripSummaryModelCopyWith<$Res> implements $TripSummaryModelCopyWith<$Res> {
  factory _$TripSummaryModelCopyWith(_TripSummaryModel value, $Res Function(_TripSummaryModel) _then) = __$TripSummaryModelCopyWithImpl;
@override @useResult
$Res call({
 String tripId, double totalExpenses, Map<String, double> memberBalances, int latestSettlementVersion, DateTime lastUpdated
});




}
/// @nodoc
class __$TripSummaryModelCopyWithImpl<$Res>
    implements _$TripSummaryModelCopyWith<$Res> {
  __$TripSummaryModelCopyWithImpl(this._self, this._then);

  final _TripSummaryModel _self;
  final $Res Function(_TripSummaryModel) _then;

/// Create a copy of TripSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tripId = null,Object? totalExpenses = null,Object? memberBalances = null,Object? latestSettlementVersion = null,Object? lastUpdated = null,}) {
  return _then(_TripSummaryModel(
tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,totalExpenses: null == totalExpenses ? _self.totalExpenses : totalExpenses // ignore: cast_nullable_to_non_nullable
as double,memberBalances: null == memberBalances ? _self._memberBalances : memberBalances // ignore: cast_nullable_to_non_nullable
as Map<String, double>,latestSettlementVersion: null == latestSettlementVersion ? _self.latestSettlementVersion : latestSettlementVersion // ignore: cast_nullable_to_non_nullable
as int,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
