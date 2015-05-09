/// Support for *Semantic Versioning*
part of ebisu_cpp.ebisu_cpp;

/// Provides data required to track a Semantic Version
class SemanticVersion {
  const SemanticVersion(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  // custom <class SemanticVersion>

  factory SemanticVersion.fromString(String version) {
    final match = _versionRe.firstMatch(version);
    if (match == null) {
      throw new ArgumentError(
          r'Version must be of form (\d+).(\d+).(\d+): $version');
    }

    final major = int.parse(match.group(1));
    final minor = int.parse(match.group(2));
    final patch = int.parse(match.group(3));

    return new SemanticVersion(major, minor, patch);
  }

  static final RegExp _versionRe = new RegExp(r'(\d+).(\d+).(\d+)');

  toString() => 'version $major.$minor.$patch';

  // end <class SemanticVersion>

}

// custom <part versioning>
// end <part versioning>
