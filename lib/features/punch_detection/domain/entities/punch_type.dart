/// Enumeração dos tipos de golpes do boxe.
enum PunchType {
  none,
  jab,
  cross,
  hook,
  uppercut,
}

extension PunchTypeExtension on PunchType {
  String get displayName {
    switch (this) {
      case PunchType.jab:
        return 'JAB (Braço da Frente)';
      case PunchType.cross:
        return 'DIRECT (Braço de Trás)';
      case PunchType.hook:
        return 'HOOK (Cruzado)';
      case PunchType.uppercut:
        return 'UPPERCUT';
      case PunchType.none:
        return 'Guarda / Em Espera';
    }
  }
}
