<div dir="rtl">

# 🔁 خطوات تنفيذ أي Feature جديدة
> الـ `core/` جاهز ✅ — ركّز هنا فقط على الـ Feature Pipeline
>
> **المثال المستخدم في الشرح:** Feature اسمها **"الحقيبة"** 👜 (`bag`)

---

## 🗂️ هيكل الـ Feature

```
lib/features/bag/
├── data/
│   ├── data_sources/
│   │   ├── bag_remote_data_source.dart           ← Abstract
│   │   ├── bag_remote_data_source_impl.dart      ← Real API
│   │   └── bag_mock_remote_data_source_impl.dart ← Offline Testing
│   ├── models/
│   │   └── bag_model.dart                        ← JSON → Object
│   └── repositories/
│       └── bag_repository_impl.dart              ← Exception → Failure
├── domain/
│   ├── entities/
│   │   └── bag_entity.dart                       ← Pure Dart
│   ├── repositories/
│   │   └── bag_repository.dart                   ← Abstract Contract
│   └── use_cases/
│       └── get_bag_use_case.dart                 ← واحد لكل Action
└── presentation/
    ├── cubit/
    │   ├── bag_cubit.dart
    │   └── bag_state.dart
    ├── pages/
    │   └── bag_view.dart
    └── widgets/
        └── bag/
```

---

## ✅ الـ Checklist — 8 خطوات بالترتيب

---

### 1️⃣ Data Sources

**`bag_remote_data_source.dart`** ← العقد (Abstract)
```dart
abstract class BagRemoteDataSource {
  Future<BagModel> getBag({required int userId});
}
```

**`bag_remote_data_source_impl.dart`** ← Real API
```dart
class BagRemoteDataSourceImpl implements BagRemoteDataSource {
  const BagRemoteDataSourceImpl({required ApiConsumer apiConsumer})
      : _apiConsumer = apiConsumer;

  final ApiConsumer _apiConsumer;

  @override
  Future<BagModel> getBag({required int userId}) async {
    final response = await _apiConsumer.get(
      EndPoint.getBag,                       // ← من EndPoint مش String
      queryParameters: {ApiKey.userId: userId}, // ← من ApiKey مش String
    );
    return BagModel.fromJson(response as Map<String, dynamic>);
  }
}
```

**`bag_mock_remote_data_source_impl.dart`** ← Mock (Offline)
```dart
class BagMockRemoteDataSourceImpl implements BagRemoteDataSource {
  const BagMockRemoteDataSourceImpl();

  @override
  Future<BagModel> getBag({required int userId}) async {
    await Future.delayed(const Duration(seconds: 1));
    return const BagModel(id: 1, name: 'حقيبة تجريبية', itemCount: 5);
  }
}
```

---

### 2️⃣ Model (تحويل JSON → Object)

**`data/models/bag_model.dart`**
```dart
class BagModel extends BagEntity {
  const BagModel({
    required super.id,
    required super.name,
    required super.itemCount,
  });

  factory BagModel.fromJson(Map<String, dynamic> json) => BagModel(
        id: json[ApiKey.id] as int,
        name: json[ApiKey.name] as String,
        itemCount: json[ApiKey.itemCount] as int,
      );
}
```
> لو الـ Response `void` (مثل حذف حقيبة) → **مفيش Model خالص**

---

### 3️⃣ Entity (Pure Dart — لا JSON، لا Flutter)

**`domain/entities/bag_entity.dart`**
```dart
class BagEntity extends Equatable {
  const BagEntity({
    required this.id,
    required this.name,
    required this.itemCount,
  });

  final int id;
  final String name;
  final int itemCount;

  @override
  List<Object?> get props => [id, name, itemCount];
}
```

---

### 4️⃣ Repository

**`domain/repositories/bag_repository.dart`** ← Interface
```dart
abstract class BagRepository {
  Future<Either<Failure, BagEntity>> getBag({required int userId});
  //                          ↑ لو void استخدم Unit بدل BagEntity
}
```

**`data/repositories/bag_repository_impl.dart`** ← Implementation
```dart
class BagRepositoryImpl implements BagRepository {
  const BagRepositoryImpl({required BagRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final BagRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, BagEntity>> getBag({required int userId}) async {
    try {
      final bag = await _remoteDataSource.getBag(userId: userId);
      return right(bag);
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.errorModel.errorMessage));
    } on OfflineException {
      return left(const OfflineFailure());
    }
  }
}
```
> هنا **فقط** بتتحوّل الـ Exception لـ Failure

---

### 5️⃣ UseCase (واحد لكل Action)

