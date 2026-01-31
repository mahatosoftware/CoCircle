// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExpenseModel {

 String get id; String get tripId; String get title; double get amount;@TimestampConverter() DateTime get date; ExpenseCategory get category; String get payerId;// Or Map<String, double> for multiple payers? Requirement 4.4.2: Multiple payers
 Map<String, double> get payers;// uid -> amount
 Map<String, double> get splitDetails;// uid -> amount/ratio/percentage dependent on splitType (stored as calculated amount usually for simplicity, or raw?)
// Storing the calculated amount per user is safer for immutable history.
 SplitType get splitType; String? get notes; bool get isSupplemental; String get createdBy;@TimestampConverter() DateTime get createdAt;
/// Create a copy of ExpenseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseModelCopyWith<ExpenseModel> get copyWith => _$ExpenseModelCopyWithImpl<ExpenseModel>(this as ExpenseModel, _$identity);

  /// Serializes this ExpenseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.category, category) || other.category == category)&&(identical(other.payerId, payerId) || other.payerId == payerId)&&const DeepCollectionEquality().equals(other.payers, payers)&&const DeepCollectionEquality().equals(other.splitDetails, splitDetails)&&(identical(other.splitType, splitType) || other.splitType == splitType)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isSupplemental, isSupplemental) || other.isSupplemental == isSupplemental)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tripId,title,amount,date,category,payerId,const DeepCollectionEquality().hash(payers),const DeepCollectionEquality().hash(splitDetails),splitType,notes,isSupplemental,createdBy,createdAt);

@override
String toString() {
  return 'ExpenseModel(id: $id, tripId: $tripId, title: $title, amount: $amount, date: $date, category: $category, payerId: $payerId, payers: $payers, splitDetails: $splitDetails, splitType: $splitType, notes: $notes, isSupplemental: $isSupplemental, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ExpenseModelCopyWith<$Res>  {
  factory $ExpenseModelCopyWith(ExpenseModel value, $Res Function(ExpenseModel) _then) = _$ExpenseModelCopyWithImpl;
@useResult
$Res call({
 String id, String tripId, String title, double amount,@TimestampConverter() DateTime date, ExpenseCategory category, String payerId, Map<String, double> payers, Map<String, double> splitDetails, SplitType splitType, String? notes, bool isSupplemental, String createdBy,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$ExpenseModelCopyWithImpl<$Res>
    implements $ExpenseModelCopyWith<$Res> {
  _$ExpenseModelCopyWithImpl(this._self, this._then);

  final ExpenseModel _self;
  final $Res Function(ExpenseModel) _then;

/// Create a copy of ExpenseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tripId = null,Object? title = null,Object? amount = null,Object? date = null,Object? category = null,Object? payerId = null,Object? payers = null,Object? splitDetails = null,Object? splitType = null,Object? notes = freezed,Object? isSupplemental = null,Object? createdBy = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExpenseCategory,payerId: null == payerId ? _self.payerId : payerId // ignore: cast_nullable_to_non_nullable
as String,payers: null == payers ? _self.payers : payers // ignore: cast_nullable_to_non_nullable
as Map<String, double>,splitDetails: null == splitDetails ? _self.splitDetails : splitDetails // ignore: cast_nullable_to_non_nullable
as Map<String, double>,splitType: null == splitType ? _self.splitType : splitType // ignore: cast_nullable_to_non_nullable
as SplitType,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isSupplemental: null == isSupplemental ? _self.isSupplemental : isSupplemental // ignore: cast_nullable_to_non_nullable
as bool,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpenseModel].
extension ExpenseModelPatterns on ExpenseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseModel value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseModel value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tripId,  String title,  double amount, @TimestampConverter()  DateTime date,  ExpenseCategory category,  String payerId,  Map<String, double> payers,  Map<String, double> splitDetails,  SplitType splitType,  String? notes,  bool isSupplemental,  String createdBy, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseModel() when $default != null:
return $default(_that.id,_that.tripId,_that.title,_that.amount,_that.date,_that.category,_that.payerId,_that.payers,_that.splitDetails,_that.splitType,_that.notes,_that.isSupplemental,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tripId,  String title,  double amount, @TimestampConverter()  DateTime date,  ExpenseCategory category,  String payerId,  Map<String, double> payers,  Map<String, double> splitDetails,  SplitType splitType,  String? notes,  bool isSupplemental,  String createdBy, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ExpenseModel():
return $default(_that.id,_that.tripId,_that.title,_that.amount,_that.date,_that.category,_that.payerId,_that.payers,_that.splitDetails,_that.splitType,_that.notes,_that.isSupplemental,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tripId,  String title,  double amount, @TimestampConverter()  DateTime date,  ExpenseCategory category,  String payerId,  Map<String, double> payers,  Map<String, double> splitDetails,  SplitType splitType,  String? notes,  bool isSupplemental,  String createdBy, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseModel() when $default != null:
return $default(_that.id,_that.tripId,_that.title,_that.amount,_that.date,_that.category,_that.payerId,_that.payers,_that.splitDetails,_that.splitType,_that.notes,_that.isSupplemental,_that.createdBy,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpenseModel implements ExpenseModel {
  const _ExpenseModel({required this.id, required this.tripId, required this.title, required this.amount, @TimestampConverter() required this.date, required this.category, required this.payerId, required final  Map<String, double> payers, required final  Map<String, double> splitDetails, required this.splitType, this.notes, this.isSupplemental = false, required this.createdBy, @TimestampConverter() required this.createdAt}): _payers = payers,_splitDetails = splitDetails;
  factory _ExpenseModel.fromJson(Map<String, dynamic> json) => _$ExpenseModelFromJson(json);

@override final  String id;
@override final  String tripId;
@override final  String title;
@override final  double amount;
@override@TimestampConverter() final  DateTime date;
@override final  ExpenseCategory category;
@override final  String payerId;
// Or Map<String, double> for multiple payers? Requirement 4.4.2: Multiple payers
 final  Map<String, double> _payers;
// Or Map<String, double> for multiple payers? Requirement 4.4.2: Multiple payers
@override Map<String, double> get payers {
  if (_payers is EqualUnmodifiableMapView) return _payers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payers);
}

// uid -> amount
 final  Map<String, double> _splitDetails;
// uid -> amount
@override Map<String, double> get splitDetails {
  if (_splitDetails is EqualUnmodifiableMapView) return _splitDetails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_splitDetails);
}

// uid -> amount/ratio/percentage dependent on splitType (stored as calculated amount usually for simplicity, or raw?)
// Storing the calculated amount per user is safer for immutable history.
@override final  SplitType splitType;
@override final  String? notes;
@override@JsonKey() final  bool isSupplemental;
@override final  String createdBy;
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of ExpenseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseModelCopyWith<_ExpenseModel> get copyWith => __$ExpenseModelCopyWithImpl<_ExpenseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.category, category) || other.category == category)&&(identical(other.payerId, payerId) || other.payerId == payerId)&&const DeepCollectionEquality().equals(other._payers, _payers)&&const DeepCollectionEquality().equals(other._splitDetails, _splitDetails)&&(identical(other.splitType, splitType) || other.splitType == splitType)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isSupplemental, isSupplemental) || other.isSupplemental == isSupplemental)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tripId,title,amount,date,category,payerId,const DeepCollectionEquality().hash(_payers),const DeepCollectionEquality().hash(_splitDetails),splitType,notes,isSupplemental,createdBy,createdAt);

