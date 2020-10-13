{ stdenv
, fetchurl
, jdk8
, unzip
}:

stdenv.mkDerivation rec {
  name    = "xmage_client";
  version = "1.4.45";

  src = fetchurl {
    url    = "haering.dev/mage-client.zip";
    sha256 = "0ynfkpay7yabzhpz327z07di75m15r2raq1rx0dgsavzn88pjz6a";
  };

  preferLocalBuild = true;

  unpackPhase = ''
    ${unzip}/bin/unzip $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -rv ./* $out

    cat << EOF > $out/bin/xmage_client
exec ${jdk8}/bin/java -Xms1g -Xmx4g -XX:MaxPermSize=384m -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -jar $out/lib/mage-client-1.4.45.jar
EOF

    chmod +x $out/bin/xmage_client
  '';

  meta = with stdenv.lib; {
    description = "Magic Another Game Engine client";
    license = licenses.mit;
    maintainers = with maintainers; [ matthiasbeyer ];
    homepage = "http://xmage.de/";
  };

}
