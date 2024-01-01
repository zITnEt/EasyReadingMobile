class Concept {
  final String concept;
  final String definition;

  Concept({
    required this.concept,
    required this.definition,
  });

  Map<String, dynamic> toMap() {
    return {
      'concept': concept,
      'definition': definition
    };
  }
}