@override
String toString() {
  return 'ExpenseModel(id: $id, tripId: $tripId, title: $title, amount: $amount, date: $date, category: $category, payerId: $payerId, payers: $payers, splitDetails: $splitDetails, splitType: $splitType, notes: $notes, isSupplemental: $isSupplemental, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ExpenseModelCopyWith<$Res> implements $ExpenseModelCopyWith<$Res> {
  factory _$ExpenseModelCopyWith(_ExpenseModel value, $Res Function(_ExpenseModel) _then) = __$ExpenseModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String tripId, String title, double amount,@TimestampConverter() DateTime date, ExpenseCategory category, String payerId, Map<String, double> payers, Map<String, double> splitDetails, SplitType splitType, String? notes, bool isSupplemental, String createdBy,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$ExpenseModelCopyWithImpl<$Res>
    implements _$ExpenseModelCopyWith<$Res> {
  __$ExpenseModelCopyWithImpl(this._self, this._then);

  final _ExpenseModel _self;
  final $Res Function(_ExpenseModel) _then;

/// Create a copy of ExpenseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tripId = null,Object? title = null,Object? amount = null,Object? date = null,Object? category = null,Object? payerId = null,Object? payers = null,Object? splitDetails = null,Object? splitType = null,Object? notes = freezed,Object? isSupplemental = null,Object? createdBy = null,Object? createdAt = null,}) {
  return _then(_ExpenseModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExpenseCategory,payerId: null == payerId ? _self.payerId : payerId // ignore: cast_nullable_to_non_nullable
as String,payers: null == payers ? _self._payers : payers // ignore: cast_nullable_to_non_nullable
as Map<String, double>,splitDetails: null == splitDetails ? _self._splitDetails : splitDetails // ignore: cast_nullable_to_non_nullable
as Map<String, double>,splitType: null == splitType ? _self.splitType : splitType // ignore: cast_nullable_to_non_nullable
as SplitType,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isSupplemental: null == isSupplemental ? _self.isSupplemental : isSupplemental // ignore: cast_nullable_to_non_nullable
as bool,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
