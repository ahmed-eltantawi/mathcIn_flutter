import 'dart:typed_data';

/// A platform-independent picked file.
///
/// The file picker plugin exposes its result as an abstract,
/// platform-provided type that cannot be constructed or read uniformly
/// in every environment. This value object carries exactly what the
/// upload flow needs (name + in-memory bytes) on mobile and web alike.
class PickedFile {
  const PickedFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}
