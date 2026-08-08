{
  shellVersion ? "dev",
}:

final: _prev: {
  ttf-phosphor-icons = final.callPackage ./ttf-phosphor-icons { };
  pangu = final.callPackage ./pangu { version = shellVersion; };
}
