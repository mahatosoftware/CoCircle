// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_preferences_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationPreferencesModel {

 bool get expensesEnabled; bool get tripRemindersEnabled; bool get taskRemindersEnabled; bool get pollRemindersEnabled; bool get quietHoursEnabled; bool get hideAmountsOnLockScreen; List<String> get mutedTrips; List<String> get mutedCircles;
/// Create a copy of NotificationPreferencesModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPreferencesModelCopyWith<NotificationPreferencesModel> get copyWith => _$NotificationPreferencesModelCopyWithImpl<NotificationPreferencesModel>(this as NotificationPreferencesModel, _$identity);

  /// Serializes this NotificationPreferencesModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPreferencesModel&&(identical(other.expensesEnabled, expensesEnabled) || other.expensesEnabled == expensesEnabled)&&(identical(other.tripRemindersEnabled, tripRemindersEnabled) || other.tripRemindersEnabled == tripRemindersEnabled)&&(identical(other.taskRemindersEnabled, taskRemindersEnabled) || other.taskRemindersEnabled == taskRemindersEnabled)&&(identical(other.pollRemindersEnabled, pollRemindersEnabled) || other.pollRemindersEnabled == pollRemindersEnabled)&&(identical(other.quietHoursEnabled, quietHoursEnabled) || other.quietHoursEnabled == quietHoursEnabled)&&(identical(other.hideAmountsOnLockScreen, hideAmountsOnLockScreen) || other.hideAmountsOnLockScreen == hideAmountsOnLockScreen)&&const DeepCollectionEquality().equals(other.mutedTrips, mutedTrips)&&const DeepCollectionEquality().equals(other.mutedCircles, mutedCircles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,expensesEnabled,tripRemindersEnabled,taskRemindersEnabled,pollRemindersEnabled,quietHoursEnabled,hideAmountsOnLockScreen,const DeepCollectionEquality().hash(mutedTrips),const DeepCollectionEquality().hash(mutedCircles));

@override
String toString() {
  return 'NotificationPreferencesModel(expensesEnabled: $expensesEnabled, tripRemindersEnabled: $tripRemindersEnabled, taskRemindersEnabled: $taskRemindersEnabled, pollRemindersEnabled: $pollRemindersEnabled, quietHoursEnabled: $quietHoursEnabled, hideAmountsOnLockScreen: $hideAmountsOnLockScreen, mutedTrips: $mutedTrips, mutedCircles: $mutedCircles)';
}


}

