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
    sha256 = "14g4ll95hacv6s648r3av608bnj6r40fcqxz6z2kq38p08cd98zs";
  };

  preferLocalBuild = true;

  unpackPhase = ''
    ${unzip}/bin/unzip $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -rv ./* $out

    cat << EOF > $out/bin/xmage_server
exec ${jdk8}/bin/java -Xms1g -Xmx4g -jar -Dfile.encoding=UTF-8 -Djava.security.policy=$out/config/security.policy -Dlog4j.configuration=file:$out/config/log4j.properties -Dconfig-path=$out/config/config.xml -Dplugin-path=$out/plugins/ -Dextension-path=$out/extension/ -jar $out/lib/mage-server-1.4.45.jar
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