**`domain/use_cases/get_bag_use_case.dart`**
```dart
class GetBagUseCase {
  const GetBagUseCase({required BagRepository repository})
      : _repository = repository;

  final BagRepository _repository;

  Future<Either<Failure, BagEntity>> call({required int userId}) =>
      _repository.getBag(userId: userId);
}
```
> لو في Feature بيها كذا Action → كذا UseCase منفصل:
> `GetBagUseCase`, `AddItemToBagUseCase`, `ClearBagUseCase`

---

### 6️⃣ تسجيل الـ DI في `services_locator.dart`

```dart
// ─── Bag Feature ─────────────────────────────────────
// Cubit → registerFactory دايماً
getIt.registerFactory<BagCubit>(
  () => BagCubit(getBagUseCase: getIt()),
);

// UseCase → registerLazySingleton
getIt.registerLazySingleton<GetBagUseCase>(
  () => GetBagUseCase(repository: getIt()),
);

// Repository → سجّل الـ Abstract مش الـ Concrete
getIt.registerLazySingleton<BagRepository>(
  () => BagRepositoryImpl(remoteDataSource: getIt()),
);

// DataSource → سجّل الـ Abstract مش الـ Concrete
getIt.registerLazySingleton<BagRemoteDataSource>(
  () => BagRemoteDataSourceImpl(apiConsumer: getIt()),
  // () => BagMockRemoteDataSourceImpl(), ← للتجربة Offline
);
```

---

### 7️⃣ State + Cubit

**`presentation/cubit/bag_state.dart`**
```dart
sealed class BagState {}

final class BagInitial extends BagState {}
final class BagLoading extends BagState {}

final class BagLoaded extends BagState {
  BagLoaded({required this.bag});
  final BagEntity bag;
}

final class BagFailure extends BagState {
  BagFailure({required this.errorMessage});
  final String errorMessage;
}
```

**`presentation/cubit/bag_cubit.dart`**
```dart
class BagCubit extends Cubit<BagState> {
  BagCubit({required GetBagUseCase getBagUseCase})
      : _getBagUseCase = getBagUseCase,
        super(BagInitial());

  final GetBagUseCase _getBagUseCase;

  Future<void> loadBag({required int userId}) async {
    emit(BagLoading());
    final result = await _getBagUseCase(userId: userId);
    result.fold(
      (failure) => emit(BagFailure(errorMessage: failure.message)),
      (bag) => emit(BagLoaded(bag: bag)),
    );
  }
}
```
> الـ Cubit لا يعرف عن الـ UI إطلاقاً — لا Navigation، لا SnackBar، لا BuildContext

---

### 8️⃣ Router + View

**في `app_router.dart`:**
```dart
GoRoute(
  path: AppRoutes.kBagView,
  builder: (context, state) => BlocProvider(
    create: (_) => getIt<BagCubit>(),
    child: const BagView(),
  ),
),
```

**في `bag_view.dart`:**
```dart
BlocConsumer<BagCubit, BagState>(
  listener: (context, state) {
    // Side Effects فقط: Navigation, SnackBar, Dialog
    if (state is BagFailure) {
      context.showErrorSnackBar(state.errorMessage);
    }
  },
  builder: (context, state) {
    // UI فقط
    return switch (state) {
      BagLoading() => const CircularProgressIndicator(),
      BagLoaded()  => BagContent(bag: state.bag),
      BagFailure() => const SizedBox.shrink(),
      BagInitial() => const SizedBox.shrink(),
    };
  },
)
```

---

## 🔁 تدفق البيانات

```
[View] onPressed / initState
  ↓ context.read<BagCubit>().loadBag(userId: id)
[Cubit] emit(BagLoading) → GetBagUseCase.call()
  ↓
[UseCase] → BagRepository.getBag()
  ↓
[RepositoryImpl] → BagRemoteDataSource.getBag() → catch Exception → Either
  ↓
[DataSourceImpl] → HTTP GET Request → BagModel.fromJson()
  ↑↑↑ الرد يصعد بنفس الترتيب
[Cubit] result.fold → emit(BagLoaded) أو emit(BagFailure)
  ↓
[View] listener (SnackBar) + builder (يعرض الحقيبة أو شاشة الخطأ)
```

---

## 🚨 القواعد الذهبية

| ❌ غلط | ✅ صح |
|---|---|
| `'bag/get'` | `EndPoint.getBag` |
| `{'user_id': id}` | `{ApiKey.userId: id}` |
| `registerLazySingleton<BagCubit>` | `registerFactory<BagCubit>` |
| `getIt<BagCubit>()` داخل الـ Widget | `context.read<BagCubit>().loadBag(...)` |
| `Navigator.push(...)` | `context.push(AppRoutes.kBagView)` |
| `Colors.blue` | `context.colors.primary` |
| `../../features/bag/...` | `package:MatchIn/features/bag/...` |
| `print(...)` | ❌ ممنوع تماماً |

</div>
