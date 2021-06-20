part of transloadit;

class Options {
  late TransloaditClient client;
  late Map<String, XFile> files;
  Map<String, dynamic>? _options;
  late Map<String, dynamic> steps;

  Options({Map<String, dynamic>? options}) {
    options = options ?? {};
    steps = {};
  }

  void addStep(String name, String robot, Map<String, dynamic> options) {
    options["robot"] = robot;
    steps[name] = options;
  }

  void removeStep(String name) {
    steps.remove(name);
  }

  Map<String, dynamic> get options {
    final _optionsCopy = _options ?? {};
    _optionsCopy["steps"] = steps;
    return _optionsCopy;
  }
}