/// @nodoc
abstract mixin class $NotificationPreferencesModelCopyWith<$Res>  {
  factory $NotificationPreferencesModelCopyWith(NotificationPreferencesModel value, $Res Function(NotificationPreferencesModel) _then) = _$NotificationPreferencesModelCopyWithImpl;
@useResult
$Res call({
 bool expensesEnabled, bool tripRemindersEnabled, bool taskRemindersEnabled, bool pollRemindersEnabled, bool quietHoursEnabled, bool hideAmountsOnLockScreen, List<String> mutedTrips, List<String> mutedCircles
});




}
/// @nodoc
class _$NotificationPreferencesModelCopyWithImpl<$Res>
    implements $NotificationPreferencesModelCopyWith<$Res> {
  _$NotificationPreferencesModelCopyWithImpl(this._self, this._then);

  final NotificationPreferencesModel _self;
  final $Res Function(NotificationPreferencesModel) _then;

/// Create a copy of NotificationPreferencesModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? expensesEnabled = null,Object? tripRemindersEnabled = null,Object? taskRemindersEnabled = null,Object? pollRemindersEnabled = null,Object? quietHoursEnabled = null,Object? hideAmountsOnLockScreen = null,Object? mutedTrips = null,Object? mutedCircles = null,}) {
  return _then(_self.copyWith(
expensesEnabled: null == expensesEnabled ? _self.expensesEnabled : expensesEnabled // ignore: cast_nullable_to_non_nullable
as bool,tripRemindersEnabled: null == tripRemindersEnabled ? _self.tripRemindersEnabled : tripRemindersEnabled // ignore: cast_nullable_to_non_nullable
as bool,taskRemindersEnabled: null == taskRemindersEnabled ? _self.taskRemindersEnabled : taskRemindersEnabled // ignore: cast_nullable_to_non_nullable
as bool,pollRemindersEnabled: null == pollRemindersEnabled ? _self.pollRemindersEnabled : pollRemindersEnabled // ignore: cast_nullable_to_non_nullable
as bool,quietHoursEnabled: null == quietHoursEnabled ? _self.quietHoursEnabled : quietHoursEnabled // ignore: cast_nullable_to_non_nullable
as bool,hideAmountsOnLockScreen: null == hideAmountsOnLockScreen ? _self.hideAmountsOnLockScreen : hideAmountsOnLockScreen // ignore: cast_nullable_to_non_nullable
as bool,mutedTrips: null == mutedTrips ? _self.mutedTrips : mutedTrips // ignore: cast_nullable_to_non_nullable
as List<String>,mutedCircles: null == mutedCircles ? _self.mutedCircles : mutedCircles // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPreferencesModel].
extension NotificationPreferencesModelPatterns on NotificationPreferencesModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPreferencesModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPreferencesModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPreferencesModel value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferencesModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPreferencesModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferencesModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool expensesEnabled,  bool tripRemindersEnabled,  bool taskRemindersEnabled,  bool pollRemindersEnabled,  bool quietHoursEnabled,  bool hideAmountsOnLockScreen,  List<String> mutedTrips,  List<String> mutedCircles)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPreferencesModel() when $default != null:
return $default(_that.expensesEnabled,_that.tripRemindersEnabled,_that.taskRemindersEnabled,_that.pollRemindersEnabled,_that.quietHoursEnabled,_that.hideAmountsOnLockScreen,_that.mutedTrips,_that.mutedCircles);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool expensesEnabled,  bool tripRemindersEnabled,  bool taskRemindersEnabled,  bool pollRemindersEnabled,  bool quietHoursEnabled,  bool hideAmountsOnLockScreen,  List<String> mutedTrips,  List<String> mutedCircles)  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferencesModel():
return $default(_that.expensesEnabled,_that.tripRemindersEnabled,_that.taskRemindersEnabled,_that.pollRemindersEnabled,_that.quietHoursEnabled,_that.hideAmountsOnLockScreen,_that.mutedTrips,_that.mutedCircles);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool expensesEnabled,  bool tripRemindersEnabled,  bool taskRemindersEnabled,  bool pollRemindersEnabled,  bool quietHoursEnabled,  bool hideAmountsOnLockScreen,  List<String> mutedTrips,  List<String> mutedCircles)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferencesModel() when $default != null:
return $default(_that.expensesEnabled,_that.tripRemindersEnabled,_that.taskRemindersEnabled,_that.pollRemindersEnabled,_that.quietHoursEnabled,_that.hideAmountsOnLockScreen,_that.mutedTrips,_that.mutedCircles);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPreferencesModel extends NotificationPreferencesModel {
  const _NotificationPreferencesModel({this.expensesEnabled = true, this.tripRemindersEnabled = true, this.taskRemindersEnabled = true, this.pollRemindersEnabled = true, this.quietHoursEnabled = true, this.hideAmountsOnLockScreen = false, final  List<String> mutedTrips = const [], final  List<String> mutedCircles = const []}): _mutedTrips = mutedTrips,_mutedCircles = mutedCircles,super._();
  factory _NotificationPreferencesModel.fromJson(Map<String, dynamic> json) => _$NotificationPreferencesModelFromJson(json);

@override@JsonKey() final  bool expensesEnabled;
@override@JsonKey() final  bool tripRemindersEnabled;
@override@JsonKey() final  bool taskRemindersEnabled;
@override@JsonKey() final  bool pollRemindersEnabled;
@override@JsonKey() final  bool quietHoursEnabled;
@override@JsonKey() final  bool hideAmountsOnLockScreen;
 final  List<String> _mutedTrips;
@override@JsonKey() List<String> get mutedTrips {
  if (_mutedTrips is EqualUnmodifiableListView) return _mutedTrips;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mutedTrips);
}

 final  List<String> _mutedCircles;
@override@JsonKey() List<String> get mutedCircles {
  if (_mutedCircles is EqualUnmodifiableListView) return _mutedCircles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mutedCircles);
}


