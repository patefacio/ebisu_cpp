part of ebisu_cpp.ebisu_cpp;

class Union extends CppEntity with AggregateBase {
  List<Member> get members => _members;

  // custom <class Union>

  Union(id) : super(id);

  Iterable<Entity> get children => members;

  get unionName => namer.nameUnion(id);

  get definition => brCompact([
        'union $unionName {',
        _memberJoinFormat(members),
        '};',
      ]);

  set members(members) => _members = new List.from(members);

  _memberJoinFormat(mems) =>
      brCompact(mems.map((m) => m._wrapIfDef(m.hasComment ? '\n$m' : '$m')));

  onOwnershipEstablished() {
    if (members.where((m) => m.hasNoInit == false || m.init != null).length >
        1) {
      throw "Union $id may have only one member initialized";
    }
  }

  // end <class Union>

  List<Member> _members = [];
}

// custom <part union>

/// Convenience fucnction for creating a [Union]
///
/// All unions must be named with an [Id]. This method accepts an [Id] or
/// creates one. Creation of [Id] requires a string in *snake case*
Union union(id) => new Union(id);

// end <part union>
