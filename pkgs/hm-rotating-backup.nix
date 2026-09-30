{ writeShellApplication, coreutils }:

writeShellApplication {
  name = "hm-rotating-backup";
  runtimeInputs = [ coreutils ];
  text = ''
    target="''${1:?target path required}"
    keep=3

    rm -rf -- "$target.hm-backup.$keep"
    i=$((keep - 1))
    while [ "$i" -ge 1 ]; do
      src="$target.hm-backup.$i"
      dst="$target.hm-backup.$((i + 1))"
      if [ -e "$src" ] || [ -L "$src" ]; then
        mv -T -- "$src" "$dst"
      fi
      i=$((i - 1))
    done

    mv -T -- "$target" "$target.hm-backup.1"
  '';
}
