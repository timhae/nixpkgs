{ stdenv
, fetchurl
, jdk8
, unzip
}:

stdenv.mkDerivation rec {
  name    = "xmage_server";
  version = "1.4.45";

  src = fetchurl {
    url    = "haering.dev/mage-server.zip";
    sha256 = "1p3kipm7ik1hgj6d5k5af5ghhh060y0hyxachzfjxaymdbmldl0z";
  };

  unpackPhase = ''
    ${unzip}/bin/unzip $src
  '';

  installPhase = ''
    # Install files.
    mkdir -p $out/bin
    mv * $out

    # Replace java binary.
    cat << EOF > $out/bin/xmage_server
exec ${jdk8}/bin/java -Xms1g -Xmx4g -jar -Dfile.encoding=UTF-8 -Djava.security.policy=$out/config/security.policy -Dlog4j.configuration=file:$out/config/log4j.properties -Dconfig-path=$out/config/config.xml -jar $out/lib/mage-server-1.4.45.jar
EOF
    chmod +x $out/bin/xmage_server
  '';

  meta = with stdenv.lib; {
    description = "Magic Another Game Engine server";
    license = licenses.mit;
    maintainers = with maintainers; [ matthiasbeyer ];
    homepage = "http://xmage.de/";
  };

}