/// Create a copy of NotificationPreferencesModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPreferencesModelCopyWith<_NotificationPreferencesModel> get copyWith => __$NotificationPreferencesModelCopyWithImpl<_NotificationPreferencesModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationPreferencesModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPreferencesModel&&(identical(other.expensesEnabled, expensesEnabled) || other.expensesEnabled == expensesEnabled)&&(identical(other.tripRemindersEnabled, tripRemindersEnabled) || other.tripRemindersEnabled == tripRemindersEnabled)&&(identical(other.taskRemindersEnabled, taskRemindersEnabled) || other.taskRemindersEnabled == taskRemindersEnabled)&&(identical(other.pollRemindersEnabled, pollRemindersEnabled) || other.pollRemindersEnabled == pollRemindersEnabled)&&(identical(other.quietHoursEnabled, quietHoursEnabled) || other.quietHoursEnabled == quietHoursEnabled)&&(identical(other.hideAmountsOnLockScreen, hideAmountsOnLockScreen) || other.hideAmountsOnLockScreen == hideAmountsOnLockScreen)&&const DeepCollectionEquality().equals(other._mutedTrips, _mutedTrips)&&const DeepCollectionEquality().equals(other._mutedCircles, _mutedCircles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,expensesEnabled,tripRemindersEnabled,taskRemindersEnabled,pollRemindersEnabled,quietHoursEnabled,hideAmountsOnLockScreen,const DeepCollectionEquality().hash(_mutedTrips),const DeepCollectionEquality().hash(_mutedCircles));

@override
String toString() {
  return 'NotificationPreferencesModel(expensesEnabled: $expensesEnabled, tripRemindersEnabled: $tripRemindersEnabled, taskRemindersEnabled: $taskRemindersEnabled, pollRemindersEnabled: $pollRemindersEnabled, quietHoursEnabled: $quietHoursEnabled, hideAmountsOnLockScreen: $hideAmountsOnLockScreen, mutedTrips: $mutedTrips, mutedCircles: $mutedCircles)';
}


}

/// @nodoc
abstract mixin class _$NotificationPreferencesModelCopyWith<$Res> implements $NotificationPreferencesModelCopyWith<$Res> {
  factory _$NotificationPreferencesModelCopyWith(_NotificationPreferencesModel value, $Res Function(_NotificationPreferencesModel) _then) = __$NotificationPreferencesModelCopyWithImpl;
@override @useResult
$Res call({
 bool expensesEnabled, bool tripRemindersEnabled, bool taskRemindersEnabled, bool pollRemindersEnabled, bool quietHoursEnabled, bool hideAmountsOnLockScreen, List<String> mutedTrips, List<String> mutedCircles
});




}
/// @nodoc
class __$NotificationPreferencesModelCopyWithImpl<$Res>
    implements _$NotificationPreferencesModelCopyWith<$Res> {
  __$NotificationPreferencesModelCopyWithImpl(this._self, this._then);

  final _NotificationPreferencesModel _self;
  final $Res Function(_NotificationPreferencesModel) _then;

/// Create a copy of NotificationPreferencesModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? expensesEnabled = null,Object? tripRemindersEnabled = null,Object? taskRemindersEnabled = null,Object? pollRemindersEnabled = null,Object? quietHoursEnabled = null,Object? hideAmountsOnLockScreen = null,Object? mutedTrips = null,Object? mutedCircles = null,}) {
  return _then(_NotificationPreferencesModel(
expensesEnabled: null == expensesEnabled ? _self.expensesEnabled : expensesEnabled // ignore: cast_nullable_to_non_nullable
as bool,tripRemindersEnabled: null == tripRemindersEnabled ? _self.tripRemindersEnabled : tripRemindersEnabled // ignore: cast_nullable_to_non_nullable
as bool,taskRemindersEnabled: null == taskRemindersEnabled ? _self.taskRemindersEnabled : taskRemindersEnabled // ignore: cast_nullable_to_non_nullable
as bool,pollRemindersEnabled: null == pollRemindersEnabled ? _self.pollRemindersEnabled : pollRemindersEnabled // ignore: cast_nullable_to_non_nullable
as bool,quietHoursEnabled: null == quietHoursEnabled ? _self.quietHoursEnabled : quietHoursEnabled // ignore: cast_nullable_to_non_nullable
as bool,hideAmountsOnLockScreen: null == hideAmountsOnLockScreen ? _self.hideAmountsOnLockScreen : hideAmountsOnLockScreen // ignore: cast_nullable_to_non_nullable
as bool,mutedTrips: null == mutedTrips ? _self._mutedTrips : mutedTrips // ignore: cast_nullable_to_non_nullable
as List<String>,mutedCircles: null == mutedCircles ? _self._mutedCircles : mutedCircles // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
