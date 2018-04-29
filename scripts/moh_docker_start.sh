export conf=${BASE_DIR}/conf/streamline.yaml

yq w -i $conf server.applicationConnectors.[0].port ${HTTP_PORT:=8080}
yq w -i $conf server.adminConnectors.[0].port ${ADMIN_HTTP_PORT:=8080}

yq w -i $conf storageProviderConfiguration.properties.\"db.type\" \"${DB_TYPE:=mysql}\"
yq w -i $conf storageProviderConfiguration.properties.\"db.properties\".dataSourceClassName \"${DB_CLASS_NAME:=com.mysql.jdbc.jdbc2.optional.MysqlDataSource}\"
yq w -i $conf storageProviderConfiguration.properties.\"db.properties\".\"dataSource.url\" \"jdbc:${DB_TYPE:=mysql}://${DB_HOST:=mysql}:${DB_PORT:=3306}/${DB_NAME:=database}\"
yq w -i $conf storageProviderConfiguration.properties.\"db.properties\".\"dataSource.user\" \"${DB_USER:=streamline_user}\"
yq w -i $conf storageProviderConfiguration.properties.\"db.properties\".\"dataSource.password\" \"${DB_PASSWORD:=streamline_password}\"

yq w -i $conf logging.loggers.\"com.hortonworks.streamline\" ${LOGGING_LEVEL:=INFO}

yq w -i $conf catalogRootUrl ${CATALOG_ROOT_URL:=http://localhost:${HTTP_PORT}/api/v1/catalog}

mkdir -p ${BASE_DIR}/logs/
touch ${BASE_DIR}/logs/streamline.log

tail -f ${BASE_DIR}/logs/streamline.log &

${BASE_DIR}/scripts/wait-for-it.sh $DB_HOST:$DB_PORT --timeout=30 --strict -- ${BASE_DIR}/bootstrap/bootstrap.sh migrate

${BASE_DIR}/bin/streamline-server-start.sh ${conf}
trap "Received trapped signal (sam is down), beginning shutdown...;" KILL TERM HUP INT EXIT;
sam_pid="$!"
wait ${sam_pid}