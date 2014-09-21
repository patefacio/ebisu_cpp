part of cpp_meta;

String enum([dynamic _]) {
  if(_ is Map) {
    _ = new Context(_);
  }
  List<String> _buf = new List<String>();


  _buf.add('''

''');
  return _buf.join();
}