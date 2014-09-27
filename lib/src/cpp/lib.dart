part of ebisu_cpp.cpp;

class Lib extends Entity {

  List<Class> classes = [];

  // custom <class Lib>

  Lib(Id id) : super(id);

  // end <class Lib>
}
// custom <part lib>

Lib lib(Object id) => new Lib(id is Id? id : new Id(id));

// end <part lib>
