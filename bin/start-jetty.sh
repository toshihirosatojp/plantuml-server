#!/usr/bin/env bash
set -euo pipefail

JETTY_VERSION=12.1.6
JETTY_HOME="$PWD/jetty-home"
JETTY_BASE="$PWD/jetty-base"

# Download Jetty 12 nếu chưa có
if [ ! -f "$JETTY_HOME/start.jar" ]; then
    mkdir -p "$JETTY_HOME"
    curl -fsSL "https://repo.maven.apache.org/maven2/org/eclipse/jetty/jetty-home/$JETTY_VERSION/jetty-home-$JETTY_VERSION.tar.gz" | tar -xz -C "$JETTY_HOME" --strip-components=1
fi

# Configure Jetty
mkdir -p "$JETTY_BASE/webapps"

if [ ! -f "$JETTY_BASE/start.d/http.ini" ]; then
    java -Djetty.base="$JETTY_BASE" -jar "$JETTY_HOME/start.jar" --add-modules=http,ee11-deploy,ee11-jsp,ee11-jstl
fi

# Deploy PlantUML at /
cp target/plantuml.war "$JETTY_BASE/webapps/ROOT.war"

# Start Jetty on Heroku port
cd "$JETTY_BASE"
exec java ${JAVA_OPTS:-} -DGRAPHVIZ_DOT=/app/.heroku-buildpack-graphviz/usr/bin/dot -jar "$JETTY_HOME/start.jar" "jetty.http.port=${PORT:-8080}"
