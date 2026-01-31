// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settlement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SettlementModel {

 String get id; String get tripId; int get version;@TimestampConverter() DateTime get timestamp; Map<String, double> get balances;// uid -> net balance
 List<SettlementTransaction> get transactions;// suggested transfers
 List<String> get expenseIdsIncluded;// Immutability
 String get createdBy;
/// Create a copy of SettlementModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettlementModelCopyWith<SettlementModel> get copyWith => _$SettlementModelCopyWithImpl<SettlementModel>(this as SettlementModel, _$identity);

  /// Serializes this SettlementModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettlementModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.version, version) || other.version == version)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other.balances, balances)&&const DeepCollectionEquality().equals(other.transactions, transactions)&&const DeepCollectionEquality().equals(other.expenseIdsIncluded, expenseIdsIncluded)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tripId,version,timestamp,const DeepCollectionEquality().hash(balances),const DeepCollectionEquality().hash(transactions),const DeepCollectionEquality().hash(expenseIdsIncluded),createdBy);

@override
String toString() {
  return 'SettlementModel(id: $id, tripId: $tripId, version: $version, timestamp: $timestamp, balances: $balances, transactions: $transactions, expenseIdsIncluded: $expenseIdsIncluded, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class $SettlementModelCopyWith<$Res>  {
  factory $SettlementModelCopyWith(SettlementModel value, $Res Function(SettlementModel) _then) = _$SettlementModelCopyWithImpl;
@useResult
$Res call({
 String id, String tripId, int version,@TimestampConverter() DateTime timestamp, Map<String, double> balances, List<SettlementTransaction> transactions, List<String> expenseIdsIncluded, String createdBy
});




}
/// @nodoc
class _$SettlementModelCopyWithImpl<$Res>
    implements $SettlementModelCopyWith<$Res> {
  _$SettlementModelCopyWithImpl(this._self, this._then);

  final SettlementModel _self;
  final $Res Function(SettlementModel) _then;

/// Create a copy of SettlementModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tripId = null,Object? version = null,Object? timestamp = null,Object? balances = null,Object? transactions = null,Object? expenseIdsIncluded = null,Object? createdBy = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,balances: null == balances ? _self.balances : balances // ignore: cast_nullable_to_non_nullable
as Map<String, double>,transactions: null == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<SettlementTransaction>,expenseIdsIncluded: null == expenseIdsIncluded ? _self.expenseIdsIncluded : expenseIdsIncluded // ignore: cast_nullable_to_non_nullable
as List<String>,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SettlementModel].
extension SettlementModelPatterns on SettlementModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettlementModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettlementModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettlementModel value)  $default,){
final _that = this;
switch (_that) {
case _SettlementModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettlementModel value)?  $default,){
final _that = this;
switch (_that) {
case _SettlementModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tripId,  int version, @TimestampConverter()  DateTime timestamp,  Map<String, double> balances,  List<SettlementTransaction> transactions,  List<String> expenseIdsIncluded,  String createdBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettlementModel() when $default != null:
return $default(_that.id,_that.tripId,_that.version,_that.timestamp,_that.balances,_that.transactions,_that.expenseIdsIncluded,_that.createdBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tripId,  int version, @TimestampConverter()  DateTime timestamp,  Map<String, double> balances,  List<SettlementTransaction> transactions,  List<String> expenseIdsIncluded,  String createdBy)  $default,) {final _that = this;
switch (_that) {
case _SettlementModel():
return $default(_that.id,_that.tripId,_that.version,_that.timestamp,_that.balances,_that.transactions,_that.expenseIdsIncluded,_that.createdBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tripId,  int version, @TimestampConverter()  DateTime timestamp,  Map<String, double> balances,  List<SettlementTransaction> transactions,  List<String> expenseIdsIncluded,  String createdBy)?  $default,) {final _that = this;
switch (_that) {
case _SettlementModel() when $default != null:
return $default(_that.id,_that.tripId,_that.version,_that.timestamp,_that.balances,_that.transactions,_that.expenseIdsIncluded,_that.createdBy);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _SettlementModel implements SettlementModel {
  const _SettlementModel({required this.id, required this.tripId, required this.version, @TimestampConverter() required this.timestamp, required final  Map<String, double> balances, required final  List<SettlementTransaction> transactions, required final  List<String> expenseIdsIncluded, required this.createdBy}): _balances = balances,_transactions = transactions,_expenseIdsIncluded = expenseIdsIncluded;
  factory _SettlementModel.fromJson(Map<String, dynamic> json) => _$SettlementModelFromJson(json);

@override final  String id;
@override final  String tripId;
@override final  int version;
@override@TimestampConverter() final  DateTime timestamp;
 final  Map<String, double> _balances;
@override Map<String, double> get balances {
  if (_balances is EqualUnmodifiableMapView) return _balances;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_balances);
}

// uid -> net balance
 final  List<SettlementTransaction> _transactions;
// uid -> net balance
@override List<SettlementTransaction> get transactions {
  if (_transactions is EqualUnmodifiableListView) return _transactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactions);
}

// suggested transfers
 final  List<String> _expenseIdsIncluded;
// suggested transfers
@override List<String> get expenseIdsIncluded {
  if (_expenseIdsIncluded is EqualUnmodifiableListView) return _expenseIdsIncluded;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expenseIdsIncluded);
}

// Immutability
@override final  String createdBy;

/// Create a copy of SettlementModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettlementModelCopyWith<_SettlementModel> get copyWith => __$SettlementModelCopyWithImpl<_SettlementModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SettlementModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettlementModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.version, version) || other.version == version)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other._balances, _balances)&&const DeepCollectionEquality().equals(other._transactions, _transactions)&&const DeepCollectionEquality().equals(other._expenseIdsIncluded, _expenseIdsIncluded)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tripId,version,timestamp,const DeepCollectionEquality().hash(_balances),const DeepCollectionEquality().hash(_transactions),const DeepCollectionEquality().hash(_expenseIdsIncluded),createdBy);

@override
String toString() {
  return 'SettlementModel(id: $id, tripId: $tripId, version: $version, timestamp: $timestamp, balances: $balances, transactions: $transactions, expenseIdsIncluded: $expenseIdsIncluded, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class _$SettlementModelCopyWith<$Res> implements $SettlementModelCopyWith<$Res> {
  factory _$SettlementModelCopyWith(_SettlementModel value, $Res Function(_SettlementModel) _then) = __$SettlementModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String tripId, int version,@TimestampConverter() DateTime timestamp, Map<String, double> balances, List<SettlementTransaction> transactions, List<String> expenseIdsIncluded, String createdBy
});




}
/// @nodoc
class __$SettlementModelCopyWithImpl<$Res>
    implements _$SettlementModelCopyWith<$Res> {
  __$SettlementModelCopyWithImpl(this._self, this._then);

  final _SettlementModel _self;
  final $Res Function(_SettlementModel) _then;

/// Create a copy of SettlementModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tripId = null,Object? version = null,Object? timestamp = null,Object? balances = null,Object? transactions = null,Object? expenseIdsIncluded = null,Object? createdBy = null,}) {
  return _then(_SettlementModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,balances: null == balances ? _self._balances : balances // ignore: cast_nullable_to_non_nullable
as Map<String, double>,transactions: null == transactions ? _self._transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<SettlementTransaction>,expenseIdsIncluded: null == expenseIdsIncluded ? _self._expenseIdsIncluded : expenseIdsIncluded // ignore: cast_nullable_to_non_nullable
as List<String>,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SettlementTransaction {

 String get fromUid; String get toUid; double get amount; bool get payerConfirmed; bool get receiverConfirmed; bool get isCompleted;@TimestampConverter() DateTime? get completedAt;
/// Create a copy of SettlementTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettlementTransactionCopyWith<SettlementTransaction> get copyWith => _$SettlementTransactionCopyWithImpl<SettlementTransaction>(this as SettlementTransaction, _$identity);

  /// Serializes this SettlementTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettlementTransaction&&(identical(other.fromUid, fromUid) || other.fromUid == fromUid)&&(identical(other.toUid, toUid) || other.toUid == toUid)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.payerConfirmed, payerConfirmed) || other.payerConfirmed == payerConfirmed)&&(identical(other.receiverConfirmed, receiverConfirmed) || other.receiverConfirmed == receiverConfirmed)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromUid,toUid,amount,payerConfirmed,receiverConfirmed,isCompleted,completedAt);

@override
String toString() {
  return 'SettlementTransaction(fromUid: $fromUid, toUid: $toUid, amount: $amount, payerConfirmed: $payerConfirmed, receiverConfirmed: $receiverConfirmed, isCompleted: $isCompleted, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $SettlementTransactionCopyWith<$Res>  {
  factory $SettlementTransactionCopyWith(SettlementTransaction value, $Res Function(SettlementTransaction) _then) = _$SettlementTransactionCopyWithImpl;
@useResult
$Res call({
 String fromUid, String toUid, double amount, bool payerConfirmed, bool receiverConfirmed, bool isCompleted,@TimestampConverter() DateTime? completedAt
});




}
/// @nodoc
class _$SettlementTransactionCopyWithImpl<$Res>
    implements $SettlementTransactionCopyWith<$Res> {
  _$SettlementTransactionCopyWithImpl(this._self, this._then);

  final SettlementTransaction _self;
  final $Res Function(SettlementTransaction) _then;

/// Create a copy of SettlementTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fromUid = null,Object? toUid = null,Object? amount = null,Object? payerConfirmed = null,Object? receiverConfirmed = null,Object? isCompleted = null,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
fromUid: null == fromUid ? _self.fromUid : fromUid // ignore: cast_nullable_to_non_nullable
as String,toUid: null == toUid ? _self.toUid : toUid // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,payerConfirmed: null == payerConfirmed ? _self.payerConfirmed : payerConfirmed // ignore: cast_nullable_to_non_nullable
as bool,receiverConfirmed: null == receiverConfirmed ? _self.receiverConfirmed : receiverConfirmed // ignore: cast_nullable_to_non_nullable
as bool,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SettlementTransaction].
extension SettlementTransactionPatterns on SettlementTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettlementTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettlementTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettlementTransaction value)  $default,){
final _that = this;
switch (_that) {
case _SettlementTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettlementTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _SettlementTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fromUid,  String toUid,  double amount,  bool payerConfirmed,  bool receiverConfirmed,  bool isCompleted, @TimestampConverter()  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettlementTransaction() when $default != null:
return $default(_that.fromUid,_that.toUid,_that.amount,_that.payerConfirmed,_that.receiverConfirmed,_that.isCompleted,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fromUid,  String toUid,  double amount,  bool payerConfirmed,  bool receiverConfirmed,  bool isCompleted, @TimestampConverter()  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _SettlementTransaction():
return $default(_that.fromUid,_that.toUid,_that.amount,_that.payerConfirmed,_that.receiverConfirmed,_that.isCompleted,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fromUid,  String toUid,  double amount,  bool payerConfirmed,  bool receiverConfirmed,  bool isCompleted, @TimestampConverter()  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _SettlementTransaction() when $default != null:
return $default(_that.fromUid,_that.toUid,_that.amount,_that.payerConfirmed,_that.receiverConfirmed,_that.isCompleted,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _SettlementTransaction implements SettlementTransaction {
  const _SettlementTransaction({required this.fromUid, required this.toUid, required this.amount, this.payerConfirmed = false, this.receiverConfirmed = false, this.isCompleted = false, @TimestampConverter() this.completedAt});
  factory _SettlementTransaction.fromJson(Map<String, dynamic> json) => _$SettlementTransactionFromJson(json);

@override final  String fromUid;
@override final  String toUid;
@override final  double amount;
@override@JsonKey() final  bool payerConfirmed;
@override@JsonKey() final  bool receiverConfirmed;
@override@JsonKey() final  bool isCompleted;
@override@TimestampConverter() final  DateTime? completedAt;

/// Create a copy of SettlementTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettlementTransactionCopyWith<_SettlementTransaction> get copyWith => __$SettlementTransactionCopyWithImpl<_SettlementTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SettlementTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettlementTransaction&&(identical(other.fromUid, fromUid) || other.fromUid == fromUid)&&(identical(other.toUid, toUid) || other.toUid == toUid)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.payerConfirmed, payerConfirmed) || other.payerConfirmed == payerConfirmed)&&(identical(other.receiverConfirmed, receiverConfirmed) || other.receiverConfirmed == receiverConfirmed)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromUid,toUid,amount,payerConfirmed,receiverConfirmed,isCompleted,completedAt);

@override
String toString() {
  return 'SettlementTransaction(fromUid: $fromUid, toUid: $toUid, amount: $amount, payerConfirmed: $payerConfirmed, receiverConfirmed: $receiverConfirmed, isCompleted: $isCompleted, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$SettlementTransactionCopyWith<$Res> implements $SettlementTransactionCopyWith<$Res> {
  factory _$SettlementTransactionCopyWith(_SettlementTransaction value, $Res Function(_SettlementTransaction) _then) = __$SettlementTransactionCopyWithImpl;
@override @useResult
$Res call({
 String fromUid, String toUid, double amount, bool payerConfirmed, bool receiverConfirmed, bool isCompleted,@TimestampConverter() DateTime? completedAt
});




}
/// @nodoc
class __$SettlementTransactionCopyWithImpl<$Res>
    implements _$SettlementTransactionCopyWith<$Res> {
  __$SettlementTransactionCopyWithImpl(this._self, this._then);

  final _SettlementTransaction _self;
  final $Res Function(_SettlementTransaction) _then;

/// Create a copy of SettlementTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fromUid = null,Object? toUid = null,Object? amount = null,Object? payerConfirmed = null,Object? receiverConfirmed = null,Object? isCompleted = null,Object? completedAt = freezed,}) {
  return _then(_SettlementTransaction(
fromUid: null == fromUid ? _self.fromUid : fromUid // ignore: cast_nullable_to_non_nullable
as String,toUid: null == toUid ? _self.toUid : toUid // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,payerConfirmed: null == payerConfirmed ? _self.payerConfirmed : payerConfirmed // ignore: cast_nullable_to_non_nullable
as bool,receiverConfirmed: null == receiverConfirmed ? _self.receiverConfirmed : receiverConfirmed // ignore: cast_nullable_to_non_nullable
as bool,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
