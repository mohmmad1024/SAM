export conf=${BASE_DIR}/conf/streamline-doc.yaml

yq w -i $conf server.applicationConnectors.[0].port ${HTTP_PORT:=8080}
yq w -i $conf server.adminConnectors.[0].port ${ADMIN_HTTP_PORT:=8080}

yq w -i $conf storageProviderConfiguration.db.type ${DB_TYPE:=mysql}
yq w -i $conf storageProviderConfiguration.db.properties.dataSourceClassName ${DB_CLASS_NAME:=com.mysql.jdbc.jdbc2.optional.MysqlDataSource}
yq w -i $conf storageProviderConfiguration.db.properties.dataSource.url ${DB_URL:=jdbc:mysql://localhost/streamline_db}
yq w -i $conf storageProviderConfiguration.db.properties.dataSource.user ${DB_USER:=streamline_user}
yq w -i $conf storageProviderConfiguration.db.properties.dataSource.password ${DB_PASSWORD:=streamline_password}

yq w -i $conf logging.loggers.com.hortonworks.streamline ${LOGGING_LEVEL:=INFO}

yq w -i $conf catalogRootUrl ${CATALOG_ROOT_URL:=http://localhost:${HTTP_PORT}/api/v1/catalog}

${BASE_DIR}/bootstrap/bootstrap.sh migrate

tail -f ${BASE_DIR}/logs/streamline.log &

${BASE_DIR}/bin/streamline-server-start.sh ${BASE_DIR}/conf/streamline.yaml
trap "Received trapped signal (sam is down), beginning shutdown...;" KILL TERM HUP INT EXIT;
sam_pid="$!"
wait ${sam_pid